//
//  HybridTextRecognizerResult.swift
//  VisionCameraTextScanner
//
//  Created by Your Name on Date.
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

  var boundingBox: Rect {
    guard let firstObservation = observations.first else {
      return Rect(left: 0, right: 0, top: 0, bottom: 0)
    }
    let box = firstObservation.boundingBox
    return Rect(
      left: box.origin.x,
      right: box.origin.x + box.size.width,
      top: box.origin.y,
      bottom: box.origin.y + box.size.height
    )
  }

  var cornerPoints: [Point] {
    guard let firstObservation = observations.first else {
      return []
    }
    let box = firstObservation.boundingBox
    return [
      Point(x: box.origin.x, y: box.origin.y),
      Point(x: box.origin.x + box.size.width, y: box.origin.y),
      Point(x: box.origin.x + box.size.width, y: box.origin.y + box.size.height),
      Point(x: box.origin.x, y: box.origin.y + box.size.height)
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

      let box = observation.boundingBox
      return TextBlock(
        text: candidate.string,
        boundingBox: Rect(
          left: box.origin.x,
          right: box.origin.x + box.size.width,
          top: box.origin.y,
          bottom: box.origin.y + box.size.height
        ),
        cornerPoints: [
          Point(x: box.origin.x, y: box.origin.y),
          Point(x: box.origin.x + box.size.width, y: box.origin.y),
          Point(x: box.origin.x + box.size.width, y: box.origin.y + box.size.height),
          Point(x: box.origin.x, y: box.origin.y + box.size.height)
        ],
        lines: [
          TextLine(
            text: candidate.string,
            boundingBox: Rect(
              left: box.origin.x,
              right: box.origin.x + box.size.width,
              top: box.origin.y,
              bottom: box.origin.y + box.size.height
            ),
            cornerPoints: [],
            words: [
              TextWord(
                text: candidate.string,
                boundingBox: Rect(
                  left: box.origin.x,
                  right: box.origin.x + box.size.width,
                  top: box.origin.y,
                  bottom: box.origin.y + box.size.height
                ),
                cornerPoints: []
              )
            ]
          )
        ]
      )
    }
  }
}