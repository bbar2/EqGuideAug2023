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
  @ObservedObject var focusModel: FocusBleModel
  @ObservedObject var pierModel: PierBleModel

  @EnvironmentObject var viewOptions: ViewOptions

  @Environment(\.scenePhase) var scenePhase
  
  var body: some View {
    VStack {
      
      // App Title and BLE connection status area
      // Yellow title emulates yellow LED on hardware focus control
      VStack {
        Text("Focus Control").font(viewOptions.appHeaderFont)
        
        HStack{
          Text("Status: ")
          Text(focusModel.statusString)
            
        }.font(.title)
      }.foregroundColor(viewOptions.appRedColor)

      VStack {
        if focusModel.bleConnected() {
          HStack{
            BigButton(label: "Disconnect"){
              softBump()
              focusModel.disconnectBle()
            }
            if focusModel.bleTimeoutEnable {
              BigButton(label: String(focusModel.timerValue)){
                softBump()
                focusModel.bleTimeoutEnable = false
                focusModel.reportUiActive()
              }
            } else {
              BigButton(image: Image(systemName: "timer"), imageSize:75) {
                softBump()
                focusModel.bleTimeoutEnable = true
                focusModel.reportUiActive()
              }
            }
          }
        }
        else {
          BigButton(label: "Connect", textColor: viewOptions.noBleColor){
            softBump()
            focusModel.connectBle()
            focusModel.reportUiActive()
          }
        }
      }
      
      Spacer()
      
      // Everything else is in this VStack and is red
      VStack {
        
        Spacer()
        
        // Focus mode selection and indication area
        // Red circles emulate red LEDs on hardware device.
        VStack {
          Text("Focus Mode").font(.title)
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
          Text("Adjust Focus").font(.title)
          HStack {
            BigButton(label: "Counter\nClockwise", minHeight: 200) {
              heavyBump() // feel different
              focusModel.reportUiActive()
              focusModel.updateMotorCommandCCW()}
            Spacer()
            BigButton(label: "Clockwise", minHeight: 200) {
              softBump()
              focusModel.reportUiActive()
              focusModel.updateMotorCommandCW()
            }
          }
        }
        
      }
      
    } // top level VStack
    .onChange(of: scenePhase) { newPhase in
      if newPhase == .active {
        focusModel.connectBle()
      } else if newPhase == .inactive {
        focusModel.disconnectBle()
        print("inactive")
      } else if newPhase == .background {
        focusModel.disconnectBle()
      }
    }
    .preferredColorScheme(.dark)
    
    .onAppear{
      softBump()
      focusModel.linkPierModel(pierModel)
      focusModel.connectBle() // always connect. Don't change bleTimeout.
    }
    .onDisappear{
      focusModel.enableBleTimeout() // pointingKnowledge is not handy, so let it go
    }
    .onShake {
      focusModel.connectBle()
    }
  }
}

struct MainView_Previews: PreviewProvider {
  static let previewFocusModel = FocusBleModel()
  static let previewPierModel = PierBleModel()
  static var previews: some View {
    FocusView(focusModel: previewFocusModel, pierModel: previewPierModel)
      .previewDevice(PreviewDevice(rawValue: "iPhone Xs"))
  }
}
