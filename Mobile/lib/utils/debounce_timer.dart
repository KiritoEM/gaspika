import 'dart:async';

typedef Debounceable<S, T> = Future<S?> Function(T parameter);

class DebounceUtils {
  static Debounceable<S, T> debounce<S, T>(
    Debounceable<S?, T> function,
    Duration duration,
  ) {
    DebounceTimer? debounceTimer;

    return (T parameter) async {
      if (debounceTimer != null && !debounceTimer!.isCompleted) {
        debounceTimer!.cancel();
      }

      debounceTimer = DebounceTimer(debounceDuration: duration);

      try {
        await debounceTimer!.future;
      } on _CancelException {
        return null;
      }

      return function(parameter);
    };
  }
}

class DebounceTimer {
  final Duration debounceDuration;

  DebounceTimer({required this.debounceDuration}) {
    _timer = Timer(debounceDuration, _onComplete);
  }

  late final Timer _timer;
  final Completer<void> _completer = Completer<void>();

  void _onComplete() {
    _completer.complete();
  }

  Future<void> get future => _completer.future;

  bool get isCompleted => _completer.isCompleted;

  void cancel() {
    _timer.cancel();
    _completer.completeError(const _CancelException());
  }
}

class _CancelException implements Exception {
  const _CancelException();
}
