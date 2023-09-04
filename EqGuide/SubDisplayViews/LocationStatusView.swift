//
//  LocationStatusView.swift
//  EqGuide
//
//  Created by Barry Bryant on 9/3/23.
//

import SwiftUI

struct LocationStatusView: View {
  var knowledge: LocationKnowledge

  @EnvironmentObject var viewOptions: ViewOptions

  func knowledgeColor(_ knowledge: LocationKnowledge) -> Color {
    switch (knowledge)
    {
      case .none:
        return viewOptions.confNoneColor
      case .alt:
        return viewOptions.confEstColor
      case .gps:
        return viewOptions.appRedColor
    }
  }

  var body: some View {
    Text("GPS").foregroundColor(knowledgeColor(knowledge))
  }
}

struct LocationStatusView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      LocationStatusView(knowledge: .none)
      LocationStatusView(knowledge: .alt)
      LocationStatusView(knowledge: .gps)
    }.previewLayout(.fixed(width: 400, height: 150))
      .preferredColorScheme(.dark)
      .environmentObject(ViewOptions())
  }
}
