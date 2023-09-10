//
//  DmInput.swift - Integer Degrees and floating point Minute format.
//
//  Modified version of DmsInput.swift to use floating point minutes, and no seconds.

import SwiftUI
import Combine

struct DmInputView: View {
  @Binding var decimalDegrees: Double
  var prefix = String("")
  
  @EnvironmentObject var viewOptions: ViewOptions
  
  @State var degString = String(33)
  @State var minString = String(11)
  @State var isPos = true
  
  enum InputField {
    case degree
    case minute
  }
  
  @FocusState private var kbFocused: InputField?
  
  var body: some View {
    HStack {
      if prefix != "" {
        Text(prefix)
          .foregroundColor(viewOptions.appRedColor)
      }
      Spacer()
      
      SignButton(isPos: $isPos)
        .onChange(of: isPos) { _ in
          reBuildFloatInput()
        }
      
      TextField("ddd", text: $degString)
        .focused($kbFocused, equals: .degree)
        .keyboardType(.numberPad)
        .frame(width:40)
        .border(.clear)
        .onChange(of: degString) { _ in
          reBuildFloatInput()
        }
      
      Text("º")
      
      TextField("m.mm", text: $minString)
        .focused($kbFocused, equals: .minute)
        .keyboardType(.decimalPad)
        .frame(width:100)
        .border(.clear)
        .onChange(of: minString) { _ in
          reBuildFloatInput()
        }
      
      Text("'")
      
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
                .font(viewOptions.arrowButtonFont)
            }
          case .minute:
            Button() {
              kbFocused = nil
              initEditableStrings()
            } label: {
              Label("", systemImage: "arrow.down.square")
                .font(viewOptions.arrowButtonFont)
            }
        }
        
      } else { // if nothing focused, button to bring up keyboard
        Button() {
          kbFocused = .degree;
        } label: {
          Label("", systemImage: "arrow.up.square")
            .font(viewOptions.arrowButtonFont)
        }
      }
    }
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
    .font(viewOptions.inputFont)
    .multilineTextAlignment(.trailing)
    .foregroundColor(viewOptions.appActionColor)
  }
  
  // called by onAppear, and onChange when decimalDegrees changed by caller
  func initEditableStrings() {
    let dms = Dms(decimalDegrees)
    degString = String(abs(dms.d))
    minString = String(format: "%.3f", fabs(dms.md))
    isPos = (dms.sign > 0 ? true : false)
  }
  
  func reBuildFloatInput() {
    decimalDegrees = Dms(d: Int(degString) ?? 0,
                         m: Double(minString) ?? 0).degrees
    decimalDegrees *= (isPos ? 1.0 : -1.0)
  }
}

struct DmInputView_Previews: PreviewProvider {
  @State static var angle = -90.5
  
  static var previews: some View {
    DmInputView(decimalDegrees: $angle)
      .environmentObject(ViewOptions())
      .preferredColorScheme(.dark)
  }
}
