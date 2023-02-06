Flame extension for displaying progress bar during game's onLoad process and also for rendering
transition animation between widget and game

## Features

- Display loading screen with progress bar
- Use any Flutter widget for this purpose without special requirements
- Render transition animation between game ans loading screen after `onLoad` is finished

## Getting started

Steps you should to perform to make things work:

1. Define messaging class to represent progress message from game to widget. Or ypu can use a simple
   type like `String` or `int`
2. Add mixins to your Flame game's class: `HasMessageProviders` and `HasLoadingProgress` with
   specifying message class type
   chosen in step 1
3. Insert calls of `reportLoadingProgress` function into `onLoad` function of the game.
4. Create subclass of `LoadingWidgetBuilder` and implement methods  `buildOnMessage`
   and `buildTransitionToGame`. In the last method use `gameWidget` parameter to render original
   Flame's `GameWidget` in widget's tree. You can use any existing Flutter widget for progress
   reporting, or create your own, or even use one from third-party libraries. Unleash your
   creativity here!
5. Use `GameWidgetWrapper` class instead original `GameWidget`. Specify your new class from step 4
   into `loadingWidgetBuilder` parameter.
6. Enjoy pretty animations!

## Usage

For more detailed instructions check the [game.dart](examples/lib/game.dart) file, where steps 1-4
are illustrated. Check [main.dart](examples/lib/main.dart) for step 5.

Also visit [live demo](https://asgalex.github.io/flame_loading_progress/) to see this package in
action.