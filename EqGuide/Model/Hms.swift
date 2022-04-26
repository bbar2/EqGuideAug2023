//
//  Hms.swift
//  EqGuide
//
//  Created by Barry Bryant on 3/30/22.
//
// Right Ascension is either Float Degrees or HMS integers, where:
//   0 <= H < 24, 0 <= M < 60, 0 <= S < 60
//   Note Factor of 15 between 24 Hours and 360 Degrees.
//
// Negative HMS angles only make sense for Offsets between positions.
// H, M, & S will usually all have the same sign.  You can construnct with
// different signs, and it will work, but it's not too meaningful.
//
// _degrees is always clamped so (360.0 < deg < 360.0) before building HMS terms, so
// HMS terms are limited to: 0 <= H < 24

struct Hms {
  private var _degrees:Float

  let DegPerHour = Float(360.0 / 24.0)
  let MinPerHour = Float(60.0)
  let SecPerHour = Float(60.0 * 60.0)
  
  init(deg: Float) {
    _degrees = deg.truncatingRemainder(dividingBy: 360.0)
    buildHmsTermsFromDegrees()
  }

  init (h:Int, m:Int, s:Int) {
    _degrees = Float(
      Float(h) * DegPerHour +
      Float(m) * DegPerHour / MinPerHour +
      Float(s) * DegPerHour / SecPerHour
    ).truncatingRemainder(dividingBy: 360.0)
    buildHmsTermsFromDegrees()
  }
  
  private var _h = Int(0.0)
  private var _m = Int(0.0)
  private var _s = Int(0.0)
  
  private mutating func buildHmsTermsFromDegrees()
  {
    let roundingTerm = self.sign * 0.5
    let hours = _degrees / DegPerHour
    let totalSeconds = Int(hours * SecPerHour + roundingTerm)
    _s = totalSeconds % 60
    let totalMinutes = totalSeconds / 60
    _m = totalMinutes % 60
    _h = totalMinutes / 60
  }
  
  var degrees: Float {
    get {
      return _degrees
    }
    set {
      _degrees = newValue.truncatingRemainder(dividingBy: 360.0)
      buildHmsTermsFromDegrees()
    }
  }
  
  var sign:Float {
    return _degrees < 0.0 ? -1.0 : 1.0
  }
  
  var h: Int {
    get {
      return _h
    }
  }
  
  var m: Int {
    get {
      return _m
    }
  }

  var s: Int {
    get {
      return _s
    }
  }
  
  static func + (left: Hms, right: Hms) -> Hms {
    return Hms(deg: left._degrees + right._degrees)
  }
  
  static func - (left: Hms, right: Hms) -> Hms {
    return Hms(deg: left._degrees - right._degrees)
  }
}
