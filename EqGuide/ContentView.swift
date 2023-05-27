//
//  ContentView.swift
//  Guide
//
//  Created by Barry Bryant on 12/18/21.
//

import SwiftUI


struct ContentView: View {

  // Models at Local scope.  Pass to Views as needed.
  @StateObject private var model = GuideModel()
  @StateObject private var armAccelModel = ArmAccelModel()
  
  // ViewOptions at App scope
  @EnvironmentObject var viewOptions: ViewOptions

  enum Tab {
    case guide
    case rate
    case focus
    case light
  }
  
  @State private var selection: Tab = .guide
  var body: some View {
    
    TabView (selection: $selection) {
      GuideView(guideModel: model)
        .tabItem {
          Label("Guide", systemImage: "arrow.2.squarepath")
        }
        .tag(Tab.guide)
      
      RaRateView(guideModel: model)
        .tabItem {
          Label("Track Rate", systemImage: "cursorarrow.click.badge.clock")
        }
        .tag(Tab.rate)

      FocusView(armModel: armAccelModel)
        .tabItem {
          Label("Focus", systemImage: "staroflife.circle")
        }
        .tag(Tab.focus)
 
      LightView()
        .tabItem {
          Label("Light", systemImage: "flashlight.off.fill")
            .preferredColorScheme(.dark)
        }
        .tag(Tab.light)
    }
    .statusBar(hidden: true)
    .accentColor(viewOptions.appRedColor)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
      .previewInterfaceOrientation(.portrait)
      .environmentObject(ViewOptions())
      .preferredColorScheme(.dark)
  }
}
