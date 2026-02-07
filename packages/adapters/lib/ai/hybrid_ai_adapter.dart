import 'dart:async';
import 'package:ecomesh_core/ecomesh_core.dart';
import 'cloudflare_ai_adapter.dart';
import 'mock_ai_adapter.dart';

/// Hybrid AI Adapter - Uses local mock for offline, cloud when online
class HybridAIAdapter implements IAIPort {
  final CloudflareAIAdapter _cloudAdapter;
  final MockAIAdapter _localAdapter;
  bool _useCloud = true;
  int _consecutiveFailures = 0;
  static const int _failureThreshold = 3;

  HybridAIAdapter({
    required String cloudBaseUrl,
  })  : _cloudAdapter = CloudflareAIAdapter(baseUrl: cloudBaseUrl),
        _localAdapter = MockAIAdapter();

  @override
  Future<bool> isAvailable() async {
    // Try cloud first, fall back to local
    if (_useCloud) {
      final cloudAvailable = await _cloudAdapter.isAvailable();
      if (cloudAvailable) return true;
    }
    return _localAdapter.isAvailable();
  }

  @override
  Future<String> generateReply(MessageContext context) async {
    return _tryWithFallback(
      () => _cloudAdapter.generateReply(context),
      () => _localAdapter.generateReply(context),
    );
  }

  @override
  Future<String> summarize(List<String> messages) async {
    return _tryWithFallback(
      () => _cloudAdapter.summarize(messages),
      () => _localAdapter.summarize(messages),
    );
  }

  @override
  Future<String> translate(String text, String targetLang) async {
    return _tryWithFallback(
      () => _cloudAdapter.translate(text, targetLang),
      () => _localAdapter.translate(text, targetLang),
    );
  }

  @override
  Future<String> detectLanguage(String text) async {
    return _tryWithFallback(
      () => _cloudAdapter.detectLanguage(text),
      () => _localAdapter.detectLanguage(text),
    );
  }

  Future<String> _tryWithFallback(
    Future<String> Function() cloudOp,
    Future<String> Function() localOp,
  ) async {
    if (_useCloud && _consecutiveFailures < _failureThreshold) {
      try {
        final result = await cloudOp();
        _consecutiveFailures = 0;
        return result;
      } catch (e) {
        _consecutiveFailures++;
        if (_consecutiveFailures >= _failureThreshold) {
          _useCloud = false;
        }
        return localOp();
      }
    }
    return localOp();
  }

  // Force switch between cloud and local
  void preferCloud(bool useCloud) {
    _useCloud = useCloud;
    if (useCloud) {
      _consecutiveFailures = 0;
    }
  }
}
