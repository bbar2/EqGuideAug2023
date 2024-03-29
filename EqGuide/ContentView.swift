//
//  ContentView.swift
//  Guide
//
//  Created by Barry Bryant on 12/18/21.
//

import SwiftUI


struct ContentView: View {

  // Each model is associated with a different BLE Peripheral device
  // .onAppear puts focusDeviceModel and pierDeviceModel links in mountDeviceModel
  // Passing mountDeviceModel gives access to all model objects
  @StateObject private var mountDeviceModel = MountBleModel()
  @StateObject private var focusDeviceModel = FocusBleModel()
  @StateObject private var pierDeviceModel = PierBleModel()
  @StateObject private var locationData = LocationData()

  // ViewOptions at App scope
  @EnvironmentObject var viewOptions: ViewOptions

  @Environment(\.scenePhase) var scenePhase

  enum Tab {
    case manual
    case guide
    case hardware
    case rate
    case focus
//    case light
  }
  
  @State private var selection: Tab = .manual
  var body: some View {
    
    TabView (selection: $selection) {
      ManualView(mountModel: mountDeviceModel)
        .tabItem {
          Label("Manual", systemImage: "arrow.up.and.down.and.arrow.left.and.right")
        }
        .tag(Tab.manual)
      
      GuideView(mountModel: mountDeviceModel)
        .tabItem {
          Label("Guide", systemImage: "arrow.2.squarepath")
        }
        .tag(Tab.guide)
      
      HardwareView(mountModel: mountDeviceModel)
        .tabItem {
          Label("Hardware", systemImage: "angle")
        }
        .tag(Tab.hardware)

      RaRateView(mountModel: mountDeviceModel)
        .tabItem {
          Label("Track Rate", systemImage: "cursorarrow.click.badge.clock")
        }
        .tag(Tab.rate)
      
      FocusView(focusModel: focusDeviceModel, pierModel: pierDeviceModel)
        .tabItem {
          Label("Focus", systemImage: "staroflife.circle")
        }
        .tag(Tab.focus)

//      LightView()
//        .tabItem {
//          Label("Light", systemImage: "flashlight.off.fill")
//            .preferredColorScheme(.dark)
//        }
//        .tag(Tab.light)
    }
    .statusBarHidden(true)
    .accentColor(viewOptions.appRedColor)
    .onChange(of: scenePhase) { newPhase in
      if newPhase == .active {
//        print("ScenePhase = Active")
      } else if newPhase == .inactive {
        mountDeviceModel.endXlControl()
//        print("ScenePhase = Inactive")
      } else if newPhase == .background {
        mountDeviceModel.endXlControl()
//        print("ScenePhase = Background")
      } else {
        mountDeviceModel.endXlControl()
        print("ScenePhase = ?")
      }
    }
    .onAppear {
      mountDeviceModel.mountModelInit()
      mountDeviceModel.pierModelLink = pierDeviceModel
      mountDeviceModel.focusModelLink = focusDeviceModel
      mountDeviceModel.locationDataLink = locationData
      viewOptions.setupSegmentControl()
    }
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
