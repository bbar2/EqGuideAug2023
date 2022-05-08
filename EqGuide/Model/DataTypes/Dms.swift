//
//  Dms.swift
//  EqGuide
//
//  Created by Barry Bryant on 3/30/22.
//
// Dms is either Float Degrees or DMS integers, where:
//   -180 < D <= 180, 0<=M<60, 0<=S<60
//
// To operate with a 0 to 360 range, comment out mapTo180
//
// D, M, and S should all have the same sign.  DMS is mathamaticaly correct
// with different signs, but it's not meaningful.
//
// Although Declination angles are limited to -90 <= Declination <= 90,
// that limit is not enforced in this DMS implementation.
//

struct Dms {
  private var _degrees: Double
  
  let MinPerDeg = Double(60.0)
  let SecPerDeg = Double(60.0 * 60.0)
  
  init(_ deg: Double) {
    _degrees = deg.truncatingRemainder(dividingBy: 360.0)
    mapTo180()
    buildDmsTermsFromDegrees()
  }
  
  private mutating func mapTo180() {
    if _degrees > 180.0 {
      _degrees -= 360.0
    } else if _degrees <= -180.0 {
      _degrees += 360.0
    }
  }

  init (d:Int, m:Int, s:Int) {
    _degrees = Double(
      Double(d) +
      Double(m) / 60.0 +
      Double(s) / 3600.0
    ).truncatingRemainder(dividingBy: 360.0)
    mapTo180()
    buildDmsTermsFromDegrees()
  }
  
  private var _d = Int(0.0)
  private var _m = Int(0.0)
  private var _s = Int(0.0)
  
  private mutating func buildDmsTermsFromDegrees() {
    let roundingTerm = self.sign * Double(0.5)
    let totalSeconds = Int(_degrees * 3600 + roundingTerm)
    _s = totalSeconds % 60
    let totalMinutes = totalSeconds / 60
    _m = totalMinutes % 60
    _d = totalMinutes / 60
  }
  
  var degrees: Double {
    get {
      return _degrees
    }
    set {
      _degrees = newValue.truncatingRemainder(dividingBy: 360.0)
      mapTo180()
      buildDmsTermsFromDegrees()
    }
  }

  var sign:Double {
    return _degrees < 0.0 ? -1.0 : 1.0
  }
  
  var d: Int {
    get {
      return _d
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
  
  func string(_ inDms: Bool = true) -> String {
    if inDms {
      if degrees >= 0 {
        return String(format: " %02dº%02d'%02d\"", d, m, s)
      } else {
        return String(format: "-%02dº%02d'%02d\"", -d, -m, -s)
      }
    } else {
      return String(format: "%.02fº", degrees)
    }
  }
  
  static func + (left: Dms, right: Dms) -> Dms {
    return Dms(left.degrees + right.degrees)
  }
  
  static func - (left: Dms, right: Dms) -> Dms {
    return Dms(left.degrees - right.degrees)
  }
  
}
