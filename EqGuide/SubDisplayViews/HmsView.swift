//
//  hmsView.swift
//  EqGuide
//
//  Created by Barry Bryant on 3/26/22.
//

import SwiftUI

struct HmsView: View {
  var angleDegrees: Float
  
  var body: some View {
    let hms = Hms(deg: angleDegrees)
    VStack {
      let decimalDegString = String(format: "%.2f deg", angleDegrees)
      let dmsString = String(format: "%dh   %dm   %ds",
                             hms.h, hms.m, hms.s)
      Text(decimalDegString)//.padding(2)
      Text(dmsString)//.padding(2)
    }
  }
}

struct hmsView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      HmsView(angleDegrees: Float(0.0) )
      HmsView(angleDegrees: Float(-45.0) )
      HmsView(angleDegrees: Float(45.0) )
      HmsView(angleDegrees: Hms(h: -23, m: -59, s: -59).degrees)
      HmsView(angleDegrees: Hms(h: 23, m: 59, s: 59).degrees)
    }
    .previewLayout(.fixed(width: 300, height: 70))
  }
}
