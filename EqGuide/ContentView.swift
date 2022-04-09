//
//  ContentView.swift
//  Guide
//
//  Created by Barry Bryant on 12/18/21.
//

import SwiftUI


struct ContentView: View {
  
  @ObservedObject var guideModel:GuideModel
  
  enum Tab {
    case focus
    case guide
  }
  
  @State private var selection: Tab = .guide
  
  var body: some View {
    
    TabView (selection: $selection) {
      GuideView(guideModel: guideModel)
        .tabItem {
          Label("Guide", systemImage: "arrow.2.squarepath")
        }
        .tag(Tab.guide)
      
      FocusView()
        .tabItem {
          Label("Focus", systemImage: "staroflife.circle")
        }
        .tag(Tab.focus)
    }
    
  }
  
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(guideModel: GuideModel())
      .previewDevice(PreviewDevice(rawValue: "iPhone Xs"))
      .previewInterfaceOrientation(.portrait)
  }
}

