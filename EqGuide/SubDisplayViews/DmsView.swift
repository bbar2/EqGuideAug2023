//
//  dmsView.swift
//  EqGuide
//
//  Created by Barry Bryant on 3/26/22.
//

import SwiftUI

struct DmsView: View {
  var angleDegrees: Double
  
  var body: some View {
    let dms = Dms(deg: angleDegrees)
    VStack {
      let decimalDegString = String(format: "%.2f deg", dms.degrees)
      let dmsString = String(format: "%dº   %d'   %d\"",
                             dms.d, dms.m, dms.s)
      Text(decimalDegString)
      Text(dmsString)
    }
  }
}

struct dmsView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      DmsView(angleDegrees: 0.0)
      DmsView(angleDegrees: 180.0)
      DmsView(angleDegrees: -180.0)
      DmsView(angleDegrees: 90.0 + 28.0/60.0 + 2.0/3600.0)
      DmsView(angleDegrees: Dms(d:  359, m:  59, s:  59 ).degrees)
      DmsView(angleDegrees: Dms(d: -359, m: -59, s: -59 ).degrees)
      DmsView(angleDegrees: Dms(d: -360, m:   0, s:   1 ).degrees)
    }
    .previewLayout(.fixed(width: 300, height: 50))
  }
}
