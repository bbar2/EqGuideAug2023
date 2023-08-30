//
//  TabTitleView.swift
//  EqGuide
//
//  Created by Barry Bryant on 8/28/23.
//

import SwiftUI

struct TabTitleView: View {
  var label:String
  @ObservedObject var mountModel: MountBleModel
  @EnvironmentObject var viewOptions: ViewOptions

  var body: some View {
    VStack {
      Text(label).font(viewOptions.appHeaderFont)
      HStack {
        RaFormatControl()
        Spacer()
        DegreeFormatControl()
      }
      StatusBarView(mountModel: mountModel)
    }
  }
}

struct TabTitleView_Previews: PreviewProvider {
  static let previewGuideModel = MountBleModel()
  static let viewOptions = ViewOptions()

  static var previews: some View {
    TabTitleView(label: "PreView", mountModel: previewGuideModel)
    .previewLayout(.fixed(width: 400, height: 250))
    .preferredColorScheme(.dark)
    .environmentObject(viewOptions)
  }
}
