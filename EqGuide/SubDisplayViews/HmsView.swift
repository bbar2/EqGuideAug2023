//
//  hmsView.swift
//  EqGuide
//
//  Created by Barry Bryant on 3/26/22.
//

import SwiftUI

struct HmsView: View {
  var angleDegrees: Double
  
  var body: some View {
    let hms = Hms(deg: angleDegrees)
    VStack {
      let decimalDegString = String(format: "%.2f deg", hms.degrees)
      let dmsString = String(format: "%dh   %dm   %ds",
                             hms.h, hms.m, hms.s)
      Text(decimalDegString)
      Text(dmsString)
    }
  }
}

struct hmsView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      HmsView(angleDegrees:   0.0 )
      HmsView(angleDegrees: -45.0 )
      HmsView(angleDegrees: 110.0 )
      HmsView(angleDegrees: Hms(h: -23, m: -59, s: -59).degrees)
      HmsView(angleDegrees: Hms(h: 23, m: 59, s: 59).degrees)
    }
    .previewLayout(.fixed(width: 300, height: 70))
  }
}
