//
//  HybridTextRecognizerOutput.swift
//  VisionCameraTextScanner
//
//  Created by Alex Korn on 21.04.26.
//

import AVFoundation
import Vision
import VisionCamera
import NitroModules

class HybridTextRecognizerOutput: HybridCameraOutputSpec, NativeCameraOutput {
  private var delegate: Delegate? = nil
  private let queue: DispatchQueue
  private let options: TextRecognizerOutputOptions
  let output = AVCaptureVideoDataOutput()
  let requiresAudioInput: Bool = false
  let requiresDepthFormat: Bool = false
  let mediaType: MediaType = .video
  var outputOrientation: CameraOrientation = .up

  let streamType: StreamType = .video
  var targetResolution: ResolutionRule {
    return .closestTo(Size(width: 720.0, height: 1280.0))
  }

  init(options: TextRecognizerOutputOptions) {
    self.options = options
    self.queue = DispatchQueue(label: "com.margelo.camera.textrecognizer")
    super.init()

    let busy = DispatchSemaphore(value: 1)
    self.delegate = Delegate(onSampleBuffer: { [weak self] sampleBuffer in
      guard let self else { return }
      guard busy.wait(timeout: .now()) == .success else { return }

      guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
        options.onError(RuntimeError.error(withMessage: "Failed to get pixel buffer from sample buffer!"))
        busy.signal()
        return
      }

      let bufW = CVPixelBufferGetWidth(pixelBuffer)
      let bufH = CVPixelBufferGetHeight(pixelBuffer)
      // After Vision rotates the buffer, portrait frame dims are swapped for landscape sensors.
      let isRotated = self.outputOrientation == .up || self.outputOrientation == .down
      let frameW = isRotated ? bufH : bufW
      let frameH = isRotated ? bufW : bufH
      self.performVisionRecognition(pixelBuffer: pixelBuffer, orientation: self.outputOrientation, frameWidth: frameW, frameHeight: frameH) { results in
        busy.signal()
        options.onTextScanned(results)
      }
    })

    self.output.setSampleBufferDelegate(delegate, queue: queue)
    self.output.alwaysDiscardsLateVideoFrames = true
    if #available(iOS 17.0, *), options.outputResolution != .full {
      self.output.deliversPreviewSizedOutputBuffers = true
    }
  }

  func configure(config: CameraOutputConfiguration) {
    guard let connection = self.output.connection(with: .video) else {
      return
    }
    connection.preferredVideoStabilizationMode = .off
  }

  private func performVisionRecognition(pixelBuffer: CVPixelBuffer, orientation: CameraOrientation, frameWidth: Int, frameHeight: Int, completion: @escaping ([HybridTextRecognizerResult]) -> Void) {
    var recognizedObservations: [VNRecognizedTextObservation] = []

    let request = VNRecognizeTextRequest { request, error in
      if error != nil { return }
      guard let observations = request.results as? [VNRecognizedTextObservation] else {
        return
      }
      recognizedObservations = observations
    }

    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = true
    if let languages = options.languages, !languages.isEmpty {
      request.recognitionLanguages = languages
    }

    let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation.toCGImagePropertyOrientation(), options: [:])

    DispatchQueue.global(qos: .userInitiated).async {
      do {
        try handler.perform([request])
        let result = HybridTextRecognizerResult(observations: recognizedObservations, frameWidth: frameWidth, frameHeight: frameHeight)
        completion([result])
      } catch {
        completion([])
      }
    }
  }

  final class Delegate: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private let onSampleBuffer: (CMSampleBuffer) -> Void

    init(onSampleBuffer: @escaping (CMSampleBuffer) -> Void) {
      self.onSampleBuffer = onSampleBuffer
      super.init()
    }

    func captureOutput(
      _ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer,
      from connection: AVCaptureConnection
    ) {
      onSampleBuffer(sampleBuffer)
    }
  }
}