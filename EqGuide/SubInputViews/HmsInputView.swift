//
//  DmsInput.swift
//  EqGuide
//
//  This is a very slightly modified copy of DmsInputView.swift.
//
//  Display and edit binding to a float for decimalDegrees - using integer
//  Hours, Minutes and Seconds
//  Although not mathematically necessary, force Hour, Min, and Sec to have the
//  same sign by using  a Sign Button for the group of input fields.
//  Use of Sign Button also addresses .decimalPad lack of sign key.
//  Encapsulate the string conversions here
//  Update the bound value:Float on every keystroke
//  Could add keyboard filtering, but being lazy and relying on .keyboardType
//  Parent must dismiss the view to terminate this editing session
//

import SwiftUI

struct HmsInputView: View {
  @Binding var decimalDegrees: Double
  var prefix = String("")
  
  @EnvironmentObject var viewOptions: ViewOptions
  
  @State var hourString = String(24)
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
          reBuildFloatInput()
        }
      
      HStack {
        TextField("dd", text: $hourString)
          .frame(width:60)
          .border(.black)
          .onChange(of: hourString) { _ in
            reBuildFloatInput()
          }
        Text("h")

        Spacer()
        TextField("dd", text: $minString)
          .frame(width:50)
          .border(.black)
          .onChange(of: minString) { _ in
            reBuildFloatInput()
          }
        Text("m")

        Spacer()
        TextField("dd", text: $secString)
          .frame(width:50)
          .border(.black)
          .onChange(of: secString) { _ in
            reBuildFloatInput()
          }
        Text("s")

        Spacer()
      }
      .keyboardType(.numberPad)
      .onAppear() {
        let hms = Hms(deg: decimalDegrees)
        hourString = String(abs(hms.h))
        minString = String(abs(hms.m))
        secString = String(abs(hms.s))
        isPos = (hms.sign > 0 ? true : false)
      }
    }
    .font(.title)
    .multilineTextAlignment(.trailing)
    .foregroundColor(viewOptions.appActionColor)
  }
  
  func reBuildFloatInput() {
    decimalDegrees = Hms(h: Int(hourString) ?? 0,
                         m: Int(minString) ?? 0,
                         s: Int(secString) ?? 0).degrees
    decimalDegrees *= (isPos ? 1.0 : -1.0)
  }
  
}

struct HmsInputView_Previews: PreviewProvider {
  @State static var angle = Double(-90.5)
  
  static var previews: some View {
    HmsInputView(decimalDegrees: $angle)
      .environmentObject(ViewOptions())
  }
}
