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
  // xxAngleDeg = (xxOffsetCount * xxDegPerStep) + xxOffsetDeg
  // Offsets are established when Marking a known object, in updateOffsetConstants()
  private var armOffsetDeg = Float32(0.0)
  private var diskOffsetDeg = Float32(0.0)

  // Mount Angles
  var lstDeg = Float32(0.0)
  var armCurrentDeg = Float32(0.0)
  var diskCurrentDeg = Float32(0.0)

  var raCurrentDeg = Float32(0.0)
  var decCurrentDeg = Float32(0.0)
  @Published var pointingKnowledge = Knowledge.none
  @Published var lstValid = false
  
  func updateLstDeg() {
    if let longitudeDeg = locationData.longitudeDeg {
      lstValid = true
      lstDeg = Float32(lstDegFrom(utDate: Date.now, localLongitudeDeg: longitudeDeg))
    } else {
      lstValid = false
      lstDeg = 0.0
    }
  }
  
  // Update all time dependent model calcs at once
  // Don't do in calculated vars, because there is too much repetition building
  // terms, and updating Views.
  // Call this everytime a new GuideDataBlock arrives from Mount
  func updateMountAngles() {
    
    updateLstDeg() // Function of time (always changing) and longitude

    // Positive Count's advance axes CCW, looking to Polaris or top of scope
    armCurrentDeg = Float32(guideDataBlock.armCount) * guideDataBlock.armDegPerStep + armOffsetDeg
    diskCurrentDeg = Float32(guideDataBlock.diskCount) * guideDataBlock.diskDegPerStep + diskOffsetDeg

    // armAngle is +- ~95 deg in RA.
    // Positive armAngle is in direction of Sky Rotation (CCW).
    // Positive armAngle rotates CCW around north pole
    // When armAngle is pos: RA = LST + 90 - armCurrentDeg; DEC = diskCurrentDeg
    // When armAngle is neg: RA = LST - 90 - armCurrentDeg; DEC = -diskCurrentDeg
    // Durring tracking, LST advancement is negated by armAngle tracking
    if lstValid && (pointingKnowledge != Knowledge.none) {
      if (armCurrentDeg > 0) {
        raCurrentDeg = lstDeg + 90.0 - armCurrentDeg
        decCurrentDeg = diskCurrentDeg
      } else {
        raCurrentDeg = lstDeg - 90.0 - armCurrentDeg
        decCurrentDeg = -diskCurrentDeg
      }
    } else {
      // TODO - add elseif block for intertial calcualtion, with confidence .estimated
      // TBD: Do inertial calc now?  Every time?
      
      raCurrentDeg = lstDeg - armCurrentDeg // RA unknown without pointing knowledge
      decCurrentDeg = diskCurrentDeg // DEC unknown without pointing knowledge
    }
  }
    
  var currentPosition: RaDec {
    return RaDec(ra: raCurrentDeg, dec: decCurrentDeg)
  }
  
  // TODO Declination Flip in here.  Check hemispheres of ref and target.
  // Returned values are arm and disk changes required.
  var offset: RaDec {
    // Get LST
    let LST = Float(1.0)

    let target = targetCoord
    let ref = refCoord
    
    var targetArm = 0.0
    var targetDisk = 0.0
    var refArm = 0.0
    var refDisk = 0.0
    
    if (targetCoord.ra > LST) {
      targetArm = 0.0//LST + 90.0 - target.ra
    } else {
      targetArm = 0.0//LST - 90.0 - target.ra
    }
        
    // Find arm and disk angle for taget and Ref
    
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

    let armCountDeg = Float32(guideDataBlock.armCount) * guideDataBlock.armDegPerStep
    let diskCountDeg = Float32(guideDataBlock.diskCount) * guideDataBlock.diskDegPerStep

    updateLstDeg()

    // When armAngle is +: RA = LST + 90 - armAngle
    // When armAngle is -: RA = LST - 90 - armAngle
    // given: armAngle = (armCount * armDegPerStep + armOffsetDeg)
    // So when armAngle is +: RA = LST + 90 - armCount * armDegPerStep - armOffsetDeg
    // So When armAngle is -: RA = LST - 90 - armCount * armDegPerStep - armOffsetDeg

    // When armAngle is unknown, infer it's sign by comparing lst and RefRaDeg.
    // armAngle sign is + if refCoord.ra > lst, else armAngle sign is -
    // Bias toward negative arm angle to init to >|-90| for refRaDeg close to LST.
    let bias = Float32(2.0) // This can be up to |NegArmLimitDeg| - 90.0
    if refRaDeg >= (lstDeg + bias) {
      // When armAngle is +:
      //  RA = LST + 90 - armCount*armDegPerStep - armOffsetDeg
      //  DEC = diskCount*diskDegPerStep + diskOffset
      armOffsetDeg = lstDeg + 90.0 - armCountDeg - refRaDeg
      diskOffsetDeg = refDecDeg - diskCountDeg
    } else {
      // When amrAngle is -:
      //   RA = LST - 90 - armCount*armDegPerStep - armOffsetDeg
      //   DEC = -diskCount*diskDegPerStep - diskOffset
      armOffsetDeg = lstDeg - 90.0 - armCountDeg - refRaDeg
      diskOffsetDeg = -diskCountDeg - refRaDeg
    }
    
    // Used for color coding values that depend on references
    pointingKnowledge = lstValid ? .marked : .none
    print("armOffsetDeg = \(armOffsetDeg)")
    print("decOffsetDeg = \(diskOffsetDeg)")
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
    if guideDataBlock.mountState == MountState.PowerUp.rawValue {
      pointingKnowledge = .none
    }
    
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
  
  // todo - no flipping in here.  Don't know enough.  This can convert degree offsets to counts.  Nothing else.
  func targetRaDec(coord: RaDec) {
    // Arm moves opposite direction of increasing RA
    let armOffset = -coord.ra / guideDataBlock.armDegPerStep
    let targetCommand = GuideCommandBlock(
      command: GuideCommand.SetTarget.rawValue,
      armOffset: Int32(armOffset),
      diskOffset: Int32(coord.dec / guideDataBlock.diskDegPerStep)
    )
    guideCommand(targetCommand)
  }

  // todo - udpate diskOffset(dec) as function of RA and LST.
  func offsetRaDec(coord: RaDec) {
    // Arm moves opposite direction of increasing RA
    let targetCommand = GuideCommandBlock(
      command: GuideCommand.SetOffset.rawValue,
      armOffset: Int32(-coord.ra / guideDataBlock.armDegPerStep),
      diskOffset: Int32(coord.dec / guideDataBlock.diskDegPerStep)
    )
    guideCommand(targetCommand)
  }
    
  func ackReference() {
    let ackCommand = GuideCommandBlock(
      command: GuideCommand.AckReference.rawValue,
      armOffset: Int32(0),
      diskOffset: Int32(0)
    )
    guideCommand(ackCommand)
  }
    
      
}
