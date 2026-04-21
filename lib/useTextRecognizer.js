import { useMemo } from 'react';
import { createTextRecognizer } from './factory';
/**
 * Use a {@linkcode TextRecognizer}.
 */
export function useTextRecognizer({ languages, }) {
    return useMemo(() => createTextRecognizer({ languages: languages }), [languages]);
}
