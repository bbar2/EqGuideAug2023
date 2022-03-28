//
//  hmsView.swift
//  EqGuide
//
//  Created by Barry Bryant on 3/26/22.
//

import SwiftUI

struct HmsView: View {
  var angle:Float
  
  var hour:Int {
    Int(angle/15)
  }
  
  var remainderHour:Float {
    angle - Float(hour)*15.0
  }
  
  var min:Int {
    return Int(remainderHour * 60/15)
  }
  
  var sec:Int {
    let remainderMin:Float = remainderHour - Float(min)/60*15
    return Int(remainderMin * 3600/15 + 0.5)  // Round to nearest Second
  }
  
  var body: some View {
    VStack {
      let decimalDegString = String(format: "%.2f deg", angle)
      let dmsString = String(format: "%dh   %d'   %d\"", hour, min, sec)
      Text(decimalDegString).padding(2)
      Text(dmsString).padding(2)
    }
  }
}

struct hmsView_Previews: PreviewProvider {
    static var previews: some View {
      HmsView(angle: 90.0 + 1.0*15.0/60.0 + 2.0*0.25/60.0)
    }
}
