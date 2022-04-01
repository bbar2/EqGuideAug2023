//
//  Dms.swift
//  EqGuide
//
//  Created by Barry Bryant on 3/30/22.
//
// Declination is either Float Degrees or DMS integers, where:
//   0<=D<360, 0<=M<60, 0<=S<60
//
// Positions are always positive.  DMS offsets can be negative.
//
// D, M, and S should all have the same sign.  DMS is mathamaticaly correct
// with different signs, but it's not meaningful.
//
// ToDo - Update for appropriate range of 0 to 180. I Think.

struct Dms {
  var degrees:Float
  
  init(deg: Float) {
    degrees = deg
  }

  init(d:Int, m:Int, s:Int) {
    degrees = Float(Float(d) + Float(m) / 60.0 + Float(s) / 3600.0)
  }
  
  var sign:Float {
    return degrees < 0.0 ? -1.0 : 1.0
  }
  
  var deg: Int {
    Int(degrees)
  }
  
  var min: Int {
    let remainderDeg = degrees.truncatingRemainder(dividingBy: 1.0)
    return Int(remainderDeg * 60.0)
  }
        
  var sec: Int {
    let remainderDeg = degrees.truncatingRemainder(dividingBy: 1.0)
    let remainderMin = (remainderDeg * 60.0).truncatingRemainder(dividingBy: 1.0)
    return Int(remainderMin * 60.0 + sign * 0.5) // Round to nearest sec
  }

  static func + (left: Dms, right: Dms) -> Dms {
    return Dms(deg: left.degrees + right.degrees)
  }
  
  static func - (left: Dms, right: Dms) -> Dms {
    return Dms(deg: left.degrees - right.degrees)
  }

}
