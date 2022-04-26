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
  case SetOffset = 1
  case SetTarget = 2
  case AckReference = 3
  case NumCommands  = 4
}

struct GuideCommandBlock {
  var command:Int32
  var raOffset:Int32
  var decOffset:Int32
}

