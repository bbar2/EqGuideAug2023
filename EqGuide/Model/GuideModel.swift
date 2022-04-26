//
//  GuideModel.swift
//  EqGuide
//
//  Created by Barry Bryant on 1/7/22.
//

import SwiftUI
import CoreBluetooth
import Combine
import CoreLocation

enum Knowledge {
  case none
  case estimated
  case marked
}

class GuideModel : BleWizardDelegate, ObservableObject {

  @Published var statusString = "Not Started"
  @Published var readCount = Int32(0)
  @Published var guideDataBlock = GuideDataBlock()
  @Published var refCoord = Catalogue().mizar //RaDec(ra: 97.5, dec: 25.5)
  @Published var targetCoord = Catalogue().m81 // RaDec(ra: 107.25, dec: 35.5)
  @Published var locationData = LocationData() // Should I @Published since elements are @Published elements.

  // These offsets, with current counts (in GuideDataBlock), determine angles.
  // xxAngleDeg = (xxOffsetCount * xxDegPerStep) + xxxOffsetDeg
  // Offsets are established when Marking a known object, in updateOffsetConstants()
  private var armOffsetDeg = Float32(0.0)
  private var decOffsetDeg = Float32(0.0)

  // Mount Angles
  var lstDeg = Float32(0.0)
  var armCurrentDeg = Float32(0.0)
  var decCurrentDeg = Float32(0.0)
  var raCurrentDeg = Float32(0.0)
  @Published var pointingKnowledge = Knowledge.none
  @Published var lstValid = false
  
  // Update all time depenedent model calcs at once
  // Don't do in calculated vars, because there is too much repetition in use to
  // calculate terms, and update Views.
  // Call this everytime a new GuideDataBlock arrives from Mount
  func updateMountAngles() {
    
    if let longitudeDeg = locationData.longitudeDeg {
      lstValid = true
      lstDeg = Float32(lstDegFrom(utDate: Date.now, localLongitudeDeg: longitudeDeg))
    } else {
      lstValid = false
      lstDeg = 0.0
    }

    // Arm Count's cause arm to advance CCW, to track CCW moving sky.
    armCurrentDeg = Float32(guideDataBlock.armCount) * guideDataBlock.armDegPerStep + armOffsetDeg
    decCurrentDeg = Float32(guideDataBlock.decCount) * guideDataBlock.decDegPerStep + decOffsetDeg

    // armAngle is +- ~95 deg in RA.
    // Positive armAngle is in direction of Sky Rotation (CCW).
    // Positive armAngle rotates CCW around north pole
    // When armAngle is pos: RA = LST + 90 - armAngle
    // When armAngle is neg: RA = LST - 90 - armAngle
    // Durrint tracking, LST advancement is negated by armAngle tracking
    if lstValid && (pointingKnowledge == Knowledge.marked) {
      if (armCurrentDeg < 0) {
        raCurrentDeg = lstDeg + 90.0 - armCurrentDeg
      } else {
        raCurrentDeg = lstDeg - 90.0 - armCurrentDeg
      }
    } else {
      // TODO - add elseif block for intertial calcualtion, with confidence .estimated
      // TBD: Do inertial calc now?  Every time?
      
      raCurrentDeg = lstDeg - armCurrentDeg // RA is meaningless with no pointing knowledge
    }
  }
    
  func clearOffsets() {
    armOffsetDeg = 0.0
    decOffsetDeg = 0.0
    pointingKnowledge = .none
  }
            
  var currentPosition: RaDec {
    return RaDec(ra: raCurrentDeg, dec: decCurrentDeg)
  }
  
  var offset: RaDec {
    return targetCoord - refCoord
  }

  var bleConnected: Bool {
    return statusString == "Connected"
  }
  
  /// ========== RA/Dec from References Star and Current Date/Time ==========

  // Update arm and dec offset constants.
  // armAngle is +- ~95 deg in RA.
  // Positive armAngle is in direction of Sky Rotation (CCW).
  // Positive armAngle rotates CCW around north pole
  // The current LST increases with UTC, as increasing RA moves overhead.
  func updateOffsetsToReference() {
    let refRaDeg = refCoord.ra
    let refDecDeg = refCoord.dec

    let lst = lstDeg
    clearOffsets()
    
    // When armAngle is +: RA = LST + 90 - armAngle
    // When armAngle is -: RA = LST - 90 - armAngle
    // given: armAngle = (armCount * armDegPerStep + armOffsetDeg)
    // So when armAngle is +: RA = LST + 90 - armCount * armDegPerStep - armOffsetDeg
    // So When armAngle is -: RA = LST - 90 - armCount * armDegPerStep - armOffsetDeg

    // When armAngle is unknown, infer it's sign by comparing lst and RefRaDeg
    // armAngle sign is + if refCoord.ra > lst, else armAngle sign is -
    // Bias toward negative arm angle to init to >|-90| for refRaDeg close to LST.
    let bias = Float32(2.0) // This can be up to |NegArmLimitDeg| - 90.0
    if refRaDeg >= (lst + bias) {
      // When armAngle is +: RA = LST + 90 - armCount*armDegPerStep - armOffsetDeg
      // armCurrentDeg = armCount * armDegPerStep after clearOffsets()
      armOffsetDeg = lst + 90.0 - armCurrentDeg - refRaDeg
    } else {
      // When amrAngle is -: RA = LST - 90 - armCount*armDegPerStep - armOffsetDeg
      // armCurrentDeg = armCount * armDegPerStep after clearOffsets()
      armOffsetDeg = lst - 90.0 - armCurrentDeg - refRaDeg
    }
    
    decOffsetDeg = refDecDeg - decCurrentDeg

    // Used for color coding values that depend on references
    pointingKnowledge = lstValid ? .marked : .none
  }
  

  
  
  // All UUID strings must match the Arduino C++ RocketMount UUID strings
  private let GUIDE_SERVICE_UUID = CBUUID(string: "828b0010-046a-42c7-9c16-00ca297e95eb")
  private let GUIDE_DATA_BLOCK_UUID = CBUUID(string: "828b0011-046a-42c7-9c16-00ca297e95eb")
  private let GUIDE_COMMAND_UUID = CBUUID(string: "828b0012-046a-42c7-9c16-00ca297e95eb")

  private let bleWizard: BleWizard  //contain a BleWizard

  private var initialized = false
  
  init() {
    
    self.bleWizard = BleWizard(
      serviceUUID: GUIDE_SERVICE_UUID,
      bleDataUUIDs: [GUIDE_DATA_BLOCK_UUID, GUIDE_COMMAND_UUID])

    // Force self implement all delegate methods of BleWizardDelegate protocol
    bleWizard.delegate = self
  }

  func guideModelInit() {
    if (!initialized) {
      bleWizard.start()
      statusString = "Searching for RocketMount ..."
      initViewModel()
      initialized = true
    }
  }
  
  // Called by focusMotorInit & BleDelegate overrides on BLE Connect or Disconnect
  func initViewModel() {
    // Init local variables
  }

  func reportBleScanning() {
    statusString = "Scanning ..."
  }
  
  func reportBleNotAvailable() {
    statusString = "BLE Not Available"
  }

  func reportBleServiceFound(){
    statusString = "RocketMount Found"
  }
  
  func reportBleServiceConnected(){
//    initViewModel()
    statusString = "Connected"
  }
  
  func reportBleServiceDisconnected(){
//    initViewModel()
    statusString = "Disconnected"
    readCount = 0;
  }
  
  func reportBleServiceCharaceristicsScanned() {

    // Setup notify handler for incomming data from Guide Mount
    bleWizard.setNotify(uuid: GUIDE_DATA_BLOCK_UUID) { [weak self] guideData in
      self?.processDataFromMount(guideData)
    }
    
  }
  /// ========== Read Data From Mount ==========
  //  func readVar1()  {
  //    do {
  //      try bleWizard.bleRead(uuid: GUIDE_VAR1_UUID) { [weak self] resultInt in
  //        self?.var1 = resultInt
  //        self?.readCount += 1
  //        self?.readVar1()
  //      }
  //    } catch {
  //      print(error)
  //    }
  //  }
  
  // This runs (via Notify Handler) every time EqMount sends a new GuideDataBlock (~10Hz)
  func processDataFromMount(_ guideData: GuideDataBlock) {

    // Store the new GuideDataBlock
    guideDataBlock = guideData
    readCount += 1
    updateMountAngles()

    // Process specific GuideDataBlock commands
    
    // Mark Reference on markRefNow transition away from zero
    @State var readyForRefMark = true
    if readyForRefMark && guideDataBlock.markReferenceNow {
      // Mark Reference on first GDB with markRefNow
      if readyForRefMark && guideDataBlock.markReferenceNow {
        readyForRefMark = false
        updateOffsetsToReference()
        ackReference()
        print("MarkRefNow")
      } else {
        // Reset on GDB w/o markReferenceNow
        readyForRefMark = true
      }
    }
    
    // Add code here for next specific GDB command -- ToDo Reverse
  }
  

  /// ========== Transmit Commands to Mount ==========

  func guideCommand(_ writeBlock:GuideCommandBlock) {
    bleWizard.bleWrite(GUIDE_COMMAND_UUID, writeBlock: writeBlock)
  }
  
  func targetRaDec(coord: RaDec) {
    let targetCommand = GuideCommandBlock(
      command:   GuideCommand.SetTarget.rawValue,
      raOffset:  Int32(coord.ra / guideDataBlock.armDegPerStep),
      decOffset: Int32(coord.dec / guideDataBlock.decDegPerStep)
    )
    guideCommand(targetCommand)
  }

  func offsetRaDec(coord: RaDec) {
    offsetRaDec(raOffsetDeg: coord.ra, decOffsetDeg: coord.dec)
  }
  
  func offsetRaDec(raOffsetDeg: Float, decOffsetDeg: Float){
    let offsetCommand = GuideCommandBlock(
      command:   GuideCommand.SetOffset.rawValue,
      raOffset:  Int32(raOffsetDeg / guideDataBlock.armDegPerStep),
      decOffset: Int32(decOffsetDeg / guideDataBlock.decDegPerStep)
    )
    guideCommand(offsetCommand)
  }
  
  func ackReference() {
    let ackCommand = GuideCommandBlock(
      command: GuideCommand.AckReference.rawValue,
      raOffset: Int32(0),
      decOffset: Int32(0)
    )
    guideCommand(ackCommand)
  }
    
      
}
