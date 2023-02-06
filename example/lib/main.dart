import 'package:flame_loading_progress/flame_loading_progress.dart';
import 'package:flame_loading_progress_example/game.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flame loading screen demo',

        /// use [Material] to keep material styles working
        home: Material(
          color: Colors.black,

          /// use [GameWidgetWrapper] instead original [GameWidget]
          child: GameWidgetWrapper<LoadingScreenExample,
              ProgressMessage>.controlled(
            gameFactory: LoadingScreenExample.new,

            /// This is new parameter. It is alternative to original
            /// [loadingBuilder] parameter. You should use it to enable
            /// progress reporting and transition animation
            loadingWidgetBuilder: ExampleBuilder(),
          ),
        ));
  }
}
