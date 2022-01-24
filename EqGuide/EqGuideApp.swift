//
//  EqGuideApp.swift
//  EqGuide
//
//  Created by Barry Bryant on 1/6/22.
//

import SwiftUI

@main
struct EqGuideApp: App {
  
  // keep model in scope, even as views change
  var appLevelGuideModel = GuideModel()
  
  var body: some Scene {
    WindowGroup {
      ContentView(guideModel: appLevelGuideModel)
    }
  }
}
