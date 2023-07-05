//  ControlViewModel.swift - Created by Barry Bryant on 10/19/21.
//
// Simulate FocusMotor hardware remote control's 20 step rotary encoder.
//   Each tap on a UI button emulates one rotary encoder step.
//   Each encoder step (or UI tap) changes the FocusMotor position
//   command by a number of FocusMotor stepper motor steps determined by FocusMode.
//
// ControlViewModel implements an iOS remote control "BLE Central":
//   - Establish BLE communication with FocusMotor Peripheral
//   - Transmits the FocusMotor commanded position
//   - Converts between CoreBlutooth UInt8 buffers and Int32 values. The
//     FocusMotor hardware is Arduino Nano33BLE based, using Int32 data.
//
// The FocusMotor command is scaled for each mode of operation, matching the
//   operation of the hardware remote control:
//   - Coarse mode: Scaled so 20 UI Taps turns the telescope focus knob one turn.
//   - Medium mode: Scaled so 4x20 UI Taps turns the telescope focus knob one
//     turn. Provides finer control over focus operation.
//   - Fine mode: the FocusMotor is driven one full stepper motor step for the
//     finest level of focus control.
//
// Data Transmitted over BLE must match C++ FocusMotor Controller definitions:
//   - RocketFocusMsg structure, defined in FocusMsg.h
//   - XLData structure, defined in FocusMsg.h
//   - CMD raw values, defined in FocusMsg.h
//   - FocusMode raw values, defined in FocusMsg.h
//   - UUID, and NAME defined in FocusUuid.h
//
// This app, the hardware remote control, and the MacOS Indigo apps tranmit
//   FocusMotor commands via Bluetooth Low Energy (BLE).
//   - Only one can connect to the FocusMotor hardware at a time.
//   - The first to connect wins. Disconnect after a period of inaction to allow
//     other devices to connect as needed.
//   - bleConnectionStatus messages inform the UI's ViewController of current BLE
//     connection state.

import SwiftUI
import CoreBluetooth
import simd

// Define the number of focus motor micro steps for each FocusMode
// Raw values = motor steps and should match FocusMotor project FocusMsg.h
enum FocusMode:Int32 {
  case course = 37
  case medium = 9
  case fine   = 2
}

class FocusBleModel : MyPeripheralDelegate,
                      ObservableObject  {
  
  enum BleState {
    case disconnected
    case connecting
    case ready
  }
  
  var pierAccelModel: PierBleModel?
  
  // Command structure sent to FocusMotor
  private struct RocketFocusMsg {
    var cmd : Int32
    var val : Int32
  }
  
  // Commands sent to FocusMotor
  private enum CMD:Int32 {
    case STOP = 0x10  // stop execution of commands
    case INIT = 0x11  // Init, No move, set pos to 0, reply with micro_steps_per_step
    case SPOS = 0x12  // set position - focuser moves to new position
    case GPOS = 0x13  // get position - focuser replies with current position
    case MOVE = 0x14  // move val full steps (not micro steps) from current position
    case XL_READ  = 0x15  // Central requests current XL data
    case XL_START = 0x16  // Central ask peripheral to start streaming XL data
    case XL_STOP  = 0x17  // Central ask peripheral to stop streaming XL data
  }
  
  @Published var bleState = BleState.disconnected
  @Published var statusString = "Not Connected"
  @Published var focusMode = FocusMode.medium
  @Published var connectionLock = true // true to prevent connection timeout
  @Published var timerValue: Int = 0
  
  private var xlRaw = BleXlData(x: 0.0, y: 0.0, z: 0.0) // is left handed
  @Published var xlAligned = simd_float3(x: 0.0, y: 0.0, z: 0.0)
  @Published var theta = Float(0.0)
  @Published var phi = Float(0.0)
  @Published var psi = Float(0.0)
  
  // Focus Service provides focus motor control and focus motor accelerations
  private let FOCUS_DEVICE_NAMED = "FocusMotor"
  private let FOCUS_SERVICE_UUID = CBUUID(string: "828b0000-046a-42c7-9c16-00ca297e95eb")
  
  // Parameter Characteristic UUIDs
  private let FOCUS_MSG_UUID = CBUUID(string: "828b0001-046a-42c7-9c16-00ca297e95eb")
  private let ACCEL_XYZ_UUID = CBUUID(string: "828b0005-046a-42c7-9c16-00ca297e95eb")
  
  private let focusMotor: MyPeripheral
  private var uponBleReadyAction : (()->Void)?
  
  // Disconnect BLE if no UI inputs for this long, so other devices can control focus
  private let TIMER_DISCONNECT_SEC = 10
  private var connectionTimer = Timer()
  
  
  // This runs everytime an FocusAccel data struct arrives via BLE.  Nominally at 5Hz.
  // Called by setNotify Closure
  func focusCalcAngles() {
    
    // Focus motor is mounted to telescope, so same rotation ref frame as telescope
    // Telescope Reference Frame: +X forward (north), +Y left (west), +Z up
    // Focus Accel is mounted:    +X back,            +Y right,       +Z down
    // Map Left Handed accelerometer to Right Handed Telescope Frame
    let xlRhs = simd_float3(x: -xlRaw.x, y: -xlRaw.y, z: -xlRaw.z)
    
    // normalize
    let xlNorm = simd_normalize(xlRhs)
    
    // TBD Measured offsets between pier and focus accelerometers
    //let pierToFocusThetaOffset = Float(toRad(0.0))
    //let pierToFocusPhiOffset = Float(toRad(0.0))
    
    let yRot = yRot3x3(phiRad: 0.0)
    let zRot = zRot3x3(psiRad: 0.0)
    let xRot = xRot3x3(thetaRad: 0.0)
    let alignTform = zRot * xRot * yRot // tbd for now
    xlAligned = alignTform * xlNorm
    
    // Get theta (pitch) and Phi (roll) from Pier Acceleromter
    theta = (pierAccelModel?.theta ?? 0.0)
    phi = (pierAccelModel?.phi ?? 0.0)
    
    // Based on Rz' * Rx' * Ry' for known theta and phi
    let CT = cos(theta)
    let ST = sin(theta)
    let SP = sin(phi)
    let CTSP = CT*SP
    psi = acos( (CTSP*xlAligned.y/ST - xlAligned.x) / (CTSP*CTSP/ST + ST) )
  }
  
  init() {
    focusMotor = MyPeripheral(deviceName: FOCUS_DEVICE_NAMED,
                              serviceUUID: FOCUS_SERVICE_UUID,
                              dataUUIDs: [FOCUS_MSG_UUID, ACCEL_XYZ_UUID])
    uponBleReadyAction = nil
    focusMotor.mpDelegate = self
    connectBle() {
      self.startXlStream()
    }
    statusString = "Searching for Focus-Motor ..."
  }
  
  // Provide access to PierBleModel
  func linkPierModel(_ pierModel: PierBleModel) {
    pierAccelModel = pierModel
  }
  
  // used by Views for UI color control and pointing knowledge
  func bleConnected() -> Bool {
    return bleState == .ready
  }
  
  func connectBle(uponReady :(()->Void)? = nil) {
    if (bleState == .disconnected) {
      statusString = "Connecting"
      bleState = .connecting
      focusMotor.startBleConnection()
    }
    if let action = uponReady{
      uponBleReadyAction = action
    }
  }
  
  func disconnectBle() {
    if (bleState != .disconnected) {
      focusMotor.endBleConnection()
    }
  }
  
  // Signal disconnect timer handler that UI is being used.
  func reportUiActive(){
    timerValue = TIMER_DISCONNECT_SEC
    
    // Any UI input, reconnects the BLE
    if(bleState == .disconnected) {
      connectBle()
    }
  }
  
  // If no UI interaction for one timerInterval disconnect the BLE link.
  func uiTimerHandler() {
    timerValue -= 1
    
    if (!connectionLock && timerValue <= 0) {
      disconnectBle()   // disconnect ble
    }
  }
  
  //MARK: UI Actions
  // Clockwise UI action
  func updateMotorCommandCW(){
    if (bleState == .ready) {
      focusMotor.bleWrite(FOCUS_MSG_UUID,
                          writeData: RocketFocusMsg(cmd: CMD.MOVE.rawValue,
                                                    val: focusMode.rawValue))
    } else {
      connectBle() {
        self.updateMotorCommandCW()
      }
    }
  }
  
  // Counter Clockwise UI action
  func updateMotorCommandCCW(){
    if (bleState == .ready) {
      focusMotor.bleWrite(FOCUS_MSG_UUID,
                          writeData: RocketFocusMsg(cmd: CMD.MOVE.rawValue,
                                                    val: -focusMode.rawValue))
    } else {
      connectBle() {
        self.updateMotorCommandCCW()
      }
    }
  }
  
  func requestCurrentXl() {
    if (bleState == .ready) {
      focusMotor.bleWrite(FOCUS_MSG_UUID,
                          writeData: RocketFocusMsg(cmd: CMD.XL_READ.rawValue,
                                                    val: 0))
    } else {
      connectBle() {
        self.requestCurrentXl()
      }
    }
  }
  
  func startXlStream() {
    if (bleState == .ready) {
      focusMotor.bleWrite(FOCUS_MSG_UUID,
                          writeData: RocketFocusMsg(cmd: CMD.XL_START.rawValue,
                                                    val: 0))
    } else {
      connectBle() {
        self.startXlStream()
      }
    }
  }
  
  func stopXlStream() {
    if (bleState == .ready) {
      focusMotor.bleWrite(FOCUS_MSG_UUID,
                          writeData: RocketFocusMsg(cmd: CMD.XL_STOP.rawValue,
                                                    val: 0))
    } else {
      connectBle() {
        self.stopXlStream()
      }
    }
  }
  
  //MARK: MyPeripheralDelegate
  
  func onFound(){
    statusString = "Focus Motor Found"
  }
  
  // BLE Connected, but have not yet scanned for services and characeristics
  func onConnected(){
    statusString = "Connected"
  }
  
  func onDisconnected(){
    bleState = .disconnected;
    statusString = "Disconnected"
    connectionTimer.invalidate()
    connectionLock = false
  }
  
  func onReady() {
    // Setup Notifications, to process writes from the FocusMotor peripheral
    
    // Approach 1:  Unique closure signature for each data type.
    // - peripheral requires access to each datatype used
    // - peripheral(didUpdateValueFor) must match closure signature to UUID
    // - peripheral must keep an array of closures for each data type
    // - peripheral requires a bleRead and setNotify for each type read
    // - Caller syntax is simple and clean
    //    focusMotor.setNotify(ACCEL_XYZ_UUID) { self.xlData = $0 }
    
    // Approach 2: Common closure signature using Swift Data type.
    // - peripheral(didUpdateValueFor) requires no mods for any data type
    // - peripheral uses a common bleRead and setNotify for all data types
    // - Caller closure is common format for all data types, but a klunky mess.
    // - This avoid approach 3's "escaping closure capture inout param" problem by:
    //   -- self reference to store result, vs passing inout param in closure
    focusMotor.setNotify(ACCEL_XYZ_UUID) { [weak self] (buffer:Data)->Void in
      let numBytes = min(buffer.count, MemoryLayout.size(ofValue: self!.xlRaw))
      withUnsafeMutableBytes(of: &self!.xlRaw) { pointer in
        _ = buffer.copyBytes(to:pointer, from:0..<numBytes)
      }
      self?.focusCalcAngles()
    }
    
    // Approach 3: Use Generic inout data and construct closure in setNotify (or bleRead)
    // - All the benefits of Approach 2, with a single Data type for stored
    //   closures, setNofity, and bleRead
    // - Cleanest calling format
    // - Doesn't work due to "escaping closure capturing inout parameter"
    // - There may be a solution with deferred copy of a local variable in setNotify3
    //    focusMotor.setNotify3(ACCEL_XYZ_UUID, readData: &xlData)
    
    // Start timer to disconnect when UI becomes inactive
    timerValue = TIMER_DISCONNECT_SEC
    connectionTimer = Timer.scheduledTimer(withTimeInterval: 1.0,
                                           repeats: true) { _ in
      self.uiTimerHandler()
    }
    
    statusString = "Ready"
    bleState = .ready
    
    // Check for saved action to complete once BLE is ready
    if let bleReadyAction = uponBleReadyAction {
      bleReadyAction()
      uponBleReadyAction = nil
    }
  }
  
}

