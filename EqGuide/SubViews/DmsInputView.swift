//
//  DmsInput.swift
//  EqGuide
//
//  Created by Barry Bryant on 3/30/22.
//

import SwiftUI

struct DmsInputView: View {
  //  @Binding var floatString:String
  @State var hourString = String("12")
  @State var minString = String("59")
  @State var secString = String("59")
  @State var isPos:Bool = true
  
  var prefix = String("")
  var msg = String("Enter DMS Angle")
  
  var body: some View {
    HStack {
      if prefix != "" {
        Text(prefix)
      }
      Spacer()
      
      SignButton(isPos: $isPos)
      
      HStack {
        Text("D")
        TextField(msg, text: $hourString)
          .frame(width:60)
          .border(.black)
        Spacer()
        Text("M")
        TextField(msg, text: $minString)
          .frame(width:50)
          .border(.black)
        Spacer()
        Text("S")
        TextField(msg, text: $secString)
          .frame(width:50)
          .border(.black)
        Spacer()
      }
      .keyboardType(.numberPad)
    }
    .font(.title)
    .multilineTextAlignment(.center)
  }
}

struct DmsInputView_Previews: PreviewProvider {
  //  @State static var testValue = "33.03"
  static var previews: some View {
    DmsInputView(prefix: "RA:")
  }
}
