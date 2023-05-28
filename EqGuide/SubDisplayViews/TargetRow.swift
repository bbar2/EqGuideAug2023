//
//  TargetRow.swift
//  EqGuide
//
//  Created by Barry Bryant on 5/5/22.
//

import SwiftUI

struct TargetRow: View {
  var target: Target
  var unitHmsDms: Bool
  
  var body: some View {
    VStack {
      HStack {
        VStack (alignment: .leading) {
          Text(target.name).bold()
          Text(target.constellation + " " + target.category.rawValue)
        }
        Spacer()
        VStack (alignment: .trailing) {
          Text("RA: " + Hms(target.ra).string(unitHmsDms))
          Text("DEC: " + Dms(target.dec).string(unitHmsDms))
        }
      }
    }
  }
}

struct TargetRow_Previews: PreviewProvider {
  static let guideModel = MountPeripheralModel()
  @State static var viewOptions = ViewOptions()

  static var previews: some View {
    Group {
      TargetRow(target: guideModel.catalog[0], unitHmsDms: true)
      TargetRow(target: guideModel.catalog[0], unitHmsDms: false)
    }
    .previewLayout(.fixed(width: 300, height: 70))
    .preferredColorScheme(.dark)
    .foregroundColor(viewOptions.appRedColor)

    
  }
}
