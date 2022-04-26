//
//  AppOptions.swift
//  EqGuide
//
//  Created by Barry Bryant on 4/8/22.
//

import Foundation

class AppOptions : ObservableObject {
  var showSecs: Bool
  var editInFloat: Bool
  
  init() {
    showSecs = false
    editInFloat = true
  }
  
}
