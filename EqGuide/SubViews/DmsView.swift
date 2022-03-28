//
//  dmsView.swift
//  EqGuide
//
//  Created by Barry Bryant on 3/26/22.
//

import SwiftUI

struct DmsView: View {
  var angle:Float
  
  var deg:Int {
    Int(angle)
  }
  
  var min:Int {
    let remainderDeg:Float = angle - Float(deg)
    return Int(remainderDeg * 60)
  }
  
  var sec:Int {
    let remainderMin:Float = angle - Float(deg) - Float(min)/60
    return Int(remainderMin * 3600 + 0.5)  // Round to nearest Second
  }
  
  var body: some View {
    VStack {
      let decimalDegString = String(format: "%.2f deg", angle)
      let dmsString = String(format: "%dº   %d'   %d\"", deg, min, sec)
      Text(decimalDegString).padding(2)
      Text(dmsString).padding(2)
    }
  }
}

struct dmsView_Previews: PreviewProvider {
  static var previews: some View {
    DmsView(angle: 180.0 + 28.0/60.0 + 2.0/3600.0)
  }
}
