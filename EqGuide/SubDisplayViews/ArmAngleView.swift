//
//  ArmAngleView.swift
//  EqGuide
//
//  Created by Barry Bryant on 3/30/22.
//

import SwiftUI

struct ArmAngleView: View {
  var angleDeg:Float
  
  var body: some View {
    HStack{
      Text("Arm: ").font(.subheadline).bold()
      Text(String(format:"%.3f", angleDeg))
      Text("deg").font(.subheadline)
    }
  }
}

struct ArmAngleView_Previews: PreviewProvider {
  static var previews: some View {
    ArmAngleView(angleDeg: 45.0)
  }
}
