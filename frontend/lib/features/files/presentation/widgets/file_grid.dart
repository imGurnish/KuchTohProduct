import 'package:flutter/material.dart';
import '../../domain/entities/file_item.dart';
import 'file_item_card.dart';

/// File Grid
///
/// Responsive grid layout for displaying files.
class FileGrid extends StatelessWidget {
  final List<FileItem> files;
  final ValueChanged<FileItem>? onFileTap;
  final ValueChanged<FileItem>? onFileLongPress;

  const FileGrid({
    super.key,
    required this.files,
    this.onFileTap,
    this.onFileLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        return FileItemCard(
          file: file,
          onTap: onFileTap != null ? () => onFileTap!(file) : null,
          onLongPress: onFileLongPress != null
              ? () => onFileLongPress!(file)
              : null,
        );
      },
    );
  }
}
