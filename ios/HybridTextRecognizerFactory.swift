//
//  HybridTextRecognizerFactory.swift
//  VisionCameraTextScanner
//
//  Created by Alex Korn on 21.04.26.
//

import NitroModules
import VisionCamera

class HybridTextRecognizerFactory: HybridTextRecognizerFactorySpec {
  func createTextRecognizer(options: TextRecognizerOptions) throws -> any HybridTextRecognizerSpec {
    return HybridTextRecognizer(options: options)
  }

  func createTextRecognizerOutput(options: TextRecognizerOutputOptions) throws
    -> any HybridCameraOutputSpec
  {
    return HybridTextRecognizerOutput(options: options)
  }
}