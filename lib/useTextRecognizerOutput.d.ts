import type { CameraOutput } from 'react-native-vision-camera';
import type { TextRecognizerOutputOptions } from './specs/TextRecognizer.nitro';
/**
 * Use a Text Recognizer {@linkcode CameraOutput}.
 */
export declare function useTextRecognizerOutput({ languages, outputResolution, onTextScanned, onError, }: TextRecognizerOutputOptions): CameraOutput;
