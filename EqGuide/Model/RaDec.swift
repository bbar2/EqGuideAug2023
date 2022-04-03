//
//  RaDec.swift
//  EqGuide
//
//  Created by Barry Bryant on 3/28/22.
//

import SwiftUI

class RaDec : ObservableObject {
  @Published var ra: Float
  @Published var dec: Float
  
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
