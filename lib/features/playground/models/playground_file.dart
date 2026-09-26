import 'dart:io';

enum FileLanguage { html, css, javascript, markdown, text }

class PlaygroundFile {
  final String name;
  String content;
  bool isModified;
  final DateTime createdAt;
  DateTime lastModified;

  PlaygroundFile({
    required this.name,
    required this.content,
    this.isModified = false,
    DateTime? createdAt,
    DateTime? lastModified,
  })  : createdAt = createdAt ?? DateTime.now(),
        lastModified = lastModified ?? DateTime.now();

  String get extension {
    final parts = name.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : 'txt';
  }

  FileLanguage get language {
    switch (extension) {
      case 'html':
      case 'htm':
        return FileLanguage.html;
      case 'css':
        return FileLanguage.css;
      case 'js':
      case 'ts':
        return FileLanguage.javascript;
      case 'md':
        return FileLanguage.markdown;
      default:
        return FileLanguage.text;
    }
  }

  String get languageLabel {
    switch (language) {
      case FileLanguage.html:
        return 'HTML';
      case FileLanguage.css:
        return 'CSS';
      case FileLanguage.javascript:
        return 'JavaScript';
      case FileLanguage.markdown:
        return 'Markdown';
      default:
        return 'Plain Text';
    }
  }

  static PlaygroundFile fromFile(File file) {
    return PlaygroundFile(
      name: file.path.split('/').last,
      content: file.existsSync() ? file.readAsStringSync() : '',
      lastModified: file.existsSync() ? file.lastModifiedSync() : DateTime.now(),
    );
  }
}
