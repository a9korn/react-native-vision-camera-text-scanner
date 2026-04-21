# react-native-vision-camera-text-scanner

Text scanning plugin for [react-native-vision-camera](https://reactnativevisioncamera.com) powered by ML Kit.

## Installation

```bash
npm install react-native-vision-camera-text-scanner
cd ios && pod install
```

## Usage

### TextScanner Component

```tsx
import { TextScanner } from 'react-native-vision-camera-text-scanner'
import { useAppState } from 'react-native'

function App() {
  const appState = useAppState()
  const isActive = appState === 'active'

  return (
    <TextScanner
      style={{ flex: 1 }}
      isActive={isActive}
      languages={['en']}
      onTextScanned={(results) => {
        console.log('Detected text:', results[0]?.text)
      }}
      onError={(error) => {
        console.error('Text scanning error:', error)
      }}
    />
  )
}
```

### useTextRecognizerOutput Hook

```tsx
import { useTextRecognizerOutput } from 'react-native-vision-camera-text-scanner'

function MyComponent({ camera }) {
  const textOutput = useTextRecognizerOutput({
    languages: ['en'],
    onTextScanned: (results) => {
      // Filter for numeric values
      const numericWords = results
        .flatMap(r => r.blocks)
        .flatMap(b => b.lines)
        .flatMap(l => l.words)
        .filter(w => /^\d+$/.test(w.text))

      console.log('Numeric values found:', numericWords)
    },
    onError: (error) => console.error(error),
  })

  return (
    <Camera
      style={{ flex: 1 }}
      isActive={true}
      device={device}
      outputs={[textOutput]}
    />
  )
}
```

### Frame Processor

```tsx
import { useTextRecognizer, useFrameOutput } from 'react-native-vision-camera-text-scanner'

function MyComponent() {
  const textRecognizer = useTextRecognizer({ languages: ['en'] })

  const frameOutput = useFrameOutput({
    onFrame: (frame) => {
      'worklet'
      const results = textRecognizer.recognizeText(frame)
      console.log('Detected text:', results.length)
      frame.dispose()
    }
  })

  return (
    <Camera
      style={{ flex: 1 }}
      isActive={true}
      device={device}
      outputs={[frameOutput]}
    />
  )
}
```

## API

### TextScanner Props

- `style` - View style
- `isActive` - Whether scanning is active
- `languages` - Language hints for ML Kit (e.g., `['en', 'de']`)
- `outputResolution` - `'preview'` (default) or `'full'`
- `onTextScanned` - Callback with detected text results
- `onError` - Error callback

### TextRecognizerResult

The result contains a hierarchical structure:

- `text` - Full raw text
- `boundingBox` - Bounding box of entire result
- `cornerPoints` - Corner points
- `blocks` - Array of text blocks
  - `lines` - Array of text lines
    - `words` - Array of words

Each level (block, line, word) has:
- `text` - Text content
- `boundingBox` - Bounding box coordinates
- `cornerPoints` - Corner points

## License

MIT