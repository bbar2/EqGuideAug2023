//
//  ContentView.swift
//  FocusControl
//
// Telescope Focus UI simulates FocusMotor hardware remote control's rotary
// encoder knob using two UI buttons to drive the FocusMotor clockwise (CW) or
// counter clockwise (CCW).
//
// Also provides controls to switch focus control mode between Coarse, Medium,
// and Fine modes.  Coarse mode moves the FocusMotor the most per UI operation,
// providing an initial coarse level of focus control.  Fine mode moves the
// FocusMotor in very small steps providing the finest level of focus control.
// Medium mode is in the middle.
//
// FocusMotorController transmits FocusMotor commands via Bluetooth Low
// Energy (BLE). UI status message field shows state of BLE connection.

import SwiftUI

struct FocusView: View {
  @ObservedObject var focusModel: FocusPeripheralModel
  @ObservedObject var armModel: ArmPeripheralModel
      
  @Environment(\.scenePhase) var scenePhase
  
  var body: some View {
    VStack {
      
      // App Title and BLE connection status area
      // Yellow title emulates yellow LED on hardware focus control
      VStack {
        Text("Focus Control").bold()
        HStack{
          Text("Status: ")
          Text(focusModel.statusString)
        }
        if focusModel.bleConnected() {
          HStack{
            Button("Disconnect"){
              softBump()
              focusModel.disconnectBle()
            }
            if focusModel.connectionLock {
              Button(){
                softBump()
                focusModel.connectionLock = false
                focusModel.reportUiActive()
              } label: {
                Image(systemName: "timer") // current state no timer
              }
            } else {
              Button(){
                softBump()
                focusModel.connectionLock = true
                focusModel.reportUiActive()
              } label: {
                Text(String(focusModel.timerValue))
              }
            }
          }
        } else {
          Button("Connect"){
            softBump()
            focusModel.connectBle()
            focusModel.reportUiActive()
          }
        }
      }.colorMultiply(focusModel.bleConnected() ? .red : .yellow)
      
      Spacer()
      
      // Everything else is in this VStack and is red
      VStack {
        VStack{
          Text("XL Data").bold()
          Text(String(format: "Pitch: %+7.2fº %+5.2f",
                      focusModel.pitch,
                      focusModel.rhsXlData.x))
          Text(String(format: "Roll: %+7.2fº %+5.2f",
                      focusModel.roll,
                      focusModel.rhsXlData.y))
          Text(String(format: "Yaw: %+7.2fº %+5.2f",
                      focusModel.yaw,
                      focusModel.rhsXlData.z))
//          Text(String(format: "Ay: %+5.2f", viewModel.xlData.y))
//          Text(String(format: "Ax: %+5.2f", viewModel.xlData.x))
//          Text(String(format: "Az: %+5.2f", viewModel.xlData.z))
          HStack{
            Button("Update"){
              softBump()
              focusModel.reportUiActive()
              focusModel.requestCurrentXl()
            }
            Button("Start"){
              softBump()
              focusModel.reportUiActive()
              focusModel.startXlStream()
            }
            Button("Stop"){
              softBump()
              focusModel.reportUiActive()
              focusModel.stopXlStream()
            }
          }
        }
        
        Spacer()
        
        // Focus mode selection and indication area
        // Red circles emulate red LEDs on hardware device.
        VStack {
          Text("Focus Mode").bold()
          Picker(selection: $focusModel.focusMode,
                 label: Text("???")) {
            Text("Course").tag(FocusMode.course)
            Text("Medium").tag(FocusMode.medium)
            Text("Fine").tag(FocusMode.fine)
          } .pickerStyle(.segmented)
            .onChange(of: focusModel.focusMode) { picker in
              softBump()
              focusModel.reportUiActive()
            }
        }
        Spacer()
        
        // Focus control area - BIG buttons simplify focusing
        // while looking through telescope and not at UI.
        VStack{
          Text("Adjust Focus").bold()
          HStack {
            Button("\nCounter\nClockwise\n") {
              heavyBump() // feel different
              focusModel.reportUiActive()
              focusModel.updateMotorCommandCCW()}
            Spacer()
            Button("\nClockwise\n\n") {
              softBump()
              focusModel.reportUiActive()
              focusModel.updateMotorCommandCW()
            }
          }
        }
      } // Vstack that is always Red
      .colorMultiply(Color(red:159/255, green: 0, blue: 0))
      
    } // top level VStack
    .onChange(of: scenePhase) { newPhase in
      if newPhase == .active {
        focusModel.connectBle()
      } else if newPhase == .inactive {
        focusModel.disconnectBle()
      } else if newPhase == .background {
        focusModel.disconnectBle()
      }
    }
    .preferredColorScheme(.dark)
    .foregroundColor(.white)
    .buttonStyle(.bordered)
    .controlSize(.large)
    .font(.title)
    
    .onAppear{
      // pass in a reference to the ArmAccel
      focusModel.viewModelInit(linkToArmAccelModel: armModel)
      
      //Change picker font size
      UISegmentedControl.appearance().setTitleTextAttributes(
        [.font : UIFont.preferredFont(forTextStyle: .title1)],
        for: .normal)
    }
    .onShake {
      focusModel.connectBle()
    }
  }
  
  func heavyBump(){
    let haptic = UIImpactFeedbackGenerator(style: .heavy)
    haptic.impactOccurred()
  }
  
  func softBump(){
    let haptic = UIImpactFeedbackGenerator(style: .soft)
    haptic.impactOccurred()
  }
  
}

struct MainView_Previews: PreviewProvider {
  static let previewFocusModel = FocusPeripheralModel()
  static let previewArmModel = ArmPeripheralModel()
  static var previews: some View {
    FocusView(focusModel: previewFocusModel, armModel: previewArmModel)
      .previewDevice(PreviewDevice(rawValue: "iPhone Xs"))
  }
}
