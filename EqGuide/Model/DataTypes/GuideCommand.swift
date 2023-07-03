//
//  GuideCommand.swift
//  EqGuide
//
//  Created by Barry Bryant on 4/2/22.
//
//  Structure sent to Mount Microcontroller via Bluetooth send operation.
//  Note that microcontroller uses 32 bit words.
//  Struct and enum must match EqMount project's NAppBleLogic.hpp

enum GuideCommand:Int32 {
  case NoOp = 0
  case SetRaOffsetDps = 1 // Tweak RA tracking speed based on observation
  case GuideToOffset = 2  // Results from GoTo Target
  case PauseTracking = 3  // Stop RA tracking
  case ResumeTracking = 4 // Resume RA tracking
  case Move = 5           // Offsets hold move speed. +-2 fast.  +-1 slow. 0 Neutral.
  case Reset = 6           // Offsets get 0 to neutalize movement.
  case GoHome = 7         // Move till XlPierY = 0.  Direciton controlled by XlPierY
  case GoEastPier = 8    // Move till XlAmrZ = 0.  Direction controlled by XlPierY
  case NumCommands = 9
}

struct GuideCommandBlock {
  var command: Int32
  var pierOffset = Int32(0)      // Counts, or micro steps
  var diskOffset = Int32(0)       // Counts, or micro steps
  var raRateOffsetDps = Float32(0)   // Offset in Deg Per Sec -- UI is ArcSec per Min
}


