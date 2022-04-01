//
//  FloatInputView.swift
//  EqGuide
//
//  Created by Barry Bryant on 3/28/22.
//

import SwiftUI
import Combine

struct FloatInputView: View {
  
  @Binding var floatString: String
  var prefix = String("")
  var msg = String("Enter a Float")
  @State var isPos: Bool = true

  var body: some View {
    HStack {
      if prefix != "" {
        Text(prefix)
      }
      
      SignButton(isPos: $isPos)
      
      TextField(msg, text: $floatString)
        .frame(width:100, alignment: .center)
        .border(.black)
        .keyboardType(.decimalPad)
    }
    .font(.title)
    .multilineTextAlignment(.center)
  }
}

struct FloatInputView_Previews: PreviewProvider {
  @State static var testValue = "33.03"
  static var previews: some View {
    FloatInputView(floatString: $testValue)
  }
}
