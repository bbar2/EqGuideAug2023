//
//  EqGuideApp.swift
//  EqGuide
//
//  Created by Barry Bryant on 1/6/22.
//

import SwiftUI

@main
struct EqGuideApp: App {
  // viewOptions shared across all top level tabs
  @StateObject var viewOptions = ViewOptions()
  
  // App level options into Environment
  @StateObject private var appOptions = AppOptions()

  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .previewDevice(PreviewDevice(rawValue: "iPhone Xs"))
        .preferredColorScheme(.dark)
        .foregroundColor(viewOptions.appRedColor)
        .environmentObject(viewOptions)
    }
  }
  
}
