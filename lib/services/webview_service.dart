import 'dart:convert';
import 'execution_service.dart';

class WebViewService {
  static final WebViewService _instance = WebViewService._internal();
  factory WebViewService() => _instance;
  WebViewService._internal();

  final ExecutionService _executionService = ExecutionService();

  /// Converts HTML content into an embeddable data URI (data:text/html;charset=utf-8,...)
  String createDataUri({
    required String htmlCode,
    String cssCode = '',
    String jsCode = '',
  }) {
    final fullDoc = _executionService.buildExecutableHtml(
      htmlCode: htmlCode,
      cssCode: cssCode,
      jsCode: jsCode,
    );
    return 'data:text/html;charset=utf-8,${Uri.encodeComponent(fullDoc)}';
  }

  /// Parses simulated console log events from postMessage payload
  Map<String, dynamic>? parseFlutterBridgeMessage(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {}
    return null;
  }
}
