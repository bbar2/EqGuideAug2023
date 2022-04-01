//
//  dmsView.swift
//  EqGuide
//
//  Created by Barry Bryant on 3/26/22.
//

import SwiftUI

struct DmsView: View {
  var angle:Float
  
  var body: some View {
    let dms = Dms(deg: angle)
    VStack {
      let decimalDegString = String(format: "%.2f deg", angle)
      let dmsString = String(format: "%dº   %d'   %d\"",
                             dms.deg, dms.min, dms.sec)
      Text(decimalDegString)//.padding(2)
      Text(dmsString)//.padding(2)
    }
  }
}

struct dmsView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      DmsView(angle: 0.0)
      DmsView(angle: 180.0)
      DmsView(angle: 90.0 + 28.0/60.0 + 2.0/3600.0)
      DmsView(angle: Dms(d:  359, m:  59, s:  59 ).degrees)
      DmsView(angle: Dms(d: -359, m: -59, s: -59 ).degrees)
      DmsView(angle: Dms(d: -360, m:   0, s:   1 ).degrees)
    }
    .previewLayout(.fixed(width: 300, height: 50))
  }
}
