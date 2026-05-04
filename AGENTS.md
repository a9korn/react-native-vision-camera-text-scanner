# react-native-vision-camera-text-scanner — AI Agent Context

Real-time text scanning plugin for react-native-vision-camera v5.
Uses **Nitro Modules** for JS↔Native bridge (not TurboModules/JSI directly).

## Stack

| Layer | Tech |
|-------|------|
| JS/TS | Nitro Modules HybridObjects, React hooks |
| iOS | Swift + Apple Vision Framework (`VNRecognizeTextRequest`) |
| Android | Kotlin + Google ML Kit Text Recognition |
| Bridge spec | `src/specs/TextRecognizer.nitro.ts` → nitrogen codegen |

## Key Files

```
src/
  specs/TextRecognizer.nitro.ts   ← single source of truth: all types + interfaces
  factory.ts                      ← singleton factory (NitroModules.createHybridObject)
  useTextRecognizer.ts            ← hook for frame-by-frame (manual) usage
  useTextRecognizerOutput.ts      ← hook returns CameraOutput (preferred path)
  views/TextScanner.tsx           ← drop-in component (wraps Camera + useTextRecognizerOutput)

ios/
  HybridTextRecognizer.swift       ← sync + async recognizeText()
  HybridTextRecognizerOutput.swift ← AVCaptureVideoDataOutput-based streaming
  HybridTextRecognizerResult.swift ← coordinate conversion Vision→UIKit, block/line/word tree
  HybridTextRecognizerFactory.swift
  Extensions/Orientation+Extensions.swift  ← CameraOrientation → CGImagePropertyOrientation

android/src/main/java/.../
  HybridTextRecognizer.kt          ← sync + async recognizeText()
  HybridTextRecognizerOutput.kt    ← ImageAnalysis.Analyzer streaming
  HybridTextRecognizerResult.kt    ← pixel coords → normalized [0,1]
  extensions/HybridFrameSpec+toInputImage.kt
```

## Coordinate System

All bounding boxes returned to JS are **normalized [0, 1]**, origin **top-left**.

- **iOS**: Vision uses bottom-left origin → converted in `visionBoxToBoundingBox()`:
  `y = 1.0 - (box.origin.y + box.size.height)`
- **Android**: ML Kit returns absolute pixels → divided by `displayWidth/displayHeight`
  (width/height are swapped when `rotationDegrees == 90 || 270`)

`frameWidth` / `frameHeight` on `TextRecognizerResult` are the post-rotation display dimensions.
Use them to map normalized coords to view pixels accounting for cover-mode cropping.

## API Surface (stable)

```ts
// Preferred: streaming via CameraOutput
const output = useTextRecognizerOutput({ languages, outputResolution, onTextScanned, onError })
<Camera outputs={[output]} ... />

// Drop-in (rear camera only)
<TextScanner style isActive languages outputResolution onTextScanned onError />

// Manual: call per-frame inside frame processor
const recognizer = useTextRecognizer({ languages })
recognizer.recognizeText(frame)       // sync
recognizer.recognizeTextAsync(frame)  // async → Promise
```

## Known Issues / Gotchas

1. **`languages` partially implemented** — iOS now applies `request.recognitionLanguages` when
   `languages` is non-empty. Android still ignores it: ML Kit's Latin recognizer does not support
   language hints via `TextRecognizerOptions.Builder`.

2. **`useMemo` deps: languages is array** — fixed: hooks now use `JSON.stringify(languages)` as
   the dep so value-equal arrays don't recreate the recognizer. Callers should still stabilize the
   array (useRef/useMemo) for clarity.

3. **Dead code**: `src/specs/Common.ts` (unused, has wrong `Rect` type) and
   `src/specs/TextRecognizerOutputResolution.ts` (duplicates type from nitro spec). Both are
   marked `@deprecated` but not yet removed to avoid any accidental breakage for consumers who
   may have imported them directly.

## Git Conventions

- Commit messages: describe only the changes, no `Co-Authored-By` or AI attribution lines
- Tag format: `v{version}` matching `package.json` version

## Build / Codegen

```bash
bun typecheck          # tsc --noEmit
bun run build          # tsc → lib/
bun run specs          # tsc + nitrogen (regenerates nitrogen/generated/)
```

Nitrogen codegen reads `nitro.json` + `src/specs/*.nitro.ts`.
After changing specs, always re-run `bun run specs`.

## Testing

No automated tests yet. Planned:
- **XCTest** (iOS): coordinate conversion, bounding box union
- **JUnit** (Android): normalization math, rotation swap
- **Jest** (TS): hook behavior with mocked `react-native-nitro-modules`

Mock path for Jest:
```ts
// __mocks__/react-native-nitro-modules.ts
export const NitroModules = {
  createHybridObject: jest.fn(() => ({ createTextRecognizer: jest.fn(), createTextRecognizerOutput: jest.fn() }))
}
```
