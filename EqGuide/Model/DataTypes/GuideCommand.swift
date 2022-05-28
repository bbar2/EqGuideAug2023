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
  case NumCommands = 5
}

struct GuideCommandBlock {
  var command:Int32
  var armOffset:Int32           // Counts, or micro steps
  var diskOffset:Int32          // Counts, or micro steps
  var raRateOffsetDps:Float32   // Rate in Degrees Per Second -- UI IS IN DEG_PER_MIN
}


