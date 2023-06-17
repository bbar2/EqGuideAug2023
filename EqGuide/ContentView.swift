//
//  ContentView.swift
//  Guide
//
//  Created by Barry Bryant on 12/18/21.
//

import SwiftUI


struct ContentView: View {

  // Models at Local scope.
  // Each model is associated with a different BLE Peripheral device
  // Pass to Views as needed.
  @StateObject private var mountDeviceModel = MountBleModel()
  @StateObject private var focusDeviceModel = FocusBleModel()
  @StateObject private var armDeviceModel = ArmBleModel()

  // ViewOptions at App scope
  @EnvironmentObject var viewOptions: ViewOptions

  enum Tab {
    case guide
    case manual
    case rate
    case focus
    case hardware
//    case light
  }
  
  @State private var selection: Tab = .guide
  var body: some View {
    
    TabView (selection: $selection) {
      GuideView(mountModel: mountDeviceModel)
        .tabItem {
          Label("Guide", systemImage: "arrow.2.squarepath")
        }
        .tag(Tab.guide)
      
      ManualView(mountModel: mountDeviceModel, armModel: armDeviceModel)
        .tabItem {
          Label("Manual", systemImage: "arrow.up.and.down.and.arrow.left.and.right")
        }
        .tag(Tab.manual)
      
      RaRateView(mountModel: mountDeviceModel)
        .tabItem {
          Label("Track Rate", systemImage: "cursorarrow.click.badge.clock")
        }
        .tag(Tab.rate)

      FocusView(focusModel: focusDeviceModel, armModel: armDeviceModel)
        .tabItem {
          Label("Focus", systemImage: "staroflife.circle")
        }
        .tag(Tab.focus)
      
      HardwareView(mountModel: mountDeviceModel,
                   focusModel: focusDeviceModel,
                   armModel: armDeviceModel)
        .tabItem {
          Label("Hardware", systemImage: "angle")
        }
        .tag(Tab.hardware)

//      LightView()
//        .tabItem {
//          Label("Light", systemImage: "flashlight.off.fill")
//            .preferredColorScheme(.dark)
//        }
//        .tag(Tab.light)
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
