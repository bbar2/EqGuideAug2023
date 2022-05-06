//
//  TargetRow.swift
//  EqGuide
//
//  Created by Barry Bryant on 5/5/22.
//

import SwiftUI

struct TargetRow: View {
  var target: Target
  
  var body: some View {
    VStack {
      HStack {
        VStack (alignment: .leading) {
          Text(target.name).bold()
          Text(target.constellation)
        }
        Spacer()
        VStack (alignment: .trailing) {
          Text(String(format:"RA: %.2f", target.ra))
          Text(String(format:" DEC: %.2f", target.dec))
        }
      }
    }
  }
}

struct TargetRow_Previews: PreviewProvider {
  static let guideModel = GuideModel()
  @State static var viewOptions = ViewOptions()

  static var previews: some View {
    Group {
      TargetRow(target: guideModel.catalog[0])
    }
    .previewLayout(.fixed(width: 300, height: 70))
    .preferredColorScheme(.dark)
    .foregroundColor(viewOptions.appRedColor)

    
  }
}
