import type { CameraOutput } from 'react-native-vision-camera';
import type { TextRecognizer, TextRecognizerOptions, TextRecognizerOutputOptions } from './specs/TextRecognizer.nitro';
/**
 * Create a new {@linkcode TextRecognizer}.
 *
 * The {@linkcode TextRecognizer} can be used to
 * scan text in a {@linkcode Frame}.
 */
export declare function createTextRecognizer(options: TextRecognizerOptions): TextRecognizer;
/**
 * Create a new Text Recognizer {@linkcode CameraOutput}.
 *
 * The Text Recognizer {@linkcode CameraOutput} can be
 * attached to a {@linkcode CameraSession}.
 */
export declare function createTextRecognizerOutput(options: TextRecognizerOutputOptions): CameraOutput;
