//
//  GuideCommand.swift
//  EqGuide
//
//  Created by Barry Bryant on 4/2/22.
//
//  Structure sent to Mount Microcontroller via Bluetooth send operation.
//  Note that microcontroller uses 32 bit words.

import Foundation

struct GuideCommandBlock {
  var command:Int32
  var raOffset:Int32
  var decOffset:Int32
}

enum GuideCommand:Int32 {
  case noOp = 0
  case setOffset = 1
  case tbd = 2
}
