# PedsFlow v19.2 Web Build Fix

- Uses `flutter build web --wasm --release --base-href "/pedsflow/"`.
- Required because `growth_standards` depends on `dart_numerics`, which contains 64-bit integer operations that fail dart2js JavaScript compilation.
- Includes the bilirubin `List<double>` and `preExchange` type fixes.
- Run `flutter analyze`, `flutter test`, and the WebAssembly build command before publishing.
