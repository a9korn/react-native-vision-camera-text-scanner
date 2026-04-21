package com.margelo.nitro.camera.textrecognizer

import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.TextRecognizer
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import com.margelo.nitro.camera.HybridFrameSpec
import com.margelo.nitro.camera.textrecognizer.extensions.toInputImage
import com.margelo.nitro.core.Promise

class HybridTextRecognizer : HybridTextRecognizerSpec() {
  private val recognizer: TextRecognizer = TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)

  override fun recognizeText(frame: HybridFrameSpec): Array<HybridTextRecognizerResultSpec> {
    val image = frame.toInputImage()
    val result = recognizer.process(image).result
    return arrayOf(HybridTextRecognizerResult(result!!))
  }

  override fun recognizeTextAsync(frame: HybridFrameSpec): Promise<Array<HybridTextRecognizerResultSpec>> {
    val promise = Promise<Array<HybridTextRecognizerResultSpec>>()
    val image = frame.toInputImage()
    recognizer
      .process(image)
      .addOnSuccessListener { result ->
        promise.resolve(arrayOf(HybridTextRecognizerResult(result)))
      }.addOnFailureListener { error ->
        promise.reject(error)
      }
    return promise
  }
}
