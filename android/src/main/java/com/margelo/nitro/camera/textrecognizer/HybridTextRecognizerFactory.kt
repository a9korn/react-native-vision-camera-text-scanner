package com.margelo.nitro.camera.textrecognizer

import com.margelo.nitro.camera.HybridCameraOutputSpec

class HybridTextRecognizerFactory : HybridTextRecognizerFactorySpec() {
  override fun createTextRecognizer(options: TextRecognizerOptions): HybridTextRecognizerSpec {
    return HybridTextRecognizer(options)
  }

  override fun createTextRecognizerOutput(
    options: TextRecognizerOutputOptions
  ): HybridCameraOutputSpec {
    return HybridTextRecognizerOutput(options)
  }
}