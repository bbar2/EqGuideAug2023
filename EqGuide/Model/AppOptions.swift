//
//  AppOptions.swift
//  EqGuide
//
//  Created by Barry Bryant on 4/8/22.
//

import Foundation

class AppOptions : ObservableObject {
  var fontSize: Int;
  
  init() {
    fontSize = Int(3)
  }
}
