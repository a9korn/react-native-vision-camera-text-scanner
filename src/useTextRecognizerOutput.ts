import { useMemo, useRef } from 'react'
import type {
  Camera,
  CameraOutput,
  CameraSession,
} from 'react-native-vision-camera'
import { createTextRecognizerOutput } from './factory'
import type {
  TextRecognizerOutputOptions,
  TextRecognizerResult,
} from './specs/TextRecognizer.nitro'

/**
 * Use a Text Recognizer {@linkcode CameraOutput}.
 */
export function useTextRecognizerOutput({
  languages,
  outputResolution = 'preview',
  onTextScanned,
  onError,
}: TextRecognizerOutputOptions): CameraOutput {
  const stableOnTextScanned = useRef(onTextScanned)
  stableOnTextScanned.current = onTextScanned

  const stableOnError = useRef(onError)
  stableOnError.current = onError

  return useMemo(
    () =>
      createTextRecognizerOutput({
        languages: languages,
        outputResolution: outputResolution,
        onTextScanned(results: TextRecognizerResult[]) {
          stableOnTextScanned.current(results)
        },
        onError(error: Error) {
          stableOnError.current(error)
        },
      }),
    [languages, outputResolution],
  )
}