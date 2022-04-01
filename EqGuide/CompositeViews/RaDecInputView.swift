//
//  RaInputView.swift
//  EqGuide
//
//  Created by Barry Bryant on 3/27/22.
//

import SwiftUI

struct RaDecInputView: View {
  
  var label:String
  @Binding var coord:RaDec
  
  @State var raString:String = "0.0"
  @State var decString:String = "0.0"
  @State var editInFloat = true
  
  @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
  
  var body: some View {
    
    VStack {
      Text(label).font(.title)
            
      VStack{
        if (editInFloat) {
          VStack{
            FloatInputView(floatString: $raString,
                           prefix: " RA:",
                           msg:"xx.yyy")
            FloatInputView(floatString: $decString,
                           prefix: "Dec:",
                           msg:"xx.yyy")
          }
        } else {
          VStack {
            DmsInputView(prefix: "RA:  ")
            DmsInputView(prefix: "Dec: ")
          }
        }
        BigButton(label:"Apply") {
          UIApplication.shared.endEditing()
          coord.ra = Float(raString) ?? 0.0
          coord.dec = Float(decString) ?? 0.0
          self.presentationMode.wrappedValue.dismiss()
        }
      }
      HStack {
        Toggle(isOn: $editInFloat) {
          Text("Input in Decimal Degrees").bold()
        }
        Spacer()
      }

      Spacer()
    }
    .onAppear() {
      raString  = String(format:"%.3f", coord.ra)
      decString = String(format:"%.3f", coord.dec)
    }
  }
}

struct RaInputView_Previews: PreviewProvider {
  @State static var crap = RaDec(ra:97.5, dec: 0.5)
  static var previews: some View {
    RaDecInputView(label: "Enter RA/DEC Pair", coord: $crap)
  }
}

// extension for keyboard to dismiss
extension UIApplication {
  func endEditing() {
    sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
  }
}
