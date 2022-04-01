//
//  Hms.swift
//  EqGuide
//
//  Created by Barry Bryant on 3/30/22.
//
// Right Ascention is either Float Degrees or HMS integers, where:
//   0<=H<24, 0<=M<60, 0<=S<60
//   Note Factor of 15 between 24 Hours and 360 Degrees.
//
// Negative HMS angles only make sense for Offsets between positions.
// H, M, & S will usually all have the same sign.  You can construnct with
// different signs, and it will work, but it's not too meaningful.
//
// ToDo - Consider range limits.  i.e. wrapping to stay 0H <= HMS < 24H

struct Hms {
  var degrees:Float
  
  let DegPerHour = Float(15.0)
  
  init(deg: Float) {
    degrees = deg
  }

  init (h:Int, m:Int, s:Int) {
    degrees = Float(
      Float(h) * 15.0 +
      Float(m) * 15.0 / 60.0 +
      Float(s) * 15.0 / 3600.0
    )
  }
  
  var sign:Float {
    return degrees < 0.0 ? -1.0 : 1.0
  }
  
  var hour: Int {
    Int(degrees / DegPerHour)
  }
  
  var min: Int {
    let hours: Float = degrees / DegPerHour
    let remainderHour = hours.truncatingRemainder(dividingBy: 1.0)
    return Int(remainderHour * 60.0)
  }

  var sec: Int {
    let hours = degrees / DegPerHour
    let remainderHour = hours.truncatingRemainder(dividingBy: 1.0)
    let remainderMin = (remainderHour * 60.0).truncatingRemainder(dividingBy: 1.0)
    return Int(remainderMin * 60.0 + sign * 0.5) // Round to nearest Second
  }
  
  static func + (left: Hms, right: Hms) -> Hms {
    return Hms(deg: left.degrees + right.degrees)
  }
  
  static func - (left: Hms, right: Hms) -> Hms {
    return Hms(deg: left.degrees - right.degrees)
  }
}
