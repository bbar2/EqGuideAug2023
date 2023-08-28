//
//  MapAngles.swift
//  EqGuide
//
//  Created by Barry Bryant on 7/3/23.
//  Double extensions for dealing with angles

import Foundation

public extension Double {

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
    var mappedValue = self.mapAngle0To360()
    if mappedValue >= 180.0 {
      mappedValue -= 360.0
    }
    return mappedValue
  }
  
  // Returns -360 < degrees < 360
  func radToDeg() -> Double {
    let degrees = self * 180.0 / Double.pi
    return degrees.truncatingRemainder(dividingBy: 360.0)
  }

  // Returns -2pi < rads < 2pi
  func degToRad() -> Double {
    let radians = self * Double.pi / 180.0
    return radians.truncatingRemainder(dividingBy: 2.0*Double.pi)
  }
  
  // Returns -24.0 < hours < 24.0
  func degToHrs() -> Double {
    let hours = self / 15.0
    return hours.truncatingRemainder(dividingBy: 24.0)
  }
  
  // Returns -360 < degrees < 360
  func hrsToDeg() -> Double {
    let degrees = self * 15.0
    return degrees.truncatingRemainder(dividingBy: 360.0)
  }

}
