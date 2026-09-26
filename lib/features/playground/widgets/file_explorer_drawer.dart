import 'package:flutter/material.dart';
import '../models/playground_file.dart';
import '../services/playground_file_service.dart';
import '../../../core/theme/app_theme.dart';

class FileExplorerDrawer extends StatefulWidget {
  final String projectName;
  final List<PlaygroundFile> files;
  final PlaygroundFile? activeFile;
  final void Function(PlaygroundFile file) onFileSelected;
  final void Function(String fileName) onFileCreated;
  final void Function(PlaygroundFile file) onFileDeleted;
  final VoidCallback onRefresh;

  const FileExplorerDrawer({
    super.key,
    required this.projectName,
    required this.files,
    required this.activeFile,
    required this.onFileSelected,
    required this.onFileCreated,
    required this.onFileDeleted,
    required this.onRefresh,
  });

  @override
  State<FileExplorerDrawer> createState() => _FileExplorerDrawerState();
}

class _FileExplorerDrawerState extends State<FileExplorerDrawer> {

  void _showNewFileDialog() {
    final controller = TextEditingController(text: 'newfile.html');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('New File', style: TextStyle(color: AppTheme.textPrimaryDark)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppTheme.textPrimaryDark, fontFamily: 'monospace'),
          decoration: InputDecoration(
            hintText: 'filename.html',
            hintStyle: const TextStyle(color: AppTheme.textMutedDark),
            filled: true,
            fillColor: AppTheme.surfaceDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.cardBorderDark),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMutedDark)),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(ctx);
                widget.onFileCreated(name);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(PlaygroundFile file) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete File', style: TextStyle(color: AppTheme.textPrimaryDark)),
        content: Text(
          'Delete "${file.name}"? This cannot be undone.',
          style: const TextStyle(color: AppTheme.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMutedDark)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onFileDeleted(file);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0D1117),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFF21262D))),
              ),
              child: Row(
                children: [
                  const Icon(Icons.folder_open_rounded, color: AppTheme.warning, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.projectName.toUpperCase(),
                      style: const TextStyle(
                        color: AppTheme.textPrimaryDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        letterSpacing: 0.8,
                        fontFamily: 'monospace',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_rounded, color: AppTheme.primary, size: 20),
                    onPressed: _showNewFileDialog,
                    tooltip: 'New File',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // File List
            Expanded(
              child: widget.files.isEmpty
                  ? const Center(
                      child: Text(
                        'No files yet.\nTap + to create one.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.textMutedDark, fontSize: 13),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: widget.files.length,
                      itemBuilder: (ctx, i) {
                        final file = widget.files[i];
                        final isActive = widget.activeFile?.name == file.name;
                        return _FileItem(
                          file: file,
                          isActive: isActive,
                          onTap: () {
                            widget.onFileSelected(file);
                            Navigator.of(context).pop(); // close drawer
                          },
                          onDelete: () => _confirmDelete(file),
                        );
                      },
                    ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFF21262D))),
              ),
              child: Row(
                children: [
                  const Icon(Icons.storage_rounded, color: AppTheme.textMutedDark, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.files.length} file${widget.files.length != 1 ? 's' : ''}',
                    style: const TextStyle(color: AppTheme.textMutedDark, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Single File Item ─────────────────────────────────────────────────────────

class _FileItem extends StatelessWidget {
  final PlaygroundFile file;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _FileItem({
    required this.file,
    required this.isActive,
    required this.onTap,
    required this.onDelete,
  });

  Color get _iconColor {
    switch (file.language) {
      case FileLanguage.html:
        return const Color(0xFFE34C26);
      case FileLanguage.css:
        return const Color(0xFF264DE4);
      case FileLanguage.javascript:
        return const Color(0xFFF0DB4F);
      case FileLanguage.markdown:
        return const Color(0xFF94A3B8);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  IconData get _fileIcon {
    switch (file.language) {
      case FileLanguage.html:
        return Icons.html_rounded;
      case FileLanguage.css:
        return Icons.brush_rounded;
      case FileLanguage.javascript:
        return Icons.javascript_rounded;
      case FileLanguage.markdown:
        return Icons.article_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: isActive
              ? BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.12),
                  border: const Border(
                    left: BorderSide(color: AppTheme.primary, width: 2),
                  ),
                )
              : null,
          child: Row(
            children: [
              Icon(_fileIcon, color: _iconColor, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  file.name,
                  style: TextStyle(
                    color: isActive ? Colors.white : const Color(0xFFCDD9E5),
                    fontSize: 13.5,
                    fontFamily: 'monospace',
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (file.isModified)
                Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: const BoxDecoration(
                    color: AppTheme.warning,
                    shape: BoxShape.circle,
                  ),
                ),
              GestureDetector(
                onTap: onDelete,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close_rounded, size: 15, color: Color(0xFF6B7280)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
