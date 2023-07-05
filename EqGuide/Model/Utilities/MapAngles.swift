//
//  MapAngles.swift
//  EqGuide
//
//  Created by Barry Bryant on 7/3/23.
//

import Foundation

extension Double {
  // Return angle so: 0 <= angle < 360.  Inputs can be pos or neg.
  // 360 maps to 0
  func mapAngle0To360() -> Double {
    var mappedValue = self.truncatingRemainder(dividingBy: 360.0)
    if mappedValue < 0.0 {
      mappedValue += 360.0
    }
    return mappedValue
  }
  
  // Return angle so: -180.0 <= angle < 180.0.  Inputs can be pos or neg.
  // 180 maps to -180
  func mapAnglePm180() ->Double {
    var mappedValue = self.clampAngle0To360()
    if mappedValue >= 180.0 {
      mappedValue -= 360.0
    }
    return mappedValue
  }
}
