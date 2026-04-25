package com.margelo.nitro.camera.textrecognizer

import android.util.Size
import androidx.annotation.OptIn
import androidx.camera.core.ExperimentalGetImage
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageProxy
import androidx.camera.core.resolutionselector.ResolutionSelector
import androidx.camera.core.resolutionselector.ResolutionStrategy
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.TextRecognizer
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import com.margelo.nitro.camera.HybridCameraOutputSpec
import com.margelo.nitro.camera.MediaType
import com.margelo.nitro.camera.MirrorMode
import com.margelo.nitro.camera.CameraOrientation
import com.margelo.nitro.camera.extensions.surfaceRotation
import com.margelo.nitro.camera.public.NativeCameraOutput
import java.util.concurrent.Executors
import java.util.concurrent.atomic.AtomicBoolean

class HybridTextRecognizerOutput(
  private val options: TextRecognizerOutputOptions,
) : HybridCameraOutputSpec(),
  ImageAnalysis.Analyzer,
  NativeCameraOutput {
  override val mediaType: MediaType = MediaType.VIDEO
  override var outputOrientation: CameraOrientation = CameraOrientation.UP
    get() = field
    set(value) {
      field = value
      imageAnalysis?.targetRotation = value.surfaceRotation
    }
  override val mirrorMode: MirrorMode = MirrorMode.AUTO
  private var imageAnalysis: ImageAnalysis? = null
  private val executor = Executors.newSingleThreadExecutor()
  private val recognizer: TextRecognizer = TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)
  private var isBusy = AtomicBoolean(false)
  private val recommendedResolutionForTextScanning = Size(1280, 720)

  override fun createUseCase(
    mirrorMode: MirrorMode,
    config: NativeCameraOutput.Config,
  ): NativeCameraOutput.PreparedUseCase {
    val resolutionStrategy =
      if (options.outputResolution == TextRecognizerOutputResolution.FULL) {
        ResolutionStrategy.HIGHEST_AVAILABLE_STRATEGY
      } else {
        ResolutionStrategy(recommendedResolutionForTextScanning, ResolutionStrategy.FALLBACK_RULE_CLOSEST_HIGHER_THEN_LOWER)
      }
    val resolutionSelector =
      ResolutionSelector
        .Builder()
        .setResolutionStrategy(resolutionStrategy)
        .setAllowedResolutionMode(ResolutionSelector.PREFER_HIGHER_RESOLUTION_OVER_CAPTURE_RATE)
        .build()
    val imageAnalysis =
      ImageAnalysis
        .Builder()
        .setOutputImageFormat(ImageAnalysis.OUTPUT_IMAGE_FORMAT_YUV_420_888)
        .setOutputImageRotationEnabled(false)
        .setResolutionSelector(resolutionSelector)
        .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
        .build()
    return NativeCameraOutput.PreparedUseCase(imageAnalysis, {
      this.imageAnalysis = imageAnalysis
      imageAnalysis.setAnalyzer(executor, this)
    })
  }

  override fun dispose() {
    recognizer.close()
    executor.close()
  }

  @OptIn(ExperimentalGetImage::class)
  override fun analyze(imageProxy: ImageProxy) {
    try {
      if (!isBusy.compareAndSet(false, true)) {
        imageProxy.close()
        return
      }

      val mediaImage = imageProxy.image
      if (mediaImage == null) {
        imageProxy.close()
        isBusy.set(false)
        options.onError(Error("`ImageProxy` does not have an `Image`!"))
        return
      }
      val rotationDegrees = imageProxy.imageInfo.rotationDegrees
      val inputImage = InputImage.fromMediaImage(mediaImage, rotationDegrees)
      // After ML Kit applies rotation, coordinates are in the display (upright) frame.
      // For 90°/270° the sensor width/height are swapped relative to the display.
      val displayWidth = if (rotationDegrees == 90 || rotationDegrees == 270) imageProxy.height else imageProxy.width
      val displayHeight = if (rotationDegrees == 90 || rotationDegrees == 270) imageProxy.width else imageProxy.height
      recognizer
        .process(inputImage)
        .addOnSuccessListener { result ->
          val hybridResult = HybridTextRecognizerResult(result, displayWidth, displayHeight)
          options.onTextScanned(arrayOf(hybridResult))
        }.addOnFailureListener { error ->
          options.onError(error)
        }.addOnCompleteListener {
          imageProxy.close()
          isBusy.set(false)
        }
    } catch (error: Throwable) {
      imageProxy.close()
      isBusy.set(false)
      options.onError(error)
    }
  }
}
