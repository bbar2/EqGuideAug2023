//
//  EqGuideApp.swift
//  EqGuide
//
//  Created by Barry Bryant on 1/6/22.
//

import SwiftUI

@main
struct EqGuideApp: App {
  
  // keep model in scope, as views change
  @StateObject private var guideModel = GuideModel()
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(guideModel)
    }
  }
}
