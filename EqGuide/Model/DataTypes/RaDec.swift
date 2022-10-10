//
//  RaDec.swift
//  EqGuide
//
//  Object to hold the two angles required to point to an object.
//  Operators for calculating offsets between objects.
//  ra = Right Ascension.  0 to 360 degrees when specified in decimal degrees.
//  dec = Declination.  -180 to 180 degrees when specified in decimal degrees.
//    Although typical usage is -90 <= dec <= 90
//    Can use |dec| > 90 if ra and LST, cause armAngle to exceed its limit of about +-95
//    Tranform (RA, DEC) to (RA+180º, 180º-DEC) or (RA+12H, 180º-DEC)
//

import SwiftUI

struct RaDec {
  private var _ra: Double
  private var _dec: Double
  
  init(ra: Double = 0.0, dec: Double = 0.0) {
    _ra = ra.truncatingRemainder(dividingBy: 360.0)
    _dec = dec.truncatingRemainder(dividingBy: 360.0)
    _dec = mapTo180(_dec);
  }
  
  var ra: Double {
    get {
      return _ra
    }
    set {
      _ra = newValue.truncatingRemainder(dividingBy: 360.0)
    }
  }
  
  var dec: Double {
    get {
      return _dec
    }
    set {
      _dec = newValue.truncatingRemainder(dividingBy: 360.0)
      _dec = mapTo180(_dec)
    }
  }
  
//  // Removed - do this to arm and disk angles, not RA and DEC
//  // Use inverted RA/DEC with DEC > 90, if RA is unachievable by mount
//  mutating func raInvert() {
//    _ra = _ra + 180.0
//    _dec = mapTo180(180.0 - _dec);
//  }
  
  static func + (left: RaDec, right: RaDec) -> RaDec {
    return RaDec(ra: left._ra + right._ra, dec: left._dec + right._dec)
  }
  
  static func - (left: RaDec, right: RaDec) -> RaDec {
    return RaDec(ra: left._ra - right._ra, dec: left._dec - right._dec)
  }
  
  private func mapTo180(_ input: Double) -> Double {
    if input > 180.0 {
      return input - 360.0
    } else if input <= -180.0 {
      return input + 360.0
    } else {
      return input
    }
  }

}
