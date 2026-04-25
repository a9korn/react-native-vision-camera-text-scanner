package com.margelo.nitro.camera.textrecognizer

import com.google.mlkit.vision.text.Text

// ML Kit returns absolute pixel coordinates with top-left origin.
// Normalize to (0–1) range so the JS side gets the same convention as iOS.
class HybridTextRecognizerResult(
  private val result: Text,
  frameWidth: Int,
  frameHeight: Int,
) : HybridTextRecognizerResultSpec() {

  private val _frameWidth: Int = frameWidth
  private val _frameHeight: Int = frameHeight

  private fun android.graphics.Rect.toNormalizedRect(): Rect = Rect(
    left = left.toDouble() / _frameWidth,
    right = right.toDouble() / _frameWidth,
    top = top.toDouble() / _frameHeight,
    bottom = bottom.toDouble() / _frameHeight,
  )

  private fun Array<android.graphics.Point>.toNormalizedPoints(): Array<Point> =
    map { Point(it.x.toDouble() / _frameWidth, it.y.toDouble() / _frameHeight) }.toTypedArray()

  override val frameWidth: Double = _frameWidth.toDouble()
  override val frameHeight: Double = _frameHeight.toDouble()

  override val text: String
    get() = result.text

  override val boundingBox: Rect
    get() = result.textBlocks.firstOrNull()?.boundingBox?.toNormalizedRect() ?: Rect(0.0, 0.0, 0.0, 0.0)

  override val cornerPoints: Array<Point>
    get() = result.textBlocks.firstOrNull()?.cornerPoints?.toNormalizedPoints() ?: emptyArray()

  override val blocks: Array<TextBlock>
    get() = result.textBlocks.map { block ->
      TextBlock(
        text = block.text,
        boundingBox = block.boundingBox?.toNormalizedRect() ?: Rect(0.0, 0.0, 0.0, 0.0),
        cornerPoints = block.cornerPoints?.toNormalizedPoints() ?: emptyArray(),
        lines = block.lines.map { line ->
          TextLine(
            text = line.text,
            boundingBox = line.boundingBox?.toNormalizedRect() ?: Rect(0.0, 0.0, 0.0, 0.0),
            cornerPoints = line.cornerPoints?.toNormalizedPoints() ?: emptyArray(),
            words = line.elements.map { element ->
              TextWord(
                text = element.text,
                boundingBox = element.boundingBox?.toNormalizedRect() ?: Rect(0.0, 0.0, 0.0, 0.0),
                cornerPoints = element.cornerPoints?.toNormalizedPoints() ?: emptyArray(),
              )
            }.toTypedArray()
          )
        }.toTypedArray()
      )
    }.toTypedArray()
}
