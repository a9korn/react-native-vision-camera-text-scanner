package com.margelo.nitro.camera.textrecognizer.extensions

import androidx.annotation.OptIn
import androidx.camera.core.ExperimentalGetImage
import androidx.camera.core.ImageProxy
import com.google.mlkit.vision.common.InputImage

@OptIn(ExperimentalGetImage::class)
fun ImageProxy.toInputImage(): InputImage {
  return InputImage.fromMediaImage(this.image!!, this.imageInfo.rotationDegrees)
}
