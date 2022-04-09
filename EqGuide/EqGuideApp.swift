//
//  EqGuideApp.swift
//  EqGuide
//
//  Created by Barry Bryant on 1/6/22.
//

import SwiftUI

@main
struct EqGuideApp: App {
  
  // App level options into Environment
  @StateObject private var appOptions = AppOptions()
  
  // Model at App scope.  Pass to Views as needed.
  @StateObject private var guideModel = GuideModel()
  
  var body: some Scene {
    WindowGroup {
      ContentView(guideModel: guideModel)
        .environmentObject(appOptions)
    }
  }
  
}
