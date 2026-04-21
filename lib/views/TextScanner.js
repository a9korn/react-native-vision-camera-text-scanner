import { jsx as _jsx } from "react/jsx-runtime";
import { Camera, useCameraDevice, } from 'react-native-vision-camera';
import { useTextRecognizerOutput } from '../useTextRecognizerOutput';
/**
 * A view that detects text in a Camera
 * using the default rear {@linkcode CameraDevice}.
 */
export function TextScanner({ isActive, style, ...textRecognizerOptions }) {
    const device = useCameraDevice('back');
    const output = useTextRecognizerOutput(textRecognizerOptions);
    if (device == null) {
        throw new Error(`No Camera device available!`);
    }
    return (_jsx(Camera, { style: style, isActive: isActive, device: device, outputs: [output], onError: textRecognizerOptions.onError }));
}
