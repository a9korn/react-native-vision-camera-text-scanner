import { useMemo } from 'react'
import type { Frame } from 'react-native-vision-camera'
import { createTextRecognizer } from './factory'
import type {
  TextRecognizer,
  TextRecognizerOptions,
} from './specs/TextRecognizer.nitro'

/**
 * Use a {@linkcode TextRecognizer}.
 */
export function useTextRecognizer({
  languages,
}: TextRecognizerOptions): TextRecognizer {
  return useMemo(
    () => createTextRecognizer({ languages: languages }),
    [languages],
  )
}