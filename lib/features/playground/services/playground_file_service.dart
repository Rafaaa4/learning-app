import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/playground_file.dart';

class PlaygroundFileService {
  static final PlaygroundFileService _instance = PlaygroundFileService._internal();
  factory PlaygroundFileService() => _instance;
  PlaygroundFileService._internal();

  static const String _projectsFolder = 'playground_projects';

  // ─── Paths ──────────────────────────────────────────────────────────────────

  Future<Directory> get _baseDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/$_projectsFolder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<Directory> projectDir(String projectName) async {
    final base = await _baseDir;
    final dir = Directory('${base.path}/$projectName');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  // ─── Projects ───────────────────────────────────────────────────────────────

  Future<List<String>> listProjects() async {
    final base = await _baseDir;
    final entries = base.listSync();
    return entries
        .whereType<Directory>()
        .map((d) => d.path.split('/').last)
        .toList()
      ..sort();
  }

  Future<void> createProject(String name) async {
    final dir = await projectDir(name);
    // Bootstrap with starter files
    await _writeFile(dir, 'index.html', _starterHtml);
    await _writeFile(dir, 'style.css', _starterCss);
    await _writeFile(dir, 'main.js', _starterJs);
  }

  Future<void> deleteProject(String name) async {
    final base = await _baseDir;
    final dir = Directory('${base.path}/$name');
    if (await dir.exists()) await dir.delete(recursive: true);
  }

  Future<bool> projectExists(String name) async {
    final base = await _baseDir;
    return Directory('${base.path}/$name').existsSync();
  }

  // ─── Files ───────────────────────────────────────────────────────────────────

  Future<List<PlaygroundFile>> listFiles(String projectName) async {
    final dir = await projectDir(projectName);
    final entries = dir.listSync();
    final files = entries
        .whereType<File>()
        .map(PlaygroundFile.fromFile)
        .toList();
    files.sort((a, b) => _fileOrder(a.name).compareTo(_fileOrder(b.name)));
    return files;
  }

  Future<PlaygroundFile> readFile(String projectName, String fileName) async {
    final dir = await projectDir(projectName);
    final file = File('${dir.path}/$fileName');
    return PlaygroundFile.fromFile(file);
  }

  Future<void> saveFile(String projectName, PlaygroundFile pf) async {
    final dir = await projectDir(projectName);
    await _writeFile(dir, pf.name, pf.content);
  }

  Future<void> renameFile(String projectName, String oldName, String newName) async {
    final dir = await projectDir(projectName);
    final oldFile = File('${dir.path}/$oldName');
    if (await oldFile.exists()) {
      await oldFile.rename('${dir.path}/$newName');
    }
  }

  Future<void> deleteFile(String projectName, String fileName) async {
    final dir = await projectDir(projectName);
    final file = File('${dir.path}/$fileName');
    if (await file.exists()) await file.delete();
  }

  Future<void> createFile(String projectName, String fileName) async {
    final dir = await projectDir(projectName);
    await _writeFile(dir, fileName, _defaultContentFor(fileName));
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  Future<void> _writeFile(Directory dir, String name, String content) async {
    final file = File('${dir.path}/$name');
    await file.writeAsString(content);
  }

  int _fileOrder(String name) {
    if (name == 'index.html') return 0;
    if (name.endsWith('.html')) return 1;
    if (name.endsWith('.css')) return 2;
    if (name.endsWith('.js')) return 3;
    return 4;
  }

  String _defaultContentFor(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'html':
        return '<!DOCTYPE html>\n<html>\n<head>\n  <title>${name.replaceAll('.html', '')}</title>\n</head>\n<body>\n  \n</body>\n</html>';
      case 'css':
        return '/* $name */\n\n';
      case 'js':
        return '// $name\n\n';
      default:
        return '';
    }
  }

  // ─── Starter Templates ────────────────────────────────────────────────────────

  static const String _starterHtml = '''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>My Project</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>

  <div class="container">
    <h1>🚀 My Project</h1>
    <p>Edit the files and press <strong>Run</strong> to preview!</p>
    <button onclick="handleClick()">Click Me</button>
    <div id="output"></div>
  </div>

  <script src="main.js"></script>
</body>
</html>''';

  static const String _starterCss = '''/* style.css */

* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

body {
  font-family: 'Segoe UI', sans-serif;
  background: #0f172a;
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #f1f5f9;
}

.container {
  text-align: center;
  padding: 40px;
  background: #1e293b;
  border-radius: 20px;
  box-shadow: 0 20px 60px rgba(0,0,0,0.4);
  max-width: 480px;
  width: 90%;
}

h1 {
  font-size: 2rem;
  color: #818cf8;
  margin-bottom: 12px;
}

p {
  color: #94a3b8;
  margin-bottom: 24px;
  line-height: 1.6;
}

button {
  background: linear-gradient(135deg, #6366f1, #8b5cf6);
  color: white;
  border: none;
  padding: 14px 32px;
  border-radius: 12px;
  font-size: 16px;
  cursor: pointer;
  transition: transform 0.2s, box-shadow 0.2s;
}

button:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 24px rgba(99,102,241,0.4);
}

#output {
  margin-top: 20px;
  color: #34d399;
  font-weight: 600;
  min-height: 24px;
}''';

  static const String _starterJs = '''// main.js

console.log("Project initialized!");

let clickCount = 0;

function handleClick() {
  clickCount++;
  const output = document.getElementById("output");
  output.textContent = "Clicked " + clickCount + " time" + (clickCount === 1 ? "" : "s") + "! 🎉";
  console.log("Click #" + clickCount);
}''';
}
