//
//  hmsView.swift
//  EqGuide
//
//  Created by Barry Bryant on 3/26/22.
//

import SwiftUI

struct HmsView: View {
  var angle:Float
  
  var body: some View {
    let hms = Hms(deg: angle)
    VStack {
      let decimalDegString = String(format: "%.2f deg", angle)
      let dmsString = String(format: "%dh   %d'   %d\"",
                             hms.hour, hms.min, hms.sec)
      Text(decimalDegString)//.padding(2)
      Text(dmsString)//.padding(2)
    }
  }
}

struct hmsView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      HmsView(angle: Float(0.0) )
      HmsView(angle: Float(-45.0) )
      HmsView(angle: Float(45.0) )
      HmsView(angle: Hms(h: -23, m: -59, s: -59).degrees)
      HmsView(angle: Hms(h: 23, m: 59, s: 59).degrees)
    }
    .previewLayout(.fixed(width: 300, height: 70))
  }
}
