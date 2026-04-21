# Changelog

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
