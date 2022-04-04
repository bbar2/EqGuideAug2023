//
//  RaDec.swift
//  EqGuide
//
//  Object to hold the two angles required to point to an object.
//  Operators for calculating offsets between objects.
//  ra = Right Ascension.  0 to 360 degrees when specified in decimal degrees.
//  dec = Declination.  0 to 180 degrees when speciried in decimal degrees.
//

import SwiftUI

struct RaDec {
  var ra: Float
  var dec: Float
  
  init(ra: Float = 0.0, dec: Float = 0.0) {
    self.ra = ra;
    self.dec = dec;
  }
  
  static func + (left: RaDec, right: RaDec) -> RaDec {
    return RaDec(ra: left.ra + right.ra, dec: left.dec + right.dec)
  }
  
  static func - (left: RaDec, right: RaDec) -> RaDec {
    return RaDec(ra: left.ra - right.ra, dec: left.dec - right.dec)
  }
}
