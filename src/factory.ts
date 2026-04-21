import { NitroModules } from 'react-native-nitro-modules'
import type {
  CameraOutput,
  CameraSession,
  Frame,
} from 'react-native-vision-camera'
import type {
  TextRecognizer,
  TextRecognizerResult,
  TextRecognizerFactory,
  TextRecognizerOptions,
  TextRecognizerOutputOptions,
} from './specs/TextRecognizer.nitro'

let _factory: TextRecognizerFactory | undefined

function getFactory(): TextRecognizerFactory {
  if (_factory == null) {
    _factory = NitroModules.createHybridObject<TextRecognizerFactory>(
      'TextRecognizerFactory',
    )
  }
  return _factory
}

export function createTextRecognizer(
  options: TextRecognizerOptions,
): TextRecognizer {
  return getFactory().createTextRecognizer(options)
}

export function createTextRecognizerOutput(
  options: TextRecognizerOutputOptions,
): CameraOutput {
  return getFactory().createTextRecognizerOutput(options)
}