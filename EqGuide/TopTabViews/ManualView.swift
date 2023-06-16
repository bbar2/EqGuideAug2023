//
//  ManualView.swift
//  Manual control view.  GUI version of hardware joystick, with additional
//  capability to drive to Home or East Pier based on accelerometer feedback.
//
//
//  Created by Barry Bryant on 6/9/23.
//

import SwiftUI

struct ManualView: View {
  @ObservedObject var mountModel: MountBleModel
  @EnvironmentObject var viewOptions: ViewOptions

  @State private var canTouchDown = true

  var body: some View {
    
    VStack {
      
      Text("Manual Control").font(.title)
      
      Spacer()
      
      HStack {
        Spacer()
        BigButton(label:"HOME") {
          heavyBump()
        }
        Spacer()
        BigButton(label:"EAST\nPIER") {
          heavyBump()
        }
        Spacer()
      }
      
      Spacer()
      
      ArrowPadView(mountModel: mountModel)
      
      Spacer()
      
      Toggle("RA Tracking", isOn: $mountModel.raIsTracking).toggleStyle(.automatic)
      
      Spacer()
      
    } // end Main VStack
    
  }
}

struct ManualView_Previews: PreviewProvider {
  static let viewOptions = ViewOptions()
  static let previewGuideModel = MountBleModel()

  static var previews: some View {
    ManualView(mountModel: previewGuideModel)
      .environmentObject(viewOptions)
      .preferredColorScheme(.dark)
      .foregroundColor(viewOptions.appRedColor)
  }
}
