import 'package:flame/game.dart';
import 'package:flame_loading_progress/flame_loading_progress.dart';
import 'package:flutter/cupertino.dart';

/// This is just proxy widget with same parameters as original [GameWidget] has.
/// It should be used instead original [GameWidget] to enable subscription
/// on game loading progress events.
class GameWidgetWrapper<T extends Game, M> extends StatefulWidget {
  const GameWidgetWrapper({
    super.key,
    required this.loadingWidgetBuilder,
    required T this.game,
    this.textDirection,
    this.loadingBuilder,
    this.errorBuilder,
    this.backgroundBuilder,
    this.overlayBuilderMap,
    this.initialActiveOverlays,
    this.focusNode,
    this.autofocus = true,
    this.mouseCursor,
  }) : gameFactory = null;

  const GameWidgetWrapper.controlled({
    super.key,
    required GameFactory<T> this.gameFactory,
    required this.loadingWidgetBuilder,
    this.textDirection,
    this.loadingBuilder,
    this.errorBuilder,
    this.backgroundBuilder,
    this.overlayBuilderMap,
    this.initialActiveOverlays,
    this.focusNode,
    this.autofocus = true,
    this.mouseCursor,
  }) : game = null;

  final T? game;
  final GameFactory<T>? gameFactory;
  final TextDirection? textDirection;
  final GameLoadingWidgetBuilder? loadingBuilder;
  final GameErrorWidgetBuilder? errorBuilder;
  final WidgetBuilder? backgroundBuilder;
  final Map<String, OverlayWidgetBuilder<T>>? overlayBuilderMap;
  final FocusNode? focusNode;
  final bool autofocus;
  final MouseCursor? mouseCursor;
  final List<String>? initialActiveOverlays;
  final LoadingWidgetBuilder<M> loadingWidgetBuilder;

  @override
  State<StatefulWidget> createState() => _GameWidgetWrapperState<T, M>();
}

class _GameWidgetWrapperState<T extends Game, M>
    extends State<GameWidgetWrapper<T, M>> {
  final _gameWidgetKey = GlobalKey();
  late T currentGame;
  late LoadingWidgetBuilder<M> loadingWidgetBuilder;

  @override
  void initState() {
    loadingWidgetBuilder = widget.loadingWidgetBuilder;
    initCurrentGame();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (currentGame is! HasLoadingProgress) {
      return _buildGameWidget();
    }
    final game = currentGame as HasLoadingProgress;

    loadingWidgetBuilder.errorBuilder = widget.errorBuilder;

    return FutureBuilder<void>(
      future: game.gameMounted,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return loadingWidgetBuilder.buildTransitionToGame(
            context,
            _buildGameWidget(),
          );
        } else {
          return Stack(
            children: [
              _buildGameWidget(),
              StreamBuilder<M>(
                builder: loadingWidgetBuilder.buildOnStreamData,
                stream: game.loadingProgressStream as Stream<M>,
              ),
            ],
          );
        }
      },
    );
  }

  GameWidget<T> _buildGameWidget() => GameWidget(
        key: _gameWidgetKey,
        game: currentGame,
        autofocus: widget.autofocus,
        backgroundBuilder: widget.backgroundBuilder,
        errorBuilder: widget.errorBuilder,
        focusNode: widget.focusNode,
        initialActiveOverlays: widget.initialActiveOverlays,
        loadingBuilder: widget.loadingBuilder,
        mouseCursor: widget.mouseCursor,
        overlayBuilderMap: widget.overlayBuilderMap,
        textDirection: widget.textDirection,
      );

  @override
  void didUpdateWidget(covariant GameWidgetWrapper<T, M> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.game != widget.game) {
      initCurrentGame();
    }
  }

  void initCurrentGame() {
    if (widget.game == null) {
      currentGame = widget.gameFactory!.call();
    } else {
      currentGame = widget.game!;
    }
  }
}
