//
//  DmsInput.swift
//  EqGuide
//
//  Edit binding to a float for decimalDegrees
//  Encapsulate the string conversion here
//  Update the bound value:Float on every keystroke
//  Could add keyboard filtering, but being lazy and relying on .keyboardType
//  Parent must dismiss the view to terminate this editing session
//  Uses a Sign Button for sign since .decimalPad has no sign key.
//  Sign Button is also consistent with DMS/HMS views which use a signButton to enforce consist signs across all three terms.
//
//

import SwiftUI

struct DmsInputView: View {
  @Binding var decimalDegrees: Float
  var prefix = String("")
  
  @State var degString = String(33)
  @State var minString = String(11)
  @State var secString = String(44)
  @State var isPos = true
  
  var body: some View {
    HStack {
      if prefix != "" {
        Text(prefix)
      }
      Spacer()
      
      SignButton(isPos: $isPos)
        .onChange(of: isPos) { _ in
          print("DMS Sign Button Change \(isPos)")
        }
      
      HStack {
        Text("D")
        TextField("dd", text: $degString)
          .frame(width:60)
          .border(.black)
          .onChange(of: degString) { _ in
            decimalDegrees = Dms(d: Int(degString) ?? 0,
                                 m: Int(minString) ?? 0,
                                 s: Int(secString) ?? 0).degrees
          }
        
        Spacer()
        Text("M")
        TextField("dd", text: $minString)
          .frame(width:50)
          .border(.black)
          .onChange(of: minString) { _ in
            decimalDegrees = Dms(d: Int(degString) ?? 0,
                                 m: Int(minString) ?? 0,
                                 s: Int(secString) ?? 0).degrees
          }

        Spacer()
        Text("S")
        TextField("dd", text: $secString)
          .frame(width:50)
          .border(.black)
          .onChange(of: secString) { _ in
            decimalDegrees = Dms(d: Int(degString) ?? 0,
                                 m: Int(minString) ?? 0,
                                 s: Int(secString) ?? 0).degrees
          }

        Spacer()
      }
      .keyboardType(.numberPad)
      .onAppear() {
        let dms = Dms(deg: decimalDegrees)
        degString = String(dms.deg)
        minString = String(dms.min)
        secString = String(dms.sec)
      }
    }
    .font(.title)
    .multilineTextAlignment(.center)
  }
}

struct DmsInputView_Previews: PreviewProvider {
  @State static var angle = Float(-90.5)
  
  static var previews: some View {
    DmsInputView(decimalDegrees: $angle)
  }
}
