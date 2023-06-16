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
  case SetOffset = 1      // Tell Mount to move to offset without a Reference Mark
  case SetTarget = 2      // Tell mount to Mark a Reference then Move to Offset
  case AckReference = 3   // Acknowledge that MarkReference has been handled by iOS App
  case SetRaOffsetDps = 4 // Tweak RA tracking speed based on observation
  case PauseTracking = 5  // Stop RA tracking
  case ResumeTracking = 6 // Resume RA tracking
  case Move = 7           // Offsets hold move speed. +-2 fast.  +-1 slow. 0 Neutral.
  case Stop = 8           // Offsets get 0 to neutalize movement.
  case GoHome = 9         // Move till XlArmY = 0.  Direciton controlled by XlArmY
  case GoEastPier = 10    // Move till XlAmrZ = 0.  Direction controlled by XlArmY
  case MarkRefNow = 11
  case MoveToOffset = 12  // Results from GoTo Target
  case NumCommands = 13
}

struct GuideCommandBlock {
  var command: Int32
  var armOffset = Int32(0)       // Counts, or micro steps
  var dskOffset = Int32(0)       // Counts, or micro steps
  var raRateOffsetDps = Float32(0)   // Offset in Deg Per Sec -- UI is ArcSec per Min
}


