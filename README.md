# react-native-vision-camera-text-scanner

Real-time text scanning plugin for [react-native-vision-camera](https://github.com/mrousavy/react-native-vision-camera) v5.

- **iOS** — powered by [Apple Vision framework](https://developer.apple.com/documentation/vision/recognizing_text_in_images)
- **Android** — powered by [Google ML Kit Text Recognition](https://developers.google.com/ml-kit/vision/text-recognition)
- Built with [Nitro Modules](https://github.com/mrousavy/nitro) for maximum performance

## Requirements

- `react-native-vision-camera` >= 5.0.0
- `react-native-nitro-modules` >= 0.35.0
- iOS 15.1+
- Android API 24+

## Installation

```bash
npm install react-native-vision-camera-text-scanner
cd ios && pod install
```

## Usage

### Option 1: TextScanner component

Drop-in component — handles camera + scanning internally.

```tsx
import { useEffect } from 'react'
import { AppState } from 'react-native'
import { TextScanner } from 'react-native-vision-camera-text-scanner'

function App() {
  const [isActive, setIsActive] = useState(true)

  useEffect(() => {
    const sub = AppState.addEventListener('change', state => {
      setIsActive(state === 'active')
    })
    return () => sub.remove()
  }, [])

  return (
    <TextScanner
      style={{ flex: 1 }}
      isActive={isActive}
      languages={['en']}
      onTextScanned={(results) => {
        const words = results.flatMap(r => r.blocks).flatMap(b => b.lines).flatMap(l => l.words)
        console.log('Detected words:', words.map(w => w.text))
      }}
      onError={(error) => console.error(error)}
    />
  )
}
```

### Option 2: useTextRecognizerOutput hook

For use with your own `Camera` component from `react-native-vision-camera`.

```tsx
import { Camera, useCameraDevice } from 'react-native-vision-camera'
import { useTextRecognizerOutput } from 'react-native-vision-camera-text-scanner'

function CameraScreen() {
  const device = useCameraDevice('back')

  const textOutput = useTextRecognizerOutput({
    languages: ['en'],
    onTextScanned: (results) => {
      const numericWords = results
        .flatMap(r => r.blocks)
        .flatMap(b => b.lines)
        .flatMap(l => l.words)
        .filter(w => /^\d+$/.test(w.text))

      console.log('Numbers found:', numericWords.map(w => w.text))
    },
    onError: (error) => console.error(error),
  })

  if (!device) return null

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

## API

### `<TextScanner>` Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `isActive` | `boolean` | — | Whether scanning is active |
| `languages` | `string[]` | — | Language hints (e.g. `['en', 'de']`) |
| `outputResolution` | `'preview' \| 'full'` | `'preview'` | Resolution to scan at |
| `onTextScanned` | `(results: TextRecognizerResult[]) => void` | — | Called with detected text |
| `onError` | `(error: Error) => void` | — | Called on error |
| `style` | `ViewStyle` | — | Style for the camera view |

### `useTextRecognizerOutput(options)` Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `languages` | `string[]` | — | Language hints |
| `outputResolution` | `'preview' \| 'full'` | `'preview'` | Resolution to scan at |
| `onTextScanned` | `(results: TextRecognizerResult[]) => void` | — | Called with detected text |
| `onError` | `(error: Error) => void` | — | Called on error |

### `TextRecognizerResult`

```ts
type TextRecognizerResult = {
  text: string           // Full raw text of the result
  boundingBox: Rect
  cornerPoints: Point[]
  blocks: TextBlock[]
}

type TextBlock = {
  text: string
  boundingBox: Rect
  cornerPoints: Point[]
  lines: TextLine[]
}

type TextLine = {
  text: string
  boundingBox: Rect
  cornerPoints: Point[]
  words: TextWord[]
}

type TextWord = {
  text: string
  boundingBox: Rect
  cornerPoints: Point[]
}

type Rect = { x: number; y: number; width: number; height: number }
type Point = { x: number; y: number }
```

## License

MIT © [Alex Korn](https://github.com/a9korn)
