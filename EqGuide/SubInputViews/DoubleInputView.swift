//
//  DoubleInputView.swift
//  EqGuide
//
//  Edit binding to a double
//  Encapsulate the string conversion here
//  Update the bound doubleValue: Double on every keystroke
//  Could add keyboard filtering, but being lazy and relying on .keyboardType
//  Includes an UP or Down button to Show or Dismiss keyboard
//  Uses a Sign Button for sign since .decimalPad has no sign key.
//  Sign Button is also consistent with DMS/HMS views which use a signButton to enforce consist signs across all three terms.

import SwiftUI
import Combine

struct DoubleInputView: View {
  @Binding var doubleValue: Double
  var prefix: String?
  var numDigits: Int = 4

  @EnvironmentObject var viewOptions: ViewOptions
  
  @State private var isPos: Bool = true
  @State private var doubleString = String("3.14")
  @FocusState private var kbFocused: Bool

  var body: some View {
    HStack {
      if let label = prefix {
        Text(label).foregroundColor(viewOptions.appRedColor)
      }
      Spacer()
      
      SignButton(isPos: $isPos)
        .onChange(of: isPos) { _ in
          reBuildDoubleValue()
        }
      
      TextField(numDigits != 0 ? "xxx.yyyy" : "xx", text: $doubleString)
        .focused($kbFocused)
        .frame(width:60+CGFloat(numDigits*25))
        .multilineTextAlignment(.leading)
        .border(.clear)
        .keyboardType(numDigits != 0 ? .decimalPad : .numberPad)
        .onChange(of: doubleString) { _ in
          reBuildDoubleValue()
        }
        // This onChange() handles cases where caller makes a change after onAppear
        // withoug using a keyboard -- i.e. selecting new target from the list.
        .onChange(of: doubleValue){ _ in
          if !kbFocused { // if changed without using the keyboard!
            initDoubleString()
          }
        }
        // Start Editing with all text selected
        .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
          if let textField = obj.object as? UITextField {
            textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
          }
        }

      // Control to raise or dismiss keyboard
      if kbFocused {
        Button() {
          kbFocused = false;
          initDoubleString()
        } label: {
          Label("", systemImage: "arrow.down.square")
            .font(viewOptions.arrowButtonFont)
        }
      } else {
        Button() {
          kbFocused = true;
        } label: {
          Label("", systemImage: "arrow.up.square")
            .font(viewOptions.arrowButtonFont)
        }
      }
      
    }
    .onAppear() {
      initDoubleString()
    }
    .font(viewOptions.inputFont)
    .foregroundColor(viewOptions.appActionColor)
  }
  
  // Create Double string to be edited, from input value
  func initDoubleString() {
    isPos = (doubleValue >= 0.0 ? true : false)
    doubleString = String(format:"%.\(numDigits)f", abs(doubleValue))
  }

  // Create new double value from edited double string
  func reBuildDoubleValue() {
    doubleValue = Double(doubleString) ?? 0.0
    doubleValue *= (isPos ? 1.0 : -1.0)
  }
}

struct FloatInputView_Previews: PreviewProvider {
  @State static var testValue = Double(33.03)
  static var previews: some View {
    DoubleInputView(doubleValue: $testValue)
      .environmentObject(ViewOptions())
  }
}
