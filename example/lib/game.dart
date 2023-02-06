import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame_loading_progress/flame_loading_progress.dart';
import 'package:flame_message_stream/flame_message_stream.dart';
import 'package:flutter/material.dart' hide Image, Draggable;

class LoadingScreenExample extends FlameGame
    with HasMessageProviders, HasLoadingProgress<ProgressMessage> {
  LoadingScreenExample();

  double anyProgressEmulation = 0;
  int messagesSent = 0;

  @override
  FutureOr<void> onLoad() async {
    /// the message will be send to loading screen, if the one is specified
    reportLoadingProgress(
      const ProgressMessage(text: 'onLoad started', progress: 10),
    );

    await Future<void>.delayed(const Duration(seconds: 3));

    reportLoadingProgress(
      const ProgressMessage(
        text: 'Something happen while loading...',
        progress: 50,
      ),
    );

    await Future<void>.delayed(const Duration(seconds: 5));

    reportLoadingProgress(
      const ProgressMessage(
        text: '...almost done!..',
        progress: 90,
      ),
    );

    final captionComponent =
        TextComponent(text: 'This is in-game text components')
          ..anchor = Anchor.topCenter
          ..x = size.x / 2
          ..y = 100;

    final path = Path();
    path.addOval(Rect.fromCircle(center: const Offset(0, 25), radius: 30));
    final effect = MoveAlongPathEffect(
      path,
      EffectController(duration: 5, infinite: true),
    );
    captionComponent.add(effect);

    add(captionComponent);

    /// These components will receive notifications during game loop.
    add(InGameProgressText(verticalPosition: 200, size: size));
    add(InGameProgressText(verticalPosition: 250, size: size));

    await Future<void>.delayed(const Duration(seconds: 5));

    reportLoadingProgress(
      const ProgressMessage(
        text: 'Finished! Be ready to play!',
        progress: 100,
      ),
    );

    await Future<void>.delayed(const Duration(seconds: 1));

    return super.onLoad();
  }

  /// This is just an example of sending messages to game components.
  @override
  void update(double dt) {
    anyProgressEmulation += dt;
    final probability = Random().nextInt(100);
    if (probability < 1) {
      messagesSent++;
      reportLoadingProgress(
        ProgressMessage(
          text: 'The notification message #$messagesSent',
          progress: (anyProgressEmulation * 100).toInt(),
        ),
      );
    }
    super.update(dt);
  }
}

/// A message strict type. You should to define an immutable message class for
/// exchanging between game and components. You also could to use just [String]
/// and even [dynamic], but the last option looks like heavy anti-pattern.
@immutable
class ProgressMessage {
  const ProgressMessage({required this.text, required this.progress});

  final String text;
  final int progress;
}

/// Class responsible to call widgets depending on received message
class ExampleBuilder extends LoadingWidgetBuilder<ProgressMessage> {
  /// A global key to let Flutter know, that [AnimatedSwitcher] is the same
  /// both in [buildOnMessage] and at [buildTransitionToGame]
  final _animatedSwitcherKey = GlobalKey();

  /// A key to make [AnimatedSwitcher] feel the difference between new and old
  /// widget
  final _loadingScreenKey = GlobalKey();

  @override
  Widget buildOnMessage(BuildContext context, ProgressMessage message) {
    return AnimatedSwitcher(
      key: _animatedSwitcherKey,
      duration: const Duration(seconds: 3),
      child: _buildLoadingScreen(message.text, message.progress),
    );
  }

  Widget _buildLoadingScreen(String message, int progress) =>
      LoadingScreenExampleWidget(
        key: _loadingScreenKey,
        text: message,
        progress: progress / 100,
      );

  @override
  Widget buildTransitionToGame(BuildContext context, GameWidget gameWidget) {
    return AnimatedSwitcher(
      key: _animatedSwitcherKey,
      duration: const Duration(seconds: 10),
      child: gameWidget,
    );
  }
}

/// The loading screen widget with animated progress bar anf fade effect
/// when displaying the game.
/// This is just ordinary Flutter widget without any special "relationships"
/// with Flame. You can use everything you want to be used as a "progress bar"
class LoadingScreenExampleWidget extends StatefulWidget {
  const LoadingScreenExampleWidget({
    super.key,
    required this.text,
    required this.progress,
  });

  final String text;
  final double progress;

  @override
  State<LoadingScreenExampleWidget> createState() =>
      _LoadingScreenExampleWidgetState();
}

class _LoadingScreenExampleWidgetState extends State<LoadingScreenExampleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  /// Message listener should be initialized here. The best place is the end of
  /// function to minimize a chance to loose an message, because everything is
  /// asynchronous
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LoadingScreenExampleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _controller.animateTo(
        widget.progress,
        duration: const Duration(seconds: 1),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          width: double.infinity,
          height: 40.0,
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(
                widget.text,
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
              LinearProgressIndicator(
                value: _controller.value,
                semanticsLabel: 'Game loading progress',
              ),
            ],
          ),
        ),
      );
}

/// Example of a component which receive messages during game loop.
/// Just add [MessageListener] mixin and implement [onStreamMessage]
/// function - the rest of configuration will be made by Flame.
class InGameProgressText extends TextComponent
    with MessageListener<ProgressMessage> {
  InGameProgressText({required double verticalPosition, required super.size}) {
    anchor = Anchor.topLeft;
    x = 10;
    y = verticalPosition;
    text = 'This will show in-game progress message';
  }

  /// The name of stream this component should listen for
  @override
  String get streamName => 'loading_progress';

  /// Just change the text here, but you might to do some more complex!
  @override
  void onStreamMessage(ProgressMessage message) {
    text = '${message.text}. The progress is: ${message.progress}';
  }
}
