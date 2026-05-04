# Changelog

## [5.0.8] - 2026-05-04

### Breaking Changes
- `Rect` renamed to `BoundingBox` with new coordinate format: `{ x, y, width, height }` (normalized [0,1], top-left origin) instead of `{ left, right, top, bottom }`

### Features
- `frameWidth` / `frameHeight` added to `TextRecognizerResult` for cover-mode bounding box mapping
- iOS: language hints now applied via `request.recognitionLanguages`
- Android: `TextRecognizerOptions` now correctly forwarded from factory to recognizer

### Fixes
- `tsconfig.json`: removed `noEmit: true`, added `outDir/rootDir/declaration` — build now correctly emits `lib/`
- `specs` script simplified to `nitrogen` only
- `HybridTextRecognizerFactory.kt`: options were not passed to `HybridTextRecognizer` constructor
- iOS `HybridTextRecognizerOutput`: replaced boolean flag with `DispatchSemaphore` to eliminate race condition in frame backpressure

### Chore
- Removed deprecated `src/specs/Common.ts` and `src/specs/TextRecognizerOutputResolution.ts`
- `lib/` moved to `.gitignore` (generated artifact); `prepare` script added
- Added `babel.config.js`, `.watchmanconfig`
- Updated `.gitignore` with Android build artifacts, IDE dirs, TypeScript cache
- Fixed podspec `source` URL (`USER` → `a9korn`)

## [5.0.0] - 2026-04-21

### Initial Release

First public release of `react-native-vision-camera-text-scanner`.

Built on top of [react-native-vision-camera](https://github.com/mrousavy/react-native-vision-camera) v5 and powered by [Nitro Modules](https://github.com/mrousavy/nitro).

#### Features
- Real-time text scanning via `TextScanner` component
- `useTextRecognizerOutput` hook for integration with custom `CameraSession`
- `useTextRecognizer` hook for standalone usage
- Multi-language support
- Full bounding box data per word, line, and block
- iOS: powered by Apple Vision framework
- Android: powered by Google ML Kit Text Recognition
