//
//  StatusBar.swift
//  EqGuide
//
//  Created by Barry Bryant on 7/6/23.
//

import SwiftUI

struct StatusBarView: View {
  @ObservedObject var mountModel: MountBleModel

  @EnvironmentObject var viewOptions: ViewOptions

  var body: some View {
    HStack {
      PierModeView(pierMode: mountModel.pierMode)
      Spacer()
      BleStatusView(mountModel: mountModel)
    }
  }
}

struct StatusBarView_Previews: PreviewProvider {
  static let previewGuideModel = MountBleModel()
  static let viewOptions = ViewOptions()
  static var previews: some View {
    StatusBarView(mountModel: previewGuideModel)
    .previewLayout(.fixed(width: 400, height: 150))
    .preferredColorScheme(.dark)
    .environmentObject(viewOptions)
  }
}

