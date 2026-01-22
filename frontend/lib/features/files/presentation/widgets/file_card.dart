import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/file_item.dart';

/// Minimal File Card
///
/// Shows only thumbnail/icon and name. Metadata shown on tap.
class FileCard extends StatelessWidget {
  final FileItem file;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const FileCard({super.key, required this.file, this.onTap, this.onLongPress});

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thumbnail area (larger, no padding)
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: _buildThumbnail(isDark),
              ),
            ),
            // Name only (minimal)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                    width: 0.5,
                  ),
                ),
              ),
              child: Text(
                file.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(bool isDark) {
    if (file.type == FileType.image) {
      return _ImageThumbnail(filePath: file.path, isDark: isDark);
    }
    if (file.type == FileType.video) {
      return _VideoThumbnail(filePath: file.path, isDark: isDark);
    }
    return _IconThumbnail(type: file.type, isDark: isDark);
  }
}

class _ImageThumbnail extends StatelessWidget {
  final String filePath;
  final bool isDark;

  const _ImageThumbnail({required this.filePath, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Image.file(
      File(filePath),
      fit: BoxFit.cover,
      cacheWidth: 300,
      errorBuilder: (_, __, ___) =>
          _IconThumbnail(type: FileType.image, isDark: isDark),
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) return child;
        return Container(
          color: isDark ? const Color(0xFF1A2E1A) : const Color(0xFFE8F5E9),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
    );
  }
}

class _VideoThumbnail extends StatefulWidget {
  final String filePath;
  final bool isDark;

  const _VideoThumbnail({required this.filePath, required this.isDark});

  @override
  State<_VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<_VideoThumbnail> {
  Uint8List? _thumbnail;
  bool _loading = true;

  static final Map<String, Uint8List> _cache = {};

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  Future<void> _loadThumbnail() async {
    if (_cache.containsKey(widget.filePath)) {
      if (mounted) {
        setState(() {
          _thumbnail = _cache[widget.filePath];
          _loading = false;
        });
      }
      return;
    }

    try {
      final thumb = await VideoThumbnail.thumbnailData(
        video: widget.filePath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 300,
        quality: 50,
      );
      if (thumb != null) {
        _cache[widget.filePath] = thumb;
        if (mounted)
          setState(() {
            _thumbnail = thumb;
            _loading = false;
          });
      } else {
        if (mounted) setState(() => _loading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        color: widget.isDark
            ? const Color(0xFF1E293B)
            : const Color(0xFFDBEAFE),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_thumbnail == null) {
      return _IconThumbnail(type: FileType.video, isDark: widget.isDark);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.memory(_thumbnail!, fit: BoxFit.cover),
        Center(
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }
}

class _IconThumbnail extends StatelessWidget {
  final FileType type;
  final bool isDark;

  const _IconThumbnail({required this.type, required this.isDark});

  IconData get _icon {
    switch (type) {
      case FileType.image:
        return Icons.image_rounded;
      case FileType.video:
        return Icons.play_circle_rounded;
      case FileType.audio:
        return Icons.music_note_rounded;
      case FileType.pdf:
        return Icons.picture_as_pdf_rounded;
      case FileType.text:
        return Icons.description_rounded;
    }
  }

  Color get _color {
    switch (type) {
      case FileType.image:
        return isDark ? const Color(0xFF4ADE80) : const Color(0xFF22C55E);
      case FileType.video:
        return isDark ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6);
      case FileType.audio:
        return isDark ? const Color(0xFFF472B6) : const Color(0xFFEC4899);
      case FileType.pdf:
        return isDark ? const Color(0xFFFB7185) : const Color(0xFFEF4444);
      case FileType.text:
        return isDark ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _color.withValues(alpha: 0.15),
      child: Center(child: Icon(_icon, size: 40, color: _color)),
    );
  }
}
