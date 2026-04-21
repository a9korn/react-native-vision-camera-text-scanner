import React from 'react';
import type { ViewProps } from 'react-native';
import type { TextRecognizerOutputOptions } from '../specs/TextRecognizer.nitro';
export interface TextScannerOptions extends TextRecognizerOutputOptions {
    /**
     * Sets the style for this view.
     */
    style: ViewProps['style'];
    /**
     * Whether the {@linkcode TextScanner} is active.
     */
    isActive: boolean;
}
/**
 * A view that detects text in a Camera
 * using the default rear {@linkcode CameraDevice}.
 */
export declare function TextScanner({ isActive, style, ...textRecognizerOptions }: TextScannerOptions): React.ReactElement;
