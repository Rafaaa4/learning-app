import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/playground_file.dart';
import '../../../core/constants/supabase_constants.dart';

class PlaygroundFileService {
  static final PlaygroundFileService _instance = PlaygroundFileService._internal();
  factory PlaygroundFileService() => _instance;
  PlaygroundFileService._internal();

  String get _userId {
    final u = supabase.auth.currentUser;
    if (u == null) throw Exception('Network error: You must be logged in to manage projects.');
    return u.id;
  }

  // ─── Projects ───────────────────────────────────────────────────────────────

  Future<List<String>> listProjects() async {
    try {
      final res = await supabase
          .from('playground_projects')
          .select('name')
          .eq('user_id', _userId)
          .order('name', ascending: true);
      
      return (res as List).map((row) => row['name'].toString()).toList();
    } catch (e) {
      debugPrint('Network error listing projects: $e');
      throw Exception('Network error: Could not load projects.');
    }
  }

  Future<void> createProject(String name, {String language = 'web'}) async {
    try {
      // Check if exists
      final existing = await supabase
          .from('playground_projects')
          .select('id')
          .eq('user_id', _userId)
          .eq('name', name)
          .maybeSingle();

      if (existing != null) {
        throw Exception('Project already exists');
      }

      List<Map<String, String>> initialFiles = [];

      if (language == 'python') {
        initialFiles.add({'name': 'main.py', 'content': 'print("Hello Python!")\n'});
      } else if (language == 'mysql') {
        initialFiles.add({'name': 'queries.sql', 'content': 'SELECT * FROM users;\n'});
      } else if (language == 'csharp') {
        initialFiles.add({'name': 'Program.cs', 'content': 'using System;\n\nclass Program {\n  static void Main() {\n    Console.WriteLine("Hello C#!");\n  }\n}\n'});
      } else if (language == 'cpp') {
        initialFiles.add({'name': 'main.cpp', 'content': '#include <iostream>\n\nint main() {\n  std::cout << "Hello C++!" << std::endl;\n  return 0;\n}\n'});
      } else if (language == 'c') {
        initialFiles.add({'name': 'main.c', 'content': '#include <stdio.h>\n\nint main() {\n  printf("Hello C!\\n");\n  return 0;\n}\n'});
      } else {
        initialFiles.add({'name': 'index.html', 'content': _starterHtml});
        initialFiles.add({'name': 'style.css', 'content': _starterCss});
        initialFiles.add({'name': 'main.js', 'content': _starterJs});
      }

      await supabase.from('playground_projects').insert({
        'user_id': _userId,
        'name': name,
        'language': language,
        'files': initialFiles,
      });
    } catch (e) {
      debugPrint('Network error creating project: $e');
      throw Exception('Network error: Could not create project.');
    }
  }

  Future<void> deleteProject(String name) async {
    try {
      await supabase
          .from('playground_projects')
          .delete()
          .eq('user_id', _userId)
          .eq('name', name);
    } catch (e) {
      throw Exception('Network error: Could not delete project.');
    }
  }

  Future<bool> projectExists(String name) async {
    try {
      final res = await supabase
          .from('playground_projects')
          .select('id')
          .eq('user_id', _userId)
          .eq('name', name)
          .maybeSingle();
      return res != null;
    } catch (e) {
      return false;
    }
  }

  // ─── Files ───────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> _getProject(String projectName) async {
    final res = await supabase
        .from('playground_projects')
        .select()
        .eq('user_id', _userId)
        .eq('name', projectName)
        .maybeSingle();
    
    if (res == null) throw Exception('Project not found');
    return res;
  }

  Future<List<PlaygroundFile>> listFiles(String projectName) async {
    try {
      final project = await _getProject(projectName);
      final List filesData = project['files'] ?? [];
      
      final files = filesData.map((f) => PlaygroundFile(
        name: f['name'],
        content: f['content'],
      )).toList();

      files.sort((a, b) => _fileOrder(a.name).compareTo(_fileOrder(b.name)));
      return files;
    } catch (e) {
      throw Exception('Network error: Could not load files.');
    }
  }

  Future<PlaygroundFile> readFile(String projectName, String fileName) async {
    final files = await listFiles(projectName);
    try {
      return files.firstWhere((f) => f.name == fileName);
    } catch (_) {
      throw Exception('File not found');
    }
  }

  Future<void> saveFile(String projectName, PlaygroundFile pf) async {
    try {
      final project = await _getProject(projectName);
      List filesData = List.from(project['files'] ?? []);
      
      final fileIndex = filesData.indexWhere((f) => f['name'] == pf.name);
      if (fileIndex >= 0) {
        filesData[fileIndex]['content'] = pf.content;
      } else {
        filesData.add({'name': pf.name, 'content': pf.content});
      }

      await supabase.from('playground_projects').update({
        'files': filesData,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', project['id']);
    } catch (e) {
      throw Exception('Network error: Could not save file.');
    }
  }

  Future<void> renameFile(String projectName, String oldName, String newName) async {
    try {
      final project = await _getProject(projectName);
      List filesData = List.from(project['files'] ?? []);
      
      final fileIndex = filesData.indexWhere((f) => f['name'] == oldName);
      if (fileIndex >= 0) {
        filesData[fileIndex]['name'] = newName;
        await supabase.from('playground_projects').update({
          'files': filesData,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', project['id']);
      }
    } catch (e) {
      throw Exception('Network error: Could not rename file.');
    }
  }

  Future<void> deleteFile(String projectName, String fileName) async {
    try {
      final project = await _getProject(projectName);
      List filesData = List.from(project['files'] ?? []);
      
      filesData.removeWhere((f) => f['name'] == fileName);
      
      await supabase.from('playground_projects').update({
        'files': filesData,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', project['id']);
    } catch (e) {
      throw Exception('Network error: Could not delete file.');
    }
  }

  Future<void> createFile(String projectName, String fileName) async {
    try {
      final project = await _getProject(projectName);
      List filesData = List.from(project['files'] ?? []);
      
      if (filesData.any((f) => f['name'] == fileName)) {
        throw Exception('File already exists');
      }
      
      filesData.add({'name': fileName, 'content': _defaultContentFor(fileName)});
      
      await supabase.from('playground_projects').update({
        'files': filesData,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', project['id']);
    } catch (e) {
      throw Exception('Network error: Could not create file.');
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

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
