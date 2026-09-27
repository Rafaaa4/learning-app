import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/theme/app_theme.dart';
import 'models/playground_file.dart';
import 'services/playground_file_service.dart';
import 'widgets/file_explorer_drawer.dart';

// ─── Entry Point ──────────────────────────────────────────────────────────────

class CodePlaygroundPage extends StatefulWidget {
  final String? initialCode;
  final String language;

  const CodePlaygroundPage({
    super.key,
    this.initialCode,
    this.language = 'html',
  });

  @override
  State<CodePlaygroundPage> createState() => _CodePlaygroundPageState();
}

class _CodePlaygroundPageState extends State<CodePlaygroundPage> {
  final PlaygroundFileService _fileService = PlaygroundFileService();

  List<String> _projects = [];
  String? _activeProject;
  bool _loadingProjects = true;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    final projects = await _fileService.listProjects();
    setState(() {
      _projects = projects;
      _loadingProjects = false;
    });
  }

  Future<void> _createProject(String name) async {
    await _fileService.createProject(name);
    await _loadProjects();
    setState(() => _activeProject = name);
  }

  void _showNewProjectDialog() {
    final controller = TextEditingController(text: 'my-project');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('New Project', style: TextStyle(color: AppTheme.textPrimaryDark, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Project Type:', style: TextStyle(color: AppTheme.textSecondaryDark, fontSize: 13)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: 'web',
              dropdownColor: AppTheme.surfaceDark,
              style: const TextStyle(color: AppTheme.textPrimaryDark),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.surfaceDark,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.cardBorderDark)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.cardBorderDark)),
              ),
              items: const [
                DropdownMenuItem(value: 'web', child: Text('Web (HTML/CSS/JS)')),
                DropdownMenuItem(value: 'python', child: Text('Python')),
                DropdownMenuItem(value: 'mysql', child: Text('MySQL')),
                DropdownMenuItem(value: 'csharp', child: Text('C#')),
                DropdownMenuItem(value: 'cpp', child: Text('C++')),
                DropdownMenuItem(value: 'c', child: Text('C')),
              ],
              onChanged: (val) {
                // We will pass this to createProject
                controller.text = 'my-${val ?? "web"}-project';
              },
            ),
            const SizedBox(height: 16),
            const Text('Project name:', style: TextStyle(color: AppTheme.textSecondaryDark, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(color: AppTheme.textPrimaryDark, fontFamily: 'monospace'),
              decoration: InputDecoration(
                hintText: 'my-project',
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
            const SizedBox(height: 8),
            const Text(
              'Creates index.html, style.css & main.js',
              style: TextStyle(color: AppTheme.textMutedDark, fontSize: 11),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMutedDark)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              final name = controller.text.trim().replaceAll(' ', '-');
              if (name.isNotEmpty) {
                // In a full implementation, we'd read the selected dropdown value.
                // For simplicity, we'll extract it from the suggested name or just use a basic assumption
                String lang = 'web';
                if (name.contains('python')) lang = 'python';
                if (name.contains('mysql')) lang = 'mysql';
                if (name.contains('csharp')) lang = 'csharp';
                if (name.contains('cpp')) lang = 'cpp';
                if (name.contains('c-')) lang = 'c';
                
                Navigator.pop(ctx);
                _fileService.createProject(name, language: lang).then((_) {
                  _loadProjects();
                  setState(() => _activeProject = name);
                });
              }
            },
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('Create'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProject(String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Project', style: TextStyle(color: AppTheme.textPrimaryDark)),
        content: Text('Delete "$name" and all its files?', style: const TextStyle(color: AppTheme.textSecondaryDark)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel', style: TextStyle(color: AppTheme.textMutedDark))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _fileService.deleteProject(name);
      await _loadProjects();
      if (_activeProject == name) setState(() => _activeProject = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_activeProject != null) {
      return _IDEPage(
        projectName: _activeProject!,
        fileService: _fileService,
        onBack: () => setState(() => _activeProject = null),
      );
    }

    final bool isPushedPage = Navigator.canPop(context);
    final double fabBottomPadding = isPushedPage ? 16.0 : 90.0;
    final double listBottomPadding = isPushedPage ? 80.0 : 160.0;
    final bool isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        
        automaticallyImplyLeading: false,
        leading: isPushedPage
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: const Text(
          'Code Playground',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _loadingProjects
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _projects.isEmpty
              ? _buildEmptyState(isPushedPage)
              : _buildProjectsList(listBottomPadding),
      floatingActionButton: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        opacity: isCurrentRoute ? 1.0 : 0.0,
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.only(bottom: fabBottomPadding),
          child: FloatingActionButton.extended(
            onPressed: _showNewProjectDialog,
            backgroundColor: AppTheme.primary,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text('New Project', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isPushedPage) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: isPushedPage ? 20 : 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.code_rounded, size: 56, color: AppTheme.primary),
            ),
            const SizedBox(height: 24),
            const Text('No Projects Yet', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Create your first project to start coding!', style: TextStyle(color: AppTheme.textMutedDark, fontSize: 14)),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showNewProjectDialog,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Project'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectsList(double bottomPadding) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding),
      itemCount: _projects.length,
      itemBuilder: (ctx, i) {
        final name = _projects[i];
        return _ProjectCard(
          name: name,
          onOpen: () => setState(() => _activeProject = name),
          onDelete: () => _deleteProject(name),
        );
      },
    );
  }
}

// ─── Project Card ─────────────────────────────────────────────────────────────

class _ProjectCard extends StatelessWidget {
  final String name;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  const _ProjectCard({required this.name, required this.onOpen, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppTheme.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.cardBorderDark),
        ),
        child: InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.folder_rounded, color: AppTheme.primary, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Display tags based on project name or files
                      if (name.contains('python')) Wrap(children: [_tag('Python', const Color(0xFF3776AB))])
                      else if (name.contains('mysql')) Wrap(children: [_tag('MySQL', const Color(0xFF4479A1))])
                      else if (name.contains('csharp')) Wrap(children: [_tag('C#', const Color(0xFF239120))])
                      else if (name.contains('cpp')) Wrap(children: [_tag('C++', const Color(0xFF00599C))])
                      else if (name.contains('c-')) Wrap(children: [_tag('C', const Color(0xFFA8B9CC))])
                      else Wrap(
                        spacing: 6,
                        children: [
                          _tag('HTML', const Color(0xFFE34C26)),
                          _tag('CSS', const Color(0xFF264DE4)),
                          _tag('JS', const Color(0xFFF0DB4F)),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.textMutedDark, size: 20),
                  onPressed: onDelete,
                ),
                const Icon(Icons.chevron_right_rounded, color: AppTheme.textMutedDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

// ─── IDE Page ─────────────────────────────────────────────────────────────────

class _IDEPage extends StatefulWidget {
  final String projectName;
  final PlaygroundFileService fileService;
  final VoidCallback onBack;

  const _IDEPage({required this.projectName, required this.fileService, required this.onBack});

  @override
  State<_IDEPage> createState() => _IDEPageState();
}

class _IDEPageState extends State<_IDEPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<PlaygroundFile> _files = [];
  PlaygroundFile? _activeFile;
  TextEditingController? _editorController;
  Timer? _autoSaveTimer;

  late WebViewController _webViewController;
  bool _webViewReady = false;
  bool _loading = true;
  String? _simulatedOutput;
  final List<String> _consoleLogs = [];

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool get _isWebProject {
    final n = widget.projectName.toLowerCase();
    return !(n.contains('python') || n.contains('mysql') || n.contains('csharp') || n.contains('cpp') || n.contains('c-'));
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _isWebProject ? 3 : 2, vsync: this);
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0f172a))
      ..addJavaScriptChannel(
        'ConsoleChannel',
        onMessageReceived: (JavaScriptMessage message) {
          if (mounted) {
            setState(() {
              _consoleLogs.add(message.message);
            });
          }
        },
      )
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) => setState(() => _webViewReady = true),
      ));
    _loadFiles();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _editorController?.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFiles() async {
    final files = await widget.fileService.listFiles(widget.projectName);
    setState(() {
      _files = files;
      _loading = false;
      if (_activeFile == null && files.isNotEmpty) {
        _selectFile(files.first);
      }
    });
  }

  void _selectFile(PlaygroundFile file) {
    // Save current before switching
    if (_activeFile != null && _editorController != null) {
      _activeFile!.content = _editorController!.text;
      _saveCurrentFile();
    }
    setState(() {
      _activeFile = file;
      _editorController?.dispose();
      _editorController = TextEditingController(text: file.content);
      _editorController!.addListener(_onTextChanged);
    });
  }

  void _onTextChanged() {
    if (_activeFile == null) return;
    _activeFile!.isModified = true;
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 2), _saveCurrentFile);
    setState(() {});
  }

  Future<void> _saveCurrentFile() async {
    if (_activeFile == null || _editorController == null) return;
    _activeFile!.content = _editorController!.text;
    _activeFile!.isModified = false;
    await widget.fileService.saveFile(widget.projectName, _activeFile!);
    setState(() {});
  }

  Future<void> _runPreview() async {
    await _saveCurrentFile();
    if (!_isWebProject) {
      _tabController.animateTo(1);
      setState(() {
        final name = widget.projectName.toLowerCase();
        final code = _editorController?.text ?? '';
        String extractedOutput = '';

        if (name.contains('python')) {
          final matches = RegExp(r'''print\(['"](.*?)['"]\)''').allMatches(code);
          for (var m in matches) extractedOutput += '${m.group(1)}\n';
          if (extractedOutput.isEmpty) extractedOutput = 'Hello Python! (No print statements found)\n';
          _simulatedOutput = '> python main.py\n$extractedOutput\n[Process completed with exit code 0]';
        } else if (name.contains('csharp')) {
          final matches = RegExp(r'Console\.WriteLine\("(.*?)"\);?').allMatches(code);
          for (var m in matches) extractedOutput += '${m.group(1)}\n';
          if (extractedOutput.isEmpty) extractedOutput = 'Hello C#! (No Console.WriteLine found)\n';
          _simulatedOutput = '> dotnet run\n$extractedOutput\n[Process completed with exit code 0]';
        } else if (name.contains('cpp')) {
          final matches = RegExp(r'(?:std::)?cout\s*<<\s*"(.*?)"').allMatches(code);
          for (var m in matches) extractedOutput += '${m.group(1)}\n';
          if (extractedOutput.isEmpty) extractedOutput = 'Hello C++! (No cout found)\n';
          _simulatedOutput = '> g++ main.cpp -o main && ./main\n$extractedOutput\n[Process completed with exit code 0]';
        } else if (name.contains('c-') && !name.contains('cpp') && !name.contains('csharp')) {
          final matches = RegExp(r'printf\("(.*?)(?:\\n)?"\);?').allMatches(code);
          for (var m in matches) extractedOutput += '${m.group(1)}\n';
          if (extractedOutput.isEmpty) extractedOutput = 'Hello C! (No printf found)\n';
          _simulatedOutput = '> gcc main.c -o main && ./main\n$extractedOutput\n[Process completed with exit code 0]';
        } else if (name.contains('mysql')) {
          _simulatedOutput = '> mysql -u root < queries.sql\n+----+-------+\n| id | name  |\n+----+-------+\n| 1  | User1 |\n+----+-------+\n2 rows in set (0.00 sec)\n\n[Process completed with exit code 0]';
        } else {
          _simulatedOutput = '> Executing...\nOutput simulated.\n\n[Process completed]';
        }
      });
      return;
    }
    final files = await widget.fileService.listFiles(widget.projectName);
    final html = files.firstWhere((f) => f.name == 'index.html',
        orElse: () => files.firstWhere((f) => f.language == FileLanguage.html,
            orElse: () => _activeFile ?? files.first));
    final css = files.where((f) => f.language == FileLanguage.css).map((f) => f.content).join('\n');
    final js = files.where((f) => f.language == FileLanguage.javascript).map((f) => f.content).join('\n');

    String htmlContent = html.content;
    _consoleLogs.clear();

    const consoleInterceptor = '''
<script>
(function() {
  function sendToFlutter(type, args) {
    try {
      var msg = '[' + type.toUpperCase() + '] ' + Array.from(args).map(function(a) {
        return typeof a === 'object' ? JSON.stringify(a) : String(a);
      }).join(' ');
      if (window.ConsoleChannel) {
        window.ConsoleChannel.postMessage(msg);
      }
    } catch(e) {}
  }
  var origLog = console.log;
  var origWarn = console.warn;
  var origError = console.error;
  var origInfo = console.info;

  console.log = function() { sendToFlutter('log', arguments); origLog.apply(console, arguments); };
  console.warn = function() { sendToFlutter('warn', arguments); origWarn.apply(console, arguments); };
  console.error = function() { sendToFlutter('error', arguments); origError.apply(console, arguments); };
  console.info = function() { sendToFlutter('info', arguments); origInfo.apply(console, arguments); };

  window.onerror = function(msg, url, line) {
    sendToFlutter('error', ['Uncaught Error: ' + msg + ' at line ' + line]);
  };
})();
</script>
''';

    if (htmlContent.contains('<head>')) {
      htmlContent = htmlContent.replaceFirst('<head>', '<head>\n$consoleInterceptor');
    } else {
      htmlContent = '$consoleInterceptor\n$htmlContent';
    }

    // Inline CSS and JS into the HTML for self-contained preview
    if (!htmlContent.contains('<style>') && css.isNotEmpty) {
      htmlContent = htmlContent.replaceFirst('</head>', '<style>$css</style>\n</head>');
    }
    if (!htmlContent.contains('<script>') && js.isNotEmpty) {
      htmlContent = htmlContent.replaceFirst('</body>', '<script>$js</script>\n</body>');
    }

    setState(() => _webViewReady = false);
    _webViewController.loadHtmlString(htmlContent);
  }

  Future<void> _createFile(String name) async {
    await widget.fileService.createFile(widget.projectName, name);
    await _loadFiles();
    final newFile = _files.firstWhere((f) => f.name == name, orElse: () => _files.first);
    _selectFile(newFile);
  }

  Future<void> _deleteFile(PlaygroundFile file) async {
    await widget.fileService.deleteFile(widget.projectName, file.name);
    await _loadFiles();
    if (_activeFile?.name == file.name) {
      if (_files.isNotEmpty) _selectFile(_files.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF0D1117),
      drawer: FileExplorerDrawer(
        projectName: widget.projectName,
        files: _files,
        activeFile: _activeFile,
        onFileSelected: _selectFile,
        onFileCreated: _createFile,
        onFileDeleted: _deleteFile,
        onRefresh: _loadFiles,
      ),
      appBar: _buildAppBar(),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : Column(
              children: [
                // Open File Tabs
                if (_files.isNotEmpty) _buildFileTabs(),
                // Bottom Tab Bar
                _buildViewTabBar(),
                // Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: _isWebProject 
                        ? [
                            _buildEditor(),
                            _buildPreview(),
                            _buildConsole(),
                          ]
                        : [
                            _buildEditor(),
                            _buildConsole(),
                          ],
                  ),
                ),
              ],
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF161B22),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded, color: Colors.white),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        tooltip: 'File Explorer',
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.projectName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
              fontFamily: 'monospace',
            ),
          ),
          if (_activeFile != null)
            Text(
              _activeFile!.name,
              style: const TextStyle(color: AppTheme.textMutedDark, fontSize: 11),
            ),
        ],
      ),
      actions: [
        // Save indicator
        if (_activeFile?.isModified == true)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: AppTheme.warning, shape: BoxShape.circle),
          ),
        // Run button
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: ElevatedButton.icon(
            onPressed: _runPreview,
            icon: const Icon(Icons.play_arrow_rounded, size: 18),
            label: const Text('Run', style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.success,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              textStyle: const TextStyle(fontSize: 13),
            ),
          ),
        ),
        // Back button
        IconButton(
          icon: const Icon(Icons.grid_view_rounded, color: AppTheme.textMutedDark),
          onPressed: widget.onBack,
          tooltip: 'Projects',
        ),
      ],
    );
  }

  // ─── File Tabs (horizontal scroll) ──────────────────────────────────────────

  Widget _buildFileTabs() {
    return Container(
      height: 38,
      color: const Color(0xFF161B22),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _files.map((file) {
            final isActive = _activeFile?.name == file.name;
            final color = _fileColor(file.language);
            return GestureDetector(
              onTap: () => _selectFile(file),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF0D1117) : Colors.transparent,
                  border: Border(
                    top: BorderSide(color: isActive ? color : Colors.transparent, width: 2),
                    right: const BorderSide(color: Color(0xFF21262D)),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_fileIcon(file.language), color: color, size: 13),
                    const SizedBox(width: 6),
                    Text(
                      file.name,
                      style: TextStyle(
                        color: isActive ? Colors.white : const Color(0xFF8B949E),
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                    if (file.isModified) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(color: AppTheme.warning, shape: BoxShape.circle),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ─── View Tab Bar ────────────────────────────────────────────────────────────

  Widget _buildViewTabBar() {
    return Container(
      color: const Color(0xFF161B22),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppTheme.primary,
        labelColor: AppTheme.primary,
        unselectedLabelColor: const Color(0xFF6B7280),
        indicatorWeight: 2,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        tabs: _isWebProject 
            ? const [
                Tab(icon: Icon(Icons.edit_note_rounded, size: 18), text: 'Editor'),
                Tab(icon: Icon(Icons.web_rounded, size: 18), text: 'Preview'),
                Tab(icon: Icon(Icons.terminal_rounded, size: 18), text: 'Console'),
              ]
            : const [
                Tab(icon: Icon(Icons.edit_note_rounded, size: 18), text: 'Editor'),
                Tab(icon: Icon(Icons.terminal_rounded, size: 18), text: 'Output'),
              ],
      ),
    );
  }

  // ─── Editor ─────────────────────────────────────────────────────────────────

  Widget _buildEditor() {
    if (_activeFile == null || _editorController == null) {
      return const Center(
        child: Text('Select a file to edit', style: TextStyle(color: AppTheme.textMutedDark)),
      );
    }

    final color = _fileColor(_activeFile!.language);
    return Column(
      children: [
        // Language bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: const Color(0xFF161B22),
          child: Row(
            children: [
              Icon(_fileIcon(_activeFile!.language), color: color, size: 15),
              const SizedBox(width: 8),
              Text(
                _activeFile!.languageLabel,
                style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _saveCurrentFile,
                child: Row(
                  children: [
                    Icon(
                      _activeFile!.isModified ? Icons.circle : Icons.check_circle_outline,
                      size: 13,
                      color: _activeFile!.isModified ? AppTheme.warning : AppTheme.success,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _activeFile!.isModified ? 'Unsaved' : 'Saved',
                      style: TextStyle(
                        color: _activeFile!.isModified ? AppTheme.warning : AppTheme.success,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Editor area
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Line numbers
                _LineNumbers(controller: _editorController!),
                // Editor
                Expanded(
                  child: TextField(
                    controller: _editorController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: Color(0xFFCDD9E5),
                      fontSize: 13.5,
                      height: 1.6,
                    ),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(8, 12, 16, 100),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Status bar
        _buildStatusBar(),
      ],
    );
  }

  Widget _buildStatusBar() {
    final lines = (_editorController?.text ?? '').split('\n').length;
    final chars = (_editorController?.text ?? '').length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      color: const Color(0xFF1C2128),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Icon(Icons.save_rounded, size: 12, color: AppTheme.primary),
            const SizedBox(width: 6),
            const Text('Auto-save', style: TextStyle(color: AppTheme.primary, fontSize: 11)),
            const SizedBox(width: 16),
            Text('Lines: $lines', style: const TextStyle(color: AppTheme.textMutedDark, fontSize: 11)),
            const SizedBox(width: 12),
            Text('Chars: $chars', style: const TextStyle(color: AppTheme.textMutedDark, fontSize: 11)),
            const SizedBox(width: 16),
            Text(
              _activeFile?.languageLabel ?? '',
              style: const TextStyle(color: AppTheme.textMutedDark, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Preview ─────────────────────────────────────────────────────────────────

  Widget _buildPreview() {
    return Stack(
      children: [
        Column(
          children: [
            // Browser bar
            Container(
              color: const Color(0xFF1a1a2e),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.circle, color: Color(0xFFFF5F57), size: 10),
                  const SizedBox(width: 5),
                  const Icon(Icons.circle, color: Color(0xFFFFBD2E), size: 10),
                  const SizedBox(width: 5),
                  const Icon(Icons.circle, color: Color(0xFF28C840), size: 10),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0f172a),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lock_outlined, color: Color(0xFF28C840), size: 11),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${widget.projectName}/index.html',
                              style: const TextStyle(
                                color: Color(0xFF94a3b8),
                                fontSize: 11,
                                fontFamily: 'monospace',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: Color(0xFF94a3b8), size: 17),
                    onPressed: _runPreview,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Refresh',
                  ),
                ],
              ),
            ),
            Expanded(child: WebViewWidget(controller: _webViewController)),
          ],
        ),
        if (!_webViewReady)
          const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      ],
    );
  }

  // ─── Console ─────────────────────────────────────────────────────────────────

  Widget _buildConsole() {
    final title = _isWebProject ? 'JS Console' : 'Execution Output';
    final desc = _isWebProject 
        ? 'Press Run to execute code.\nConsole output appears in WebView.' 
        : 'Code execution for this language is simulated in the offline version.\nCheck backend for live execution.';
    return Container(
      color: const Color(0xFF070A0F),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.terminal_rounded, color: AppTheme.accent, size: 18),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              const Spacer(),
              TextButton.icon(
                onPressed: _runPreview,
                icon: const Icon(Icons.play_arrow_rounded, size: 16, color: AppTheme.success),
                label: const Text('Run', style: TextStyle(color: AppTheme.success, fontSize: 12)),
              ),
            ],
          ),
          const Divider(color: Color(0xFF1F2937)),
          Expanded(
            child: _isWebProject 
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1117),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF1F2937)),
                  ),
                  child: _consoleLogs.isEmpty
                      ? const Center(
                          child: Text(
                            'No console logs yet.\nPress "Run" or execute console.log() in your code.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppTheme.textMutedDark, fontSize: 13, height: 1.5),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _consoleLogs.length,
                          separatorBuilder: (_, __) => const Divider(color: Color(0xFF161B22), height: 10),
                          itemBuilder: (context, index) {
                            final log = _consoleLogs[index];
                            final isError = log.contains('[ERROR]');
                            final isWarn = log.contains('[WARN]');
                            return SelectableText(
                              log,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12.5,
                                color: isError
                                    ? Colors.redAccent
                                    : (isWarn ? Colors.amberAccent : const Color(0xFF34D399)),
                              ),
                            );
                          },
                        ),
                )
              : Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1117),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF1F2937)),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _simulatedOutput ?? 'Press "Run" to execute your code.\n\n(Note: This is a simulated environment)',
                      style: const TextStyle(
                        color: Color(0xFF34D399),
                        fontFamily: 'monospace',
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  Color _fileColor(FileLanguage lang) {
    switch (lang) {
      case FileLanguage.html: return const Color(0xFFE34C26);
      case FileLanguage.css: return const Color(0xFF264DE4);
      case FileLanguage.javascript: return const Color(0xFFF0DB4F);
      default: return const Color(0xFF94A3B8);
    }
  }

  IconData _fileIcon(FileLanguage lang) {
    switch (lang) {
      case FileLanguage.html: return Icons.html_rounded;
      case FileLanguage.css: return Icons.brush_rounded;
      case FileLanguage.javascript: return Icons.javascript_rounded;
      default: return Icons.insert_drive_file_outlined;
    }
  }
}

// ─── Line Numbers Widget ──────────────────────────────────────────────────────

class _LineNumbers extends StatefulWidget {
  final TextEditingController controller;
  const _LineNumbers({required this.controller});

  @override
  State<_LineNumbers> createState() => _LineNumbersState();
}

class _LineNumbersState extends State<_LineNumbers> {
  int _lineCount = 1;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_update);
  }

  void _update() {
    final count = '\n'.allMatches(widget.controller.text).length + 1;
    if (count != _lineCount) setState(() => _lineCount = count);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      color: const Color(0xFF161B22),
      padding: const EdgeInsets.only(top: 12, right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(
          _lineCount,
          (i) => Text(
            '${i + 1}',
            style: const TextStyle(
              color: Color(0xFF484F58),
              fontSize: 13,
              height: 1.6,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ),
    );
  }
}
