
class ExecutionResult {
  final String htmlDocument;
  final List<String> logs;
  final List<String> errors;

  ExecutionResult({
    required this.htmlDocument,
    this.logs = const [],
    this.errors = const [],
  });
}

class ExecutionService {
  static final ExecutionService _instance = ExecutionService._internal();
  factory ExecutionService() => _instance;
  ExecutionService._internal();

  /// Build complete self-contained HTML document with embedded console interceptor
  String buildExecutableHtml({
    required String htmlCode,
    String cssCode = '',
    String jsCode = '',
  }) {
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
      margin: 16px;
      color: #1e293b;
      background-color: #ffffff;
      line-height: 1.5;
    }
    $cssCode
  </style>
</head>
<body>
  $htmlCode

  <script>
    // Console log interceptor
    (function() {
      const originalLog = console.log;
      const originalError = console.error;
      const originalWarn = console.warn;

      function sendToFlutter(type, args) {
        try {
          const message = Array.from(args).map(a => typeof a === 'object' ? JSON.stringify(a) : String(a)).join(' ');
          if (window.FlutterBridge) {
            window.FlutterBridge.postMessage(JSON.stringify({ type: type, message: message }));
          }
        } catch(e) {}
      }

      console.log = function(...args) {
        sendToFlutter('log', args);
        originalLog.apply(console, args);
      };
      console.error = function(...args) {
        sendToFlutter('error', args);
        originalError.apply(console, args);
      };
      console.warn = function(...args) {
        sendToFlutter('warn', args);
        originalWarn.apply(console, args);
      };
    })();

    try {
      $jsCode
    } catch(err) {
      console.error(err.message || String(err));
    }
  </script>
</body>
</html>
''';
  }

  /// Evaluates JS code in a simulated environment if running offline or on native desktop/mobile
  List<String> simulateJsConsoleLogs(String code) {
    final List<String> logs = [];

    // Capture console.log(...) statements directly
    final logRegex = RegExp(r'console\.log\((.*?)\);?', multiLine: true);
    final matches = logRegex.allMatches(code);

    for (final m in matches) {
      final expr = m.group(1)?.trim() ?? '';
      if (expr.isEmpty) continue;

      // Clean simple string literals
      if ((expr.startsWith('"') && expr.endsWith('"')) ||
          (expr.startsWith("'") && expr.endsWith("'")) ||
          (expr.startsWith('`') && expr.endsWith('`'))) {
        logs.add(expr.substring(1, expr.length - 1));
      } else if (int.tryParse(expr) != null || double.tryParse(expr) != null) {
        logs.add(expr);
      } else {
        // Try basic arithmetic or string concatenation (e.g. "Hello" + " World" or 2 + 2)
        final simpleSum = _evaluateSimpleExpression(expr);
        logs.add(simpleSum ?? expr);
      }
    }

    return logs;
  }

  String? _evaluateSimpleExpression(String expr) {
    try {
      // String concatenation e.g. "Hello" + " " + "World"
      if (expr.contains('+')) {
        final parts = expr.split('+').map((p) => p.trim()).toList();
        final buffer = StringBuffer();
        bool isString = false;
        for (final p in parts) {
          if ((p.startsWith('"') && p.endsWith('"')) ||
              (p.startsWith("'") && p.endsWith("'"))) {
            buffer.write(p.substring(1, p.length - 1));
            isString = true;
          }
        }
        if (isString) return buffer.toString();
      }
    } catch (_) {}
    return null;
  }
}
