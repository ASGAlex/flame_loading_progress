import 'dart:async';

import 'package:flame_message_stream/flame_message_stream.dart';
import 'package:meta/meta.dart';

/// Add this mixin to your Game class to enable functionality of progress
/// reporting. Use [reportLoadingProgress] function in [onLoad] to send progress
/// information to loading screen widget.
mixin HasLoadingProgress<M> on HasMessageProviders {
  MessageStreamProvider<M> get _streamProvider =>
      getMessageProvider<M>('loading_progress');

  final _completer = Completer<void>();

  /// Reports game loading progress to flutter widget, used for it
  void reportLoadingProgress(M message) => _streamProvider.sendMessage(message);

  @internal
  Future get gameMounted => _completer.future;

  Stream<M> get loadingProgressStream => _streamProvider.messagingStream;

  @override
  void onMount() {
    super.onMount();
    if (!_completer.isCompleted) {
      _completer.complete();
    }
  }

  @override
  void onDetach() {
    _streamProvider.dispose();
    super.onDetach();
  }
}
