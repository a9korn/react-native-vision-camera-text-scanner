import { useMemo, useRef } from 'react';
import { createTextRecognizerOutput } from './factory';
/**
 * Use a Text Recognizer {@linkcode CameraOutput}.
 */
export function useTextRecognizerOutput({ languages, outputResolution = 'preview', onTextScanned, onError, }) {
    const stableOnTextScanned = useRef(onTextScanned);
    stableOnTextScanned.current = onTextScanned;
    const stableOnError = useRef(onError);
    stableOnError.current = onError;
    return useMemo(() => createTextRecognizerOutput({
        languages: languages,
        outputResolution: outputResolution,
        onTextScanned(results) {
            stableOnTextScanned.current(results);
        },
        onError(error) {
            stableOnError.current(error);
        },
    }), [languages, outputResolution]);
}
