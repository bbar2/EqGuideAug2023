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
  
  // TODO: Put this in mountModel.  Had trouble accessing viewOptions from mountModel.
  // It's also used by HardwareView, so duplicated for now.
  func pointingKnowledgeColor() -> Color {
    switch (mountModel.pointingKnowledge)
    {
      case .none:
        return viewOptions.confNoneColor
      case .estimated:
        return viewOptions.confEstColor
      case .marked:
        return viewOptions.appRedColor
    }
  }
  
  var body: some View {
    
    VStack {
      VStack {
        Text("Manual Control").font(viewOptions.appHeaderFont)
      }
      
      Spacer()

      RaDecPairView(
        pairTitle: "Current\nPosition",
        pair: mountModel.currentPosition,
        showDmsHms: viewOptions.showDmsHms,
        pierDeg: mountModel.pierCurrentDeg,
        diskDeg: mountModel.diskCurrentDeg
      )
      .foregroundColor(pointingKnowledgeColor())
//      .padding([.bottom], 1)

      HStack {
        if ((mountModel.pierModelLink?.bleConnected()) != nil)
        {
          Spacer()
          BigButton(label:"HOME") {
            mountModel.goHome()
            heavyBump()
          }
          Spacer()
          BigButton(label:"EAST") {
            mountModel.goEastPier()
            heavyBump()
          }
          Spacer()
        }
        else
        {
          Spacer()
          BigButton(label:"HOME",
                    textColor: viewOptions.appDisabledColor) {
            softBump()
          }
          Spacer()
          BigButton(label:"EAST\nPIER",
                    textColor: viewOptions.appDisabledColor) {
            softBump()
          }
          Spacer()
        }
      }
      
      Spacer()
      
      ArrowPadView(mountModel: mountModel)
      
      Spacer()
      
      StopControlView(mountModel: mountModel)

      StatusBarView(mountModel: mountModel)

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
