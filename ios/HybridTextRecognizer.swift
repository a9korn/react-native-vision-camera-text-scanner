//
//  HybridTextRecognizer.swift
//  VisionCameraTextScanner
//
//  Created by Alex Korn on 21.04.26.
//

import Vision
import VisionCamera
import NitroModules
import AVFoundation

class HybridTextRecognizer: HybridTextRecognizerSpec {
  init(options: TextRecognizerOptions) {
    super.init()
  }

  func recognizeText(frame: any HybridFrameSpec) throws -> [any HybridTextRecognizerResultSpec] {
    let (observations, frameWidth, frameHeight) = try performVisionRecognition(frame: frame)
    return [HybridTextRecognizerResult(observations: observations, frameWidth: frameWidth, frameHeight: frameHeight)]
  }

  func recognizeTextAsync(frame: any HybridFrameSpec) throws -> Promise<[any HybridTextRecognizerResultSpec]> {
    let promise = Promise<[any HybridTextRecognizerResultSpec]>()

    DispatchQueue.global(qos: .userInitiated).async {
      do {
        let (observations, frameWidth, frameHeight) = try self.performVisionRecognition(frame: frame)
        let result = HybridTextRecognizerResult(observations: observations, frameWidth: frameWidth, frameHeight: frameHeight)
        promise.resolve(withResult: [result])
      } catch {
        promise.reject(withError: error)
      }
    }

    return promise
  }

  private func performVisionRecognition(frame: any HybridFrameSpec) throws -> ([VNRecognizedTextObservation], Int, Int) {
    guard let nativeFrame = frame as? any NativeFrame else {
      throw RuntimeError.error(withMessage: "Frame is not of type `NativeFrame`!")
    }
    guard let sampleBuffer = nativeFrame.sampleBuffer else {
      throw RuntimeError.error(withMessage: "Frame doesn't have a CMSampleBuffer!")
    }
    guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
      throw RuntimeError.error(withMessage: "Failed to get pixel buffer from sample buffer!")
    }

    let bufW = CVPixelBufferGetWidth(pixelBuffer)
    let bufH = CVPixelBufferGetHeight(pixelBuffer)
    let orientation = frame.orientation
    let isRotated = orientation == .up || orientation == .down
    let frameWidth = isRotated ? bufH : bufW
    let frameHeight = isRotated ? bufW : bufH

    var observations: [VNRecognizedTextObservation] = []

    let request = VNRecognizeTextRequest { request, error in
      if error != nil { return }
      guard let results = request.results as? [VNRecognizedTextObservation] else {
        return
      }
      observations = results
    }

    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = true

    let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation.toCGImagePropertyOrientation(), options: [:])

    try handler.perform([request])

    return (observations, frameWidth, frameHeight)
  }
}