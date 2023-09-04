//
//  BleStatusView.swift
//  EqGuide
//
//  Created by Barry Bryant on 5/27/23.
//

import SwiftUI
struct BleStatusView: View {
  @ObservedObject var mountModel: MountBleModel

  @EnvironmentObject var viewOptions: ViewOptions

  var body: some View {
    HStack {
      Text("Mount").foregroundColor(mountModel.bleConnected() ?
                                    viewOptions.appRedColor : viewOptions.noBleColor)
      Text("Pier").foregroundColor(mountModel.pierModelLink?.bleConnected() ?? false ?
                                   viewOptions.appRedColor : viewOptions.noBleColor)
      Text("Saddle").foregroundColor(mountModel.focusModelLink?.bleConnected() ?? false ?
                                    viewOptions.appRedColor : viewOptions.appDisabledColor)
    }.font(viewOptions.smallHeaderfont)
  }
}

struct BleStatusView_Previews: PreviewProvider {
  static let previewGuideModel = MountBleModel()
  static let viewOptions = ViewOptions()
  static var previews: some View {
    BleStatusView(mountModel: previewGuideModel)
    .previewLayout(.fixed(width: 400, height: 150))
    .preferredColorScheme(.dark)
    .environmentObject(viewOptions)
  }
}

