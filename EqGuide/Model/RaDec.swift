//
//  RaDec.swift
//  EqGuide
//
//  Created by Barry Bryant on 3/28/22.
//

struct RaDec {
  var ra:Float = 0.0
  var dec:Float = 0.0
  
  static func + (left: RaDec, right: RaDec) -> RaDec {
    return RaDec(ra: left.ra + right.ra, dec: left.dec + right.dec)
  }
  
  static func - (left: RaDec, right: RaDec) -> RaDec {
    return RaDec(ra: left.ra - right.ra, dec: left.dec - right.dec)
  }
}
