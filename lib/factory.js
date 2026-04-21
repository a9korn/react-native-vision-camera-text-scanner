import { NitroModules } from 'react-native-nitro-modules';
const factory = NitroModules.createHybridObject('TextRecognizerFactory');
/**
 * Create a new {@linkcode TextRecognizer}.
 *
 * The {@linkcode TextRecognizer} can be used to
 * scan text in a {@linkcode Frame}.
 */
export function createTextRecognizer(options) {
    return factory.createTextRecognizer(options);
}
/**
 * Create a new Text Recognizer {@linkcode CameraOutput}.
 *
 * The Text Recognizer {@linkcode CameraOutput} can be
 * attached to a {@linkcode CameraSession}.
 */
export function createTextRecognizerOutput(options) {
    return factory.createTextRecognizerOutput(options);
}
