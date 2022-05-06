//
//  AppOptions.swift
//  EqGuide
//
//  Created by Barry Bryant on 4/8/22.
//

import Foundation

class AppOptions : ObservableObject {
  var showSecs: Bool
  var showDmsHms: Bool
  
  init() {
    showSecs = false
    showDmsHms = true
  }
  
}
