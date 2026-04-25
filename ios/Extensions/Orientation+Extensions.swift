//
//  CameraOrientation+Extensions.swift
//  VisionCameraTextScanner
//
//  Created by Your Name on Date.
//

import VisionCamera

extension CameraOrientation {
  // Maps VisionCamera device orientation to the CGImagePropertyOrientation
  // that tells Vision Framework how the pixel buffer data is stored.
  // The camera sensor delivers landscape buffers regardless of device orientation,
  // so this is NOT a 1:1 mapping.
  func toCGImagePropertyOrientation() -> CGImagePropertyOrientation {
    switch self {
    case .up:    return .right  // portrait: buffer row-0 is at visual right
    case .right: return .up     // landscape-right: buffer is already upright
    case .down:  return .left   // inverted portrait: buffer row-0 is at visual left
    case .left:  return .down   // landscape-left: buffer row-0 is at visual bottom
    @unknown default: return .right
    }
  }
}