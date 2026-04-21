package com.margelo.nitro.camera.textrecognizer

import com.google.mlkit.vision.text.Text
import com.google.mlkit.vision.text.TextBlock
import com.google.mlkit.vision.text.TextLine
import com.google.mlkit.vision.text.TextWord
import com.margelo.nitro.camera.textrecognizer.extensions.fromMLTextBlockFormat
import com.margelo.nitro.core.ArrayBuffer

class HybridTextRecognizerResult(
  private val result: Text,
) : HybridTextRecognizerResultSpec() {
  override val text: String
    get() = result.text
  override val boundingBox: Rect
    get() {
      val box = result.boundingBox ?: return Rect(0.0, 0.0, 0.0, 0.0)
      return Rect(box.left.toDouble(), box.right.toDouble(), box.top.toDouble(), box.bottom.toDouble())
    }
  override val cornerPoints: Array<Point>
    get() {
      val points = result.cornerPoints ?: return emptyArray()
      return points
        .map { point -> Point(point.x.toDouble(), point.y.toDouble()) }
        .toTypedArray()
    }
  override val blocks: Array<HybridTextBlockSpec>
    get() = result.textBlocks.map { HybridTextBlock(it) }.toTypedArray()
}

// MARK: - TextBlock

class HybridTextBlock(
  private val block: TextBlock,
) : HybridTextBlockSpec() {
  override val text: String
    get() = block.text
  override val boundingBox: Rect
    get() {
      val box = block.boundingBox ?: return Rect(0.0, 0.0, 0.0, 0.0)
      return Rect(box.left.toDouble(), box.right.toDouble(), box.top.toDouble(), box.bottom.toDouble())
    }
  override val cornerPoints: Array<Point>
    get() {
      val points = block.cornerPoints ?: return emptyArray()
      return points
        .map { point -> Point(point.x.toDouble(), point.y.toDouble()) }
        .toTypedArray()
    }
  override val lines: Array<HybridTextLineSpec>
    get() = block.lines.map { HybridTextLine(it) }.toTypedArray()
}

// MARK: - TextLine

class HybridTextLine(
  private val line: TextLine,
) : HybridTextLineSpec() {
  override val text: String
    get() = line.text
  override val boundingBox: Rect
    get() {
      val box = line.boundingBox ?: return Rect(0.0, 0.0, 0.0, 0.0)
      return Rect(box.left.toDouble(), box.right.toDouble(), box.top.toDouble(), box.bottom.toDouble())
    }
  override val cornerPoints: Array<Point>
    get() {
      val points = line.cornerPoints ?: return emptyArray()
      return points
        .map { point -> Point(point.x.toDouble(), point.y.toDouble()) }
        .toTypedArray()
    }
  override val words: Array<HybridTextWordSpec>
    get() = line.elements.map { HybridTextWord(it) }.toTypedArray()
}

// MARK: - TextWord

class HybridTextWord(
  private val word: TextWord,
) : HybridTextWordSpec() {
  override val text: String
    get() = word.text
  override val boundingBox: Rect
    get() {
      val box = word.boundingBox ?: return Rect(0.0, 0.0, 0.0, 0.0)
      return Rect(box.left.toDouble(), box.right.toDouble(), box.top.toDouble(), box.bottom.toDouble())
    }
  override val cornerPoints: Array<Point>
    get() {
      val points = word.cornerPoints ?: return emptyArray()
      return points
        .map { point -> Point(point.x.toDouble(), point.y.toDouble()) }
        .toTypedArray()
    }
}