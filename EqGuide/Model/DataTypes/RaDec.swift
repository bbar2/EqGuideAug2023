//
//  RaDec.swift
//  EqGuide
//
//  Object to hold the two angles (in degrees) required to point to an object.
//  Operators for calculating offsets between objects.
//  ra = Right Ascension.  0 <= ra < 360 degrees when specified in decimal degrees.
//  dec = Declination.  -180 <= dec < 180 degrees when specified in decimal degrees.
//    Typical dec usage is -90 <= dec <= 90
//

import SwiftUI

struct RaDec {
  private var _ra: Double
  private var _dec: Double
  
  init(ra: Double = 0.0, dec: Double = 0.0) {
    _ra = ra.truncatingRemainder(dividingBy: 360.0)
    _dec = dec.truncatingRemainder(dividingBy: 360.0)
    _dec = _dec.mapAnglePm180();
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
      _dec = _dec.mapAnglePm180()
    }
  }
    
  static func + (left: RaDec, right: RaDec) -> RaDec {
    return RaDec(ra: left._ra + right._ra, dec: left._dec + right._dec)
  }
  
  static func - (left: RaDec, right: RaDec) -> RaDec {
    return RaDec(ra: left._ra - right._ra, dec: left._dec - right._dec)
  }
  
}
