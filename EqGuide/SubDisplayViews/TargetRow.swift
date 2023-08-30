//
//  TargetRow.swift
//  EqGuide
//
//  Created by Barry Bryant on 5/5/22.
//

import SwiftUI

struct TargetRow: View {

  @EnvironmentObject var viewOptions: ViewOptions

  var target: Target
  var lstDeg: Double
  
  var body: some View {
    VStack {
      HStack {
        VStack (alignment: .leading) {
          Text(target.name).bold()
          Text(target.constellation + " " + target.category.rawValue)
        }
        Spacer()
        VStack (alignment: .trailing) {
          if viewOptions.showRaAsHA {
            Text("HA: " + Hms(lstDeg - target.ra).string(viewOptions.showDmsHms))
          } else {
            Text("RA: " + Hms(target.ra).string(viewOptions.showDmsHms))
          }
          Text("DEC: " + Dms(target.dec).string(viewOptions.showDmsHms))
        }
      }
    }
  }
}

struct TargetRow_Previews: PreviewProvider {
  static let guideModel = MountBleModel()
  @State static var viewOptions = ViewOptions()

  static var previews: some View {
    Group {
      TargetRow(target: guideModel.catalog[0], lstDeg: 0.0)
    }
    .previewLayout(.fixed(width: 300, height: 70))
    .preferredColorScheme(.dark)
    .foregroundColor(viewOptions.appRedColor)

    
  }
}
