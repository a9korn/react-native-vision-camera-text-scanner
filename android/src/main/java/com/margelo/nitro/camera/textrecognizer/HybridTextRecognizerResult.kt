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

  private fun android.graphics.Rect.toNormalizedBoundingBox(): BoundingBox = BoundingBox(
    x = left.toDouble() / _frameWidth,
    y = top.toDouble() / _frameHeight,
    width = (right - left).toDouble() / _frameWidth,
    height = (bottom - top).toDouble() / _frameHeight,
  )

  private fun Array<android.graphics.Point>.toNormalizedPoints(): Array<Point> =
    map { Point(it.x.toDouble() / _frameWidth, it.y.toDouble() / _frameHeight) }.toTypedArray()

  override val frameWidth: Double = _frameWidth.toDouble()
  override val frameHeight: Double = _frameHeight.toDouble()

  override val text: String
    get() = result.text

  override val boundingBox: BoundingBox
    get() {
      val rects = result.textBlocks.mapNotNull { it.boundingBox }
      if (rects.isEmpty()) return BoundingBox(0.0, 0.0, 0.0, 0.0)
      val left = rects.minOf { it.left }
      val top = rects.minOf { it.top }
      val right = rects.maxOf { it.right }
      val bottom = rects.maxOf { it.bottom }
      return BoundingBox(
        x = left.toDouble() / _frameWidth,
        y = top.toDouble() / _frameHeight,
        width = (right - left).toDouble() / _frameWidth,
        height = (bottom - top).toDouble() / _frameHeight,
      )
    }

  override val cornerPoints: Array<Point>
    get() {
      val b = boundingBox
      if (b.width == 0.0 && b.height == 0.0) return emptyArray()
      return arrayOf(
        Point(b.x, b.y),
        Point(b.x + b.width, b.y),
        Point(b.x + b.width, b.y + b.height),
        Point(b.x, b.y + b.height),
      )
    }

  override val blocks: Array<TextBlock>
    get() = result.textBlocks.map { block ->
      TextBlock(
        text = block.text,
        boundingBox = block.boundingBox?.toNormalizedBoundingBox() ?: BoundingBox(0.0, 0.0, 0.0, 0.0),
        cornerPoints = block.cornerPoints?.toNormalizedPoints() ?: emptyArray(),
        lines = block.lines.map { line ->
          TextLine(
            text = line.text,
            boundingBox = line.boundingBox?.toNormalizedBoundingBox() ?: BoundingBox(0.0, 0.0, 0.0, 0.0),
            cornerPoints = line.cornerPoints?.toNormalizedPoints() ?: emptyArray(),
            words = line.elements.map { element ->
              TextWord(
                text = element.text,
                boundingBox = element.boundingBox?.toNormalizedBoundingBox() ?: BoundingBox(0.0, 0.0, 0.0, 0.0),
                cornerPoints = element.cornerPoints?.toNormalizedPoints() ?: emptyArray(),
              )
            }.toTypedArray()
          )
        }.toTypedArray()
      )
    }.toTypedArray()
}
