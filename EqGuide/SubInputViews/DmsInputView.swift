//
//  DmsInput.swift
//  EqGuide
//
//  Display and edit binding to a float for decimalDegrees - using integer
//  Degrees, ArcMinutes and ArcSeconds
//  Although not mathematically necessary, force Deg, Min, and Sec to have the
//  same sign by using  a Sign Button for the group of input fields.
//  Use of Sign Button also addresses .decimalPad lack of sign key.
//  Encapsulate the string conversions here
//  Update the bound value:Float on every keystroke
//  Could add keyboard filtering, but being lazy and relying on .keyboardType
//  Parent must dismiss the view to terminate this editing session
//

import SwiftUI
import Combine

struct DmsInputView: View {
  @Binding var decimalDegrees: Double
  var prefix = String("")
  
  @EnvironmentObject var viewOptions: ViewOptions
  
  @State var degString = String(33)
  @State var minString = String(11)
  @State var secString = String(44)
  @State var isPos = true

  enum InputField {
    case degree
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
        TextField("dd", text: $degString)
          .focused($kbFocused, equals: .degree)
          .frame(width:60)
          .border(.clear)
          .onChange(of: degString) { _ in
            reBuildFloatInput()
          }
        
        Text("º")
        
        Spacer()
        TextField("dd", text: $minString)
          .focused($kbFocused, equals: .minute)
          .keyboardType(.decimalPad)
          .frame(width:50)
          .border(.clear)
          .onChange(of: minString) { _ in
            reBuildFloatInput()
          }
        
        Text("'")
        
        Spacer()
        TextField("dd", text: $secString)
          .focused($kbFocused, equals: .second)
          .frame(width:50)
          .border(.clear)
          .onChange(of: secString) { _ in
            reBuildFloatInput()
          }
        
        Text("\"")

        // Control to raise or dismiss keyboard.
        // Cycles with right arrow's, until dismiss after editing seconds
        if let focus = kbFocused {
          switch focus {
            case .degree:
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
            kbFocused = .degree;
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
      .onChange(of: decimalDegrees) { _ in
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
    let dms = Dms(decimalDegrees)
    degString = String(abs(dms.d))
    minString = String(abs(dms.m))
    secString = String(abs(dms.s))
    isPos = (dms.sign > 0 ? true : false)
  }
  
  func reBuildFloatInput() {
    decimalDegrees = Dms(d: Int(degString) ?? 0,
                         m: Int(minString) ?? 0,
                         s: Int(secString) ?? 0).degrees
    decimalDegrees *= (isPos ? 1.0 : -1.0)
  }
  
}

struct DmsInputView_Previews: PreviewProvider {
  @State static var angle = -90.5
  
  static var previews: some View {
    DmsInputView(decimalDegrees: $angle)
      .environmentObject(ViewOptions())
      .preferredColorScheme(.dark)
  }
}
