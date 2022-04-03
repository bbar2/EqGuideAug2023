//
//  SignButton.swift
//  EqGuide
//
//  Created by Barry Bryant on 3/31/22.
//

import SwiftUI

struct SignButton: View {
  @Binding var isPos:Bool
  
  var body: some View {
    Button() { isPos = !isPos
    } label: {
      Text(isPos ? "＋" : "−")
        .font(.title)
        .bold()
        .foregroundColor(.blue)
    }
  }
}

struct SignButton_Previews: PreviewProvider {
  @State static var trueBinding = true
  @State static var falseBinding = false
  static var previews: some View {
    Group {
      SignButton(isPos: $trueBinding)
      SignButton(isPos: $falseBinding)
    }
    .previewLayout(.fixed(width: 300, height: 50))
  }
}
