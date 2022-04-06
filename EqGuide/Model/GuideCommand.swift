//
//  GuideCommand.swift
//  EqGuide
//
//  Created by Barry Bryant on 4/2/22.
//
//  Structure sent to Mount Microcontroller via Bluetooth send operation.
//  Note that microcontroller uses 32 bit words.

import Foundation

enum GuideCommand:Int32 {
  case NoOp = 0
  case SetOffset = 1
  case SetTarget = 2
  case NumCommands = 3
}

struct GuideCommandBlock {
  var command:Int32
  var raOffset:Int32
  var decOffset:Int32
}

