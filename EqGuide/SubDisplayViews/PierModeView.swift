//
//  PierMode.swift
//  EqGuide
//
//  Created by Barry Bryant on 7/5/23.
//

import SwiftUI
struct PierModeView: View {
  var pierMode:PierMode
  @EnvironmentObject var viewOptions: ViewOptions

  var body: some View {
    HStack {
      Text("PierMode: ").foregroundColor(viewOptions.appRedColor)
      switch pierMode {
        case .unknown:
          Text("Unknown").foregroundColor(viewOptions.noBleColor)
        case .east:
          Text("EastPier").foregroundColor(viewOptions.appRedColor)
        case .west:
          Text("WestPier").foregroundColor(viewOptions.appRedColor)
      }
    }.font(viewOptions.smallHeaderfont)
  }
}

struct PierModeView_Previews: PreviewProvider {
  static let viewOptions = ViewOptions()
  static var previews: some View {
    PierModeView(pierMode: PierMode.east)
    .previewLayout(.fixed(width: 400, height: 150))
    .preferredColorScheme(.dark)
    .environmentObject(viewOptions)
  }
}

