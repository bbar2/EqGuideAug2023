//
//  BleStatusView.swift
//  EqGuide
//
//  Created by Barry Bryant on 5/27/23.
//

import SwiftUI
struct BleStatusView: View {
  @ObservedObject var mountModel: MountBleModel
  @ObservedObject var focusModel: FocusBleModel
  @ObservedObject var armModel: ArmBleModel

  @EnvironmentObject var viewOptions: ViewOptions

  var body: some View {
    HStack {
      Text("Mount").foregroundColor((mountModel.bleConnected() ?
                                     viewOptions.appRedColor :
                                      viewOptions.noBleColor) )
      Text("Focus").foregroundColor((focusModel.bleConnected() ?
                                     viewOptions.appRedColor :
                                      viewOptions.noBleColor) )
      Text("Arm").foregroundColor((armModel.bleConnected() ?
                                   viewOptions.appRedColor :
                                    viewOptions.noBleColor) )
    }
  }
}

struct BleStatusView_Previews: PreviewProvider {
  static let previewGuideModel = MountBleModel()
  static let previewFocusModel = FocusBleModel()
  static let previewArmModel = ArmBleModel()
  static let viewOptions = ViewOptions()
  static var previews: some View {
    BleStatusView(mountModel: previewGuideModel,
                  focusModel: previewFocusModel,
                  armModel: previewArmModel)
    .previewLayout(.fixed(width: 400, height: 150))
    .preferredColorScheme(.dark)
    .environmentObject(viewOptions)
  }
}

