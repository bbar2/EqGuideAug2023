//
//  FloatInputView.swift
//  EqGuide
//
//  Edit binding to a float
//  Encapsulate the string conversion here
//  Update the bound floatValue:Float on every keystroke
//  Could add keyboard filtering, but being lazy and relying on .keyboardType
//  Parent must dismiss the view to terminate this editing session
//  Uses a Sign Button for sign since .decimalPad has no sign key.
//  Sign Button is also consistent with DMS/HMS views which use a signButton to enforce consist signs across all three terms.
//
//

import SwiftUI
import Combine

struct FloatInputView: View {
  @Binding var doubleValue: Double
  var prefix = String("")
  
  @EnvironmentObject var viewOptions: ViewOptions
  
  @State var isPos: Bool = true
  @State var floatString = String("3.14")
  
  var body: some View {
    HStack {
      if prefix != "" {
        Text(prefix)
      }
      
      SignButton(isPos: $isPos)
        .onChange(of: isPos) { _ in
          reBuildDoubleInput()
        }
      
      TextField("xx.yy", text: $floatString)
        .frame(width:125)
        .multilineTextAlignment(.leading)
        .border(.black)
        .foregroundColor(viewOptions.appActionColor)
        .keyboardType(.decimalPad)
        .onChange(of: floatString) { _ in
          reBuildDoubleInput()
        }
    }
    .font(.title)
    .multilineTextAlignment(.center)
    .onAppear() {
      initEditableString()
    }
    // This onChange() handles cases where caller makes a change after onAppear
    .onChange(of: doubleValue){ _ in
      initEditableString()
    }
  }
  
  func initEditableString() {
    isPos = (doubleValue >= 0.0 ? true : false)
    floatString = String(format:"%.2f", abs(doubleValue))
  }
  
  func reBuildDoubleInput() {
    doubleValue = Double(floatString) ?? 0.0
    doubleValue *= (isPos ? 1.0 : -1.0)
  }
}

struct FloatInputView_Previews: PreviewProvider {
  @State static var testValue = Double(33.03)
  static var previews: some View {
    FloatInputView(doubleValue: $testValue)
      .environmentObject(ViewOptions())
  }
}
