package com.margelo.nitro.camera.textrecognizer.extensions

import androidx.annotation.OptIn
import androidx.camera.core.ExperimentalGetImage
import androidx.camera.core.ImageProxy
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.frame.Frame
import com.margelo.nitro.camera.HybridFrameSpec

@OptIn(ExperimentalGetImage::class)
fun HybridFrameSpec.toInputImage(): InputImage {
  // For HybridFrame, we need to get the image from the frame
  // This is a placeholder - actual implementation depends on HybridFrame API
  throw NotImplementedError("HybridFrame to InputImage conversion not yet implemented")
}

fun ImageProxy.toInputImage(): InputImage {
  return InputImage.fromMediaImage(this.image!!, this.imageInfo.rotationDegrees)
}