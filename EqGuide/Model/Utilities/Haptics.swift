//
//  Haptics.swift
//  EqGuide
//
//  Created by Barry Bryant on 4/23/22.
//
import SwiftUI

func heavyBump(){
  let haptic = UIImpactFeedbackGenerator(style: .heavy)
  haptic.impactOccurred()
}

func softBump(){
  let haptic = UIImpactFeedbackGenerator(style: .soft)
  haptic.impactOccurred()
}
