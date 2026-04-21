import React from 'react'
import type { ViewProps } from 'react-native'
import {
  Camera,
  type CameraDevice,
  useCameraDevice,
} from 'react-native-vision-camera'
import type {
  TextRecognizerOutputOptions,
} from '../specs/TextRecognizer.nitro'
import { useTextRecognizerOutput } from '../useTextRecognizerOutput'

export interface TextScannerOptions extends TextRecognizerOutputOptions {
  /**
   * Sets the style for this view.
   */
  style: ViewProps['style']
  /**
   * Whether the {@linkcode TextScanner} is active.
   */
  isActive: boolean
}

/**
 * A view that detects text in a Camera
 * using the default rear {@linkcode CameraDevice}.
 */
export function TextScanner({
  isActive,
  style,
  ...textRecognizerOptions
}: TextScannerOptions): React.ReactElement {
  const device = useCameraDevice('back')
  const output = useTextRecognizerOutput(textRecognizerOptions)

  if (device == null) {
    throw new Error(`No Camera device available!`)
  }
  return (
    <Camera
      style={style}
      isActive={isActive}
      device={device}
      outputs={[output]}
      onError={textRecognizerOptions.onError}
    />
  )
}