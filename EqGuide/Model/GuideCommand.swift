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
  case SetArmPos = 4      // Inform Mount that Arm is in Positive hemisphere
  case SetArmNeg = 5      // Inform Mount that Arm is in Negative hemisphere
  case NumCommands = 6
}

struct GuideCommandBlock {
  var command:Int32
  var armOffset:Int32
  var diskOffset:Int32
}

