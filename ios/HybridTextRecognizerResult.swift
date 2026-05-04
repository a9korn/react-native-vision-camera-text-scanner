//
//  HybridTextRecognizerResult.swift
//  VisionCameraTextScanner
//
//  Created by Alex Korn on 21.04.26.
//

import Vision
import NitroModules

final class HybridTextRecognizerResult: HybridTextRecognizerResultSpec {
  private let observations: [VNRecognizedTextObservation]
  private let _frameWidth: Double
  private let _frameHeight: Double

  init(observations: [VNRecognizedTextObservation], frameWidth: Int, frameHeight: Int) {
    self.observations = observations
    self._frameWidth = Double(frameWidth)
    self._frameHeight = Double(frameHeight)
    super.init()
  }

  var frameWidth: Double { _frameWidth }
  var frameHeight: Double { _frameHeight }

  var text: String {
    return observations.compactMap { observation in
      observation.topCandidates(1).first?.string
    }.joined(separator: " ")
  }

  // Vision Framework uses bottom-left origin with normalized (0–1) coordinates.
  // Convert to top-left origin (UIKit/RN convention) so callers get a consistent system.
  private func visionBoxToBoundingBox(_ box: CGRect) -> BoundingBox {
    return BoundingBox(
      x: box.origin.x,
      y: 1.0 - (box.origin.y + box.size.height),
      width: box.size.width,
      height: box.size.height
    )
  }

  var boundingBox: BoundingBox {
    guard !observations.isEmpty else {
      return BoundingBox(x: 0, y: 0, width: 0, height: 0)
    }
    // Compute union of all observation bounding boxes (Vision coords: bottom-left origin).
    let minX = observations.map { $0.boundingBox.minX }.min()!
    let minY = observations.map { $0.boundingBox.minY }.min()!
    let maxX = observations.map { $0.boundingBox.maxX }.max()!
    let maxY = observations.map { $0.boundingBox.maxY }.max()!
    let unionBox = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    return visionBoxToBoundingBox(unionBox)
  }

  var cornerPoints: [Point] {
    guard !observations.isEmpty else {
      return []
    }
    let b = boundingBox
    return [
      Point(x: b.x,           y: b.y),
      Point(x: b.x + b.width, y: b.y),
      Point(x: b.x + b.width, y: b.y + b.height),
      Point(x: b.x,           y: b.y + b.height),
    ]
  }

  // Vision Framework does not provide a block/line/word hierarchy — each VNRecognizedTextObservation
  // is a single recognized text region. We map each observation to one Block containing one Line
  // containing one Word. This is an intentional simplification; the structure mirrors Android ML Kit's
  // output shape for API consistency.
  var blocks: [TextBlock] {
    return observations.map { observation in
      guard let candidate = observation.topCandidates(1).first else {
        return TextBlock(
          text: "",
          boundingBox: BoundingBox(x: 0, y: 0, width: 0, height: 0),
          cornerPoints: [],
          lines: []
        )
      }

      let b = visionBoxToBoundingBox(observation.boundingBox)
      let corners = [
        Point(x: b.x,           y: b.y),
        Point(x: b.x + b.width, y: b.y),
        Point(x: b.x + b.width, y: b.y + b.height),
        Point(x: b.x,           y: b.y + b.height),
      ]
      return TextBlock(
        text: candidate.string,
        boundingBox: b,
        cornerPoints: corners,
        lines: [
          TextLine(
            text: candidate.string,
            boundingBox: b,
            cornerPoints: [],
            words: [
              TextWord(
                text: candidate.string,
                boundingBox: b,
                cornerPoints: []
              )
            ]
          )
        ]
      )
    }
  }
}