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
// ToDo - Update for appropriate range of +90 to -90.
// Really - If |deg| >  90, implies change RA by 12 Hr

struct Dms {
  private var _degrees: Float32
  
  let MinPerDeg = Float32(60.0)
  let SecPerDeg = Float32(60.0 * 60.0)
  
  init(deg: Float32) {
    _degrees = deg
    buildDmsTermsFromDegrees()
  }

  init (d:Int32, m:Int32, s:Int32) {
    _degrees = Float32(
      Float32(d) +
      Float32(m) / 60.0 +
      Float32(s) / 3600.0
    ).truncatingRemainder(dividingBy: 360.0)
    buildDmsTermsFromDegrees()
  }
  
  private var _d = Int32(0.0)
  private var _m = Int32(0.0)
  private var _s = Int32(0.0)
  
  private mutating func buildDmsTermsFromDegrees() {
    let roundingTerm = self.sign * Float32(0.5)
    let totalSeconds = Int32(_degrees * 3600 + roundingTerm)
    _s = totalSeconds % 60
    let totalMinutes = totalSeconds / 60
    _m = totalMinutes % 60
    _d = totalMinutes / 60
  }
  
  var degrees: Float {
    get {
      return _degrees
    }
    set {
      _degrees = newValue.truncatingRemainder(dividingBy: 360.0)
      buildDmsTermsFromDegrees()
    }
  }

  var sign:Float32 {
    return _degrees < 0.0 ? -1.0 : 1.0
  }
  
  var d: Int32 {
    get {
      return _d
    }
  }
  
  var m: Int32 {
    get {
      return _m
    }
  }
        
  var s: Int32 {
    get {
      return _s
    }
  }

  static func + (left: Dms, right: Dms) -> Dms {
    return Dms(deg: left.degrees + right.degrees)
  }
  
  static func - (left: Dms, right: Dms) -> Dms {
    return Dms(deg: left.degrees - right.degrees)
  }

}
