//
//  GuideDataBlock.swift
//  EqGuide
//
//  Created by Barry Bryant on 4/2/22.
//
//  Structure received from Mount microcontroller via Bluetooth receive operation.
//  Ensure 32 bit sized words to match 32 bit microcontroller.

import Foundation

// Must match Arduino project enum in NAppBleLogic.hpp
enum MountState:Int32 {
  case PowerUp = 0
  case ReadyGuide
  case Guiding
  case GuideComplete
  case Stopping
  case StateError
}

struct GuideDataBlock {
  var pierDegPerStep: Float32 = 1.0    // really, Degrees per MicroStep
  var diskDegPerStep: Float32 = 1.0   // Again, Degrees per MicroStep
  var raRateOffsetDegPerSec: Float32 = 0.0
  var accel_x: Float32 = 0.0
  var accel_y: Float32 = 0.0
  var accel_z: Float32 = 0.0
  var mountState: Int32 = MountState.PowerUp.rawValue
  var trackingPaused: Int32 = 0
  var mountTimeMs: UInt32 = 0
  var pierCount: Int32 = 0
  var diskCount: Int32 = 0
  
  var pierCountDeg: Double {
      return Double(pierCount) * Double(pierDegPerStep)
  }
  
  var diskCountDeg: Double {
    return Double(diskCount) * Double(diskDegPerStep)
  }
  
}

