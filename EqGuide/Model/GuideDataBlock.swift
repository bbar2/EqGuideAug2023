//
//  GuideDataBlock.swift
//  EqGuide
//
//  Created by Barry Bryant on 4/2/22.
//
//  Structure received from Mount microcontroller via Bluetooth receive operation.
//  Note that microcontroller uses 32 bit words.

import Foundation

// Must match Arduino project enum in NAppBleLogic.hpp
enum MountState:Int32 {
  case PowerUp = 0
  case ReadyOffset
  case ReadyMark
  case ReadyGuide
  case Guiding
  case GuideComplete
  case Pointing
  case PointComplete
  case Stopping
  case ReadyShutter
  case ShutterControl
  case StateError
}

struct GuideDataBlock {
  var armDegPerStep:Float32 = 1
  var decDegPerStep:Float32 = 1
  var mountState:Int32 = MountState.PowerUp.rawValue
  var markRefNowInt:Int32 = 0
  var mountTimeMs:UInt32 = 0
  var armCount:Int32 = 0
  var decCount:Int32 = 0

  var markReferenceNow: Bool {
    return markRefNowInt != 0
  }
  
}

