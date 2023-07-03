//
//  StopControlView.swift
//
//  Controls to HALT or StopTracking.
//  Used by multiple TopTabViews.
//
//  Created by Barry Bryant on 6/17/23.
//

import SwiftUI

struct StopControlView: View {
  @ObservedObject var mountModel: MountBleModel
  @EnvironmentObject var viewOptions: ViewOptions
  
  var body: some View {
    HStack {
      // Reset Button on Left
      BigButton(label: "RESET", minWidth: 175) {
        mountModel.guideCommandReset()
        heavyBump()
      }
      Spacer()
      if (mountModel.raIsTracking) {
        BigButton(label: "Pause\nTracking", minWidth: 150) {
          mountModel.pauseTracking()
          softBump()
        }
      } else {
        BigButton(label: "Resume\nTracking", minWidth: 150, textColor: Color.yellow) {
          mountModel.resumeTracking()
          softBump()
        }
      }

    }.padding([.bottom], 10)
  }
}

struct StopControlView_Previews: PreviewProvider {
  static let previewGuideModel = MountBleModel()
  static let viewOptions = ViewOptions()
  
  static var previews: some View {
    StopControlView(mountModel: previewGuideModel)
      .previewLayout(.fixed(width: 300, height: 70))
      .preferredColorScheme(.dark)
  }
  //  .foregroundColor(viewOptions.appRedColor)
}

