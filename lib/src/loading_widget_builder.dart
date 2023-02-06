import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';

/// Base class to encapsulate builder functions and required variables.
/// You should create your own subclass of this class and implement
/// three functions with user-defined logic:
/// - [buildOnMessage] - this function is responsible on building loading screen
///   using data from received progress message
/// - [buildTransitionToGame] is responsible for rendering game widget,
///   optionally with a transition animation from loading screen.
abstract class LoadingWidgetBuilder<M> {
  late GameErrorWidgetBuilder? errorBuilder;

  /// Reimplement this if you want to process [snapshot] yourself.
  @mustCallSuper
  Widget buildOnStreamData(BuildContext context, AsyncSnapshot<M> snapshot) {
    if (snapshot.hasError) {
      if (errorBuilder == null) {
        throw Error.throwWithStackTrace(
          snapshot.error!,
          snapshot.stackTrace!,
        );
      } else {
        return errorBuilder!(context, snapshot.error!);
      }
    }

    if (snapshot.hasData) {
      return buildOnMessage(context, snapshot.data as M);
    }

    return Container();
  }

  /// This function is responsible on building loading screen using data from
  /// received progress message
  Widget buildOnMessage(BuildContext context, M message);

  /// Function is responsible for rendering game widget, optionally with a
  /// transition animation from loading screen.
  Widget buildTransitionToGame(BuildContext context, GameWidget gameWidget);
}
