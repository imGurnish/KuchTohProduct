import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/file_item.dart';

/// File Item Card
///
/// Displays a single file with thumbnail (for images/videos) or icon.
class FileItemCard extends StatelessWidget {
  final FileItem file;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const FileItemCard({
    super.key,
    required this.file,
    this.onTap,
    this.onLongPress,
  });

  IconData get _icon {
    switch (file.type) {
      case FileType.image:
        return Icons.image_rounded;
      case FileType.video:
        return Icons.play_circle_rounded;
      case FileType.audio:
        return Icons.audiotrack_rounded;
      case FileType.pdf:
        return Icons.picture_as_pdf_rounded;
      case FileType.text:
        return Icons.description_rounded;
    }
  }

  Color _getIconColor(bool isDark) {
    switch (file.type) {
      case FileType.image:
        return isDark ? const Color(0xFF4ADE80) : const Color(0xFF22C55E);
      case FileType.video:
        return isDark ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6);
      case FileType.audio:
        return isDark ? const Color(0xFFFB7185) : const Color(0xFFEC4899);
      case FileType.pdf:
        return isDark ? const Color(0xFFFB7185) : const Color(0xFFEF4444);
      case FileType.text:
        return isDark ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B);
    }
  }

  Color _getIconBackgroundColor(bool isDark) {
    final color = _getIconColor(isDark);
    return color.withValues(alpha: isDark ? 0.2 : 0.1);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail/Icon area
              Expanded(child: _buildThumbnail(isDark)),
              const SizedBox(height: 10),
              // File name
              Text(
                file.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 4),
              // File size
              Text(
                file.formattedSize,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(bool isDark) {
    // Show actual image for image files
    if (file.type == FileType.image) {
      return _ImageThumbnail(filePath: file.path, isDark: isDark);
    }

    // Show video thumbnail for video files
    if (file.type == FileType.video) {
      return _VideoThumbnail(filePath: file.path, isDark: isDark);
    }

    // Show icon for other file types
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _getIconBackgroundColor(isDark),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(child: Icon(_icon, size: 40, color: _getIconColor(isDark))),
    );
  }
}

/// Image thumbnail widget
class _ImageThumbnail extends StatelessWidget {
  final String filePath;
  final bool isDark;

  const _ImageThumbnail({required this.filePath, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        File(filePath),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        cacheWidth: 200, // Limit size for performance
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) {
            return child;
          }
          return _buildLoading();
        },
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF22302C) : const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(
          Icons.broken_image_rounded,
          size: 32,
          color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF22C55E),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF22302C) : const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF22C55E),
          ),
        ),
      ),
    );
  }
}

/// Video thumbnail widget with caching
class _VideoThumbnail extends StatefulWidget {
  final String filePath;
  final bool isDark;

  const _VideoThumbnail({required this.filePath, required this.isDark});

  @override
  State<_VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<_VideoThumbnail> {
  Uint8List? _thumbnail;
  bool _isLoading = true;
  bool _hasError = false;

  // Simple in-memory cache for video thumbnails
  static final Map<String, Uint8List> _thumbnailCache = {};

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  Future<void> _loadThumbnail() async {
    // Check cache first
    if (_thumbnailCache.containsKey(widget.filePath)) {
      if (mounted) {
        setState(() {
          _thumbnail = _thumbnailCache[widget.filePath];
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final thumbnail = await VideoThumbnail.thumbnailData(
        video: widget.filePath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 200,
        quality: 50,
      );

      if (thumbnail != null) {
        _thumbnailCache[widget.filePath] = thumbnail;
        if (mounted) {
          setState(() {
            _thumbnail = thumbnail;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _hasError = true;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoading();
    }

    if (_hasError || _thumbnail == null) {
      return _buildPlaceholder();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            _thumbnail!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildPlaceholder(),
          ),
        ),
        // Play icon overlay
        Center(
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDark
            ? const Color(0xFF1E293B)
            : const Color(0xFFDBEAFE),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(
          Icons.play_circle_rounded,
          size: 40,
          color: widget.isDark
              ? const Color(0xFF60A5FA)
              : const Color(0xFF3B82F6),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDark
            ? const Color(0xFF1E293B)
            : const Color(0xFFDBEAFE),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: widget.isDark
                ? const Color(0xFF60A5FA)
                : const Color(0xFF3B82F6),
          ),
        ),
      ),
    );
  }
}
