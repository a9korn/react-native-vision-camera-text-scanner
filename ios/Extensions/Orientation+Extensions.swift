//
//  CameraOrientation+Extensions.swift
//  VisionCameraTextScanner
//
//  Created by Your Name on Date.
//

import VisionCamera

extension CameraOrientation {
  func toCGImagePropertyOrientation() -> CGImagePropertyOrientation {
    switch self {
    case .up: return .up
    case .left: return .left
    case .right: return .right
    case .down: return .down
    @unknown default: return .up
    }
  }
}