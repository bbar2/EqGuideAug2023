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
  @ObservedObject var armModel: ArmBleModel
  
  @EnvironmentObject var viewOptions: ViewOptions

  @State private var canTouchDown = true

  var body: some View {
    
    VStack {
      
      Text("Manual Control").font(.title)
      
      Spacer()
      
      HStack {
        Spacer()
        BigButton(label:"HOME") {
          mountModel.goHome()
          heavyBump()
        }
        Spacer()
        BigButton(label:"EAST\nPIER") {
          mountModel.goEastPier()
          heavyBump()
        }
        Spacer()
      }
      
      Spacer()
      
      ArrowPadView(mountModel: mountModel)
      
      Spacer()
      
      StopControlView(mountModel: mountModel)
            
    } // end Main VStack
    .onAppear {
      // MountBleModel needs access to ArmBleModel
      mountModel.linkArmModel(armModel)
    }

  }

}

struct ManualView_Previews: PreviewProvider {
  static let viewOptions = ViewOptions()
  static let previewGuideModel = MountBleModel()
  static let previewArmModel = ArmBleModel()

  static var previews: some View {
    ManualView(mountModel: previewGuideModel, armModel: previewArmModel)
      .environmentObject(viewOptions)
      .preferredColorScheme(.dark)
      .foregroundColor(viewOptions.appRedColor)
  }
}
