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
  let output = AVCaptureVideoDataOutput()
  let requiresAudioInput: Bool = false
  let requiresDepthFormat: Bool = false
  let mediaType: MediaType = .video
  var outputOrientation: Orientation = .up

  let streamType: StreamType = .video
  var targetResolution: ResolutionRule {
    return .closestTo(Size(width: 720.0, height: 1280.0))
  }

  init(options: TextRecognizerOutputOptions) {
    self.queue = DispatchQueue(label: "com.margelo.camera.textrecognizer")
    super.init()

    var isScanning = false
    self.delegate = Delegate(onSampleBuffer: { [weak self] sampleBuffer in
      guard let self else { return }
      if isScanning { return }

      isScanning = true

      guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
        options.onError(RuntimeError.error(withMessage: "Failed to get pixel buffer from sample buffer!"))
        isScanning = false
        return
      }

      self.performVisionRecognition(pixelBuffer: pixelBuffer, orientation: self.outputOrientation) { results in
        isScanning = false
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

  private func performVisionRecognition(pixelBuffer: CVPixelBuffer, orientation: Orientation, completion: @escaping ([HybridTextRecognizerResult]) -> Void) {
    var recognizedObservations: [VNRecognizedTextObservation] = []

    let request = VNRecognizeTextRequest { request, error in
      if let error = error {
        print("Vision error: \(error)")
        return
      }
      guard let observations = request.results as? [VNRecognizedTextObservation] else {
        return
      }
      recognizedObservations = observations
    }

    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = true

    let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation.toCGImagePropertyOrientation(), options: [:])

    DispatchQueue.global(qos: .userInitiated).async {
      do {
        try handler.perform([request])
        let result = HybridTextRecognizerResult(observations: recognizedObservations)
        completion([result])
      } catch {
        print("Vision perform error: \(error)")
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