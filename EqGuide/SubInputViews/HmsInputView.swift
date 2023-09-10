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
  
  enum InputField {
    case hour
    case minute
    case second
  }
  @FocusState private var kbFocused: InputField?

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
          .focused($kbFocused, equals: .hour)
          .frame(width:60)
          .border(.clear)
          .onChange(of: hourString) { _ in
            reBuildFloatInput()
          }
        Text("h").font(viewOptions.labelFont)

        Spacer()
        TextField("dd", text: $minString)
          .focused($kbFocused, equals: .minute)
          .frame(width:50)
          .border(.clear)
          .onChange(of: minString) { _ in
            reBuildFloatInput()
          }
        Text("m").font(viewOptions.labelFont)

        Spacer()
        TextField("dd", text: $secString)
          .focused($kbFocused, equals: .second)
          .frame(width:50)
          .border(.clear)
          .onChange(of: secString) { _ in
            reBuildFloatInput()
          }
        Text("s").font(viewOptions.labelFont)

        // Control to raise or dismiss keyboard.
        // Cycles with right arrow's, until dismiss after editing seconds
        if let focus = kbFocused {
          switch focus {
            case .hour:
            Button() {
              kbFocused = .minute
              initEditableStrings()
            } label: {
              Label("", systemImage: "arrow.right.square")
            }
            case .minute:
            Button() {
              kbFocused = .second
              initEditableStrings()
            } label: {
              Label("", systemImage: "arrow.right.square")
            }
            case .second:
            Button() {
              kbFocused = nil
              initEditableStrings()
            } label: {
              Label("", systemImage: "arrow.down.square")
            }

          }
          
        } else { // if nothing focused, button to bring up keyboard
          Button() {
            kbFocused = .hour;
          } label: {
            Label("", systemImage: "arrow.up.square")
          }
        }
        
      }
      .keyboardType(.numberPad)
      .onAppear() {
        initEditableStrings()
      }
      // This onChange() handles cases where caller makes a change after onAppear
      .onChange(of: decimalDegrees) {_ in
        if kbFocused == nil {
          initEditableStrings()
        }
      }
      // Start Editing with all text selected
      .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
        if let textField = obj.object as? UITextField {
          textField.selectedTextRange =
          textField.textRange(from: textField.beginningOfDocument,
                              to: textField.endOfDocument)
        }
      }

    }
    .font(.title)
    .multilineTextAlignment(.trailing)
    .foregroundColor(viewOptions.appActionColor)
  }

  // called by onAppear, and onChange when decimalDegrees changed by caller
  func initEditableStrings() {
    let hms = Hms(decimalDegrees)
    hourString = String(abs(hms.h))
    minString = String(abs(hms.m))
    secString = String(abs(hms.s))
    isPos = (hms.sign > 0 ? true : false)
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
