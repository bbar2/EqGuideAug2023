//
//  ArmAngleView.swift
//  EqGuide
//
//  Created by Barry Bryant on 3/30/22.
//

import SwiftUI

struct AngleDegView: View {
  var label: String
  var angleDeg: Float
  
  var body: some View {
    HStack{
      Text(label).font(.subheadline).bold()
      Text(String(format:"%.3fº", angleDeg))
    }
  }
}

struct ArmAngleView_Previews: PreviewProvider {
  static var previews: some View {
    AngleDegView(label: "Test: ",
                 angleDeg: 45.0)
  }
}
