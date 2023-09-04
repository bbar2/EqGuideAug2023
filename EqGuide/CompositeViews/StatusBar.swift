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
  
  @State private var showOptions = false
  
  var body: some View {
    HStack {
      PierModeView(pierMode: mountModel.pierMode)
      Spacer()
      Button {
        showOptions = true
      } label: {
        let locationKnowledge = mountModel.locationDataLink?.knowledge ?? .none
        LocationStatusView(knowledge: locationKnowledge)
      }
      Spacer()
      BleStatusView(mountModel: mountModel)
    }
    .sheet(isPresented: $showOptions) {
      if let locationData = mountModel.locationDataLink {
        LocationOptionSheet(locData: locationData,
                            lstDeg: mountModel.lstDeg)
      } else {
        Text("ERROR: locationDataLink nil in StatusBar.swift")
      }
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

