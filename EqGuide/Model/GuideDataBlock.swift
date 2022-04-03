//
//  GuideDataBlock.swift
//  EqGuide
//
//  Created by Barry Bryant on 4/2/22.
//
//  Structure received from Mount microcontroller via Bluetooth receive operation.
//  Note that microcontroller uses 32 bit words.


import Foundation

struct GuideDataBlock {
  var raDegPerStep:Float32 = 1
  var decDegPerStep:Float32 = 1
  var mountState:Int32 = 0
  var mountTimeMs:UInt32 = 0
  var raCount:Int32 = 0
  var decCount:Int32 = 0
}
