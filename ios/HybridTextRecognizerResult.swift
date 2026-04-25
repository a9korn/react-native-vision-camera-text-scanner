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

  init(observations: [VNRecognizedTextObservation]) {
    self.observations = observations
    super.init()
  }

  var text: String {
    return observations.compactMap { observation in
      observation.topCandidates(1).first?.string
    }.joined(separator: " ")
  }

  // Vision Framework uses bottom-left origin with normalized (0–1) coordinates.
  // Convert to top-left origin (UIKit/RN convention) so callers get a consistent system.
  private func visionRectToTopLeft(_ box: CGRect) -> Rect {
    return Rect(
      left: box.origin.x,
      right: box.origin.x + box.size.width,
      top: 1.0 - (box.origin.y + box.size.height),
      bottom: 1.0 - box.origin.y
    )
  }

  var boundingBox: Rect {
    guard let firstObservation = observations.first else {
      return Rect(left: 0, right: 0, top: 0, bottom: 0)
    }
    return visionRectToTopLeft(firstObservation.boundingBox)
  }

  var cornerPoints: [Point] {
    guard let firstObservation = observations.first else {
      return []
    }
    let box = firstObservation.boundingBox
    let r = visionRectToTopLeft(box)
    return [
      Point(x: r.left, y: r.top),
      Point(x: r.right, y: r.top),
      Point(x: r.right, y: r.bottom),
      Point(x: r.left, y: r.bottom),
    ]
  }

  var blocks: [TextBlock] {
    return observations.map { observation in
      guard let candidate = observation.topCandidates(1).first else {
        return TextBlock(
          text: "",
          boundingBox: Rect(left: 0, right: 0, top: 0, bottom: 0),
          cornerPoints: [],
          lines: []
        )
      }

      let r = visionRectToTopLeft(observation.boundingBox)
      return TextBlock(
        text: candidate.string,
        boundingBox: r,
        cornerPoints: [
          Point(x: r.left, y: r.top),
          Point(x: r.right, y: r.top),
          Point(x: r.right, y: r.bottom),
          Point(x: r.left, y: r.bottom),
        ],
        lines: [
          TextLine(
            text: candidate.string,
            boundingBox: r,
            cornerPoints: [],
            words: [
              TextWord(
                text: candidate.string,
                boundingBox: r,
                cornerPoints: []
              )
            ]
          )
        ]
      )
    }
  }
}