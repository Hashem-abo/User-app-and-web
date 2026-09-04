import 'dart:async';

/// Exception thrown when an operation is cancelled via [CancellationToken].
class CancellationException implements Exception {
  final String message;
  CancellationException([this.message = 'Operation was cancelled.']);

  @override
  String toString() => 'CancellationException: $message';
}

/// A lightweight, production-grade token used to abort in-flight asynchronous operations,
/// close HTTP client sockets, and invalidate stale tab/module requests.
class CancellationToken {
  bool _isCancelled = false;
  String? _cancelReason;
  final List<void Function()> _listeners = [];

  bool get isCancelled => _isCancelled;
  String? get cancelReason => _cancelReason;

  /// Cancels the operation, notifying all registered listeners (e.g., closing underlying HTTP sockets).
  void cancel({String? reason}) {
    if (_isCancelled) return;
    _isCancelled = true;
    _cancelReason = reason ?? 'Operation was cancelled.';

    final listenersCopy = List<void Function()>.from(_listeners);
    for (final listener in listenersCopy) {
      try {
        listener();
      } catch (_) {
        // Suppress listener errors to ensure all cancellation handlers execute
      }
    }
    _listeners.clear();
  }

  /// Registers a callback to be invoked immediately if already cancelled, or upon cancellation.
  void onCancel(void Function() listener) {
    if (_isCancelled) {
      try {
        listener();
      } catch (_) {}
    } else {
      _listeners.add(listener);
    }
  }

  /// Throws a [CancellationException] if this token has been cancelled.
  void throwIfCancelled() {
    if (_isCancelled) {
      throw CancellationException(_cancelReason ?? 'Operation was cancelled.');
    }
  }
}
