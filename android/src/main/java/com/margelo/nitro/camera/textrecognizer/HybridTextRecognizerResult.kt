package com.margelo.nitro.camera.textrecognizer

import com.google.mlkit.vision.text.Text

private fun android.graphics.Rect.toNitroRect(): Rect =
  Rect(left.toDouble(), right.toDouble(), top.toDouble(), bottom.toDouble())

private fun Array<android.graphics.Point>.toNitroPoints(): Array<Point> =
  map { Point(it.x.toDouble(), it.y.toDouble()) }.toTypedArray()

class HybridTextRecognizerResult(
  private val result: Text,
) : HybridTextRecognizerResultSpec() {
  override val text: String
    get() = result.text

  override val boundingBox: Rect
    get() = result.boundingBox?.toNitroRect() ?: Rect(0.0, 0.0, 0.0, 0.0)

  override val cornerPoints: Array<Point>
    get() = result.cornerPoints?.toNitroPoints() ?: emptyArray()

  override val blocks: Array<TextBlock>
    get() = result.textBlocks.map { block ->
      TextBlock(
        text = block.text,
        boundingBox = block.boundingBox?.toNitroRect() ?: Rect(0.0, 0.0, 0.0, 0.0),
        cornerPoints = block.cornerPoints?.toNitroPoints() ?: emptyArray(),
        lines = block.lines.map { line ->
          TextLine(
            text = line.text,
            boundingBox = line.boundingBox?.toNitroRect() ?: Rect(0.0, 0.0, 0.0, 0.0),
            cornerPoints = line.cornerPoints?.toNitroPoints() ?: emptyArray(),
            words = line.elements.map { element ->
              TextWord(
                text = element.text,
                boundingBox = element.boundingBox?.toNitroRect() ?: Rect(0.0, 0.0, 0.0, 0.0),
                cornerPoints = element.cornerPoints?.toNitroPoints() ?: emptyArray(),
              )
            }.toTypedArray()
          )
        }.toTypedArray()
      )
    }.toTypedArray()
}
