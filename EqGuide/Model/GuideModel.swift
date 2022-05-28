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
  @Published var refCoord = RaDec(ra: 0, dec: 0)
  @Published var targetCoord = RaDec(ra: 0, dec: 0)
  @Published var locationData = LocationData() // Should I @Published since elements are @Published elements.
  @Published var refName = ""
  @Published var targName = ""
  
  let catalog: [Target] = loadJson("TargetData.json")
  
  // These offsets, with current counts (in GuideDataBlock), determine angles.
  // xxAngleDeg = (xxOffsetCount * xxDegPerStep) + xxOffsetDeg
  // Offsets are established when Marking a known object, in updateOffsetsToReference()
  private var armOffsetDeg = 0.0
  private var diskOffsetDeg = 0.0
  
  private var lookForRateChange = false
  private var targetRateDps = Float32(0.0)
  
  // Mount Angles
  var lstDeg = 0.0
  var armCurrentDeg = 0.0
  var diskCurrentDeg = 0.0
  
  var currentPosition = RaDec()
  @Published var pointingKnowledge = Knowledge.none
  @Published var lstValid = false
  
  func updateLstDeg() {
    if let longitudeDeg = locationData.longitudeDeg {
      lstValid = true
      lstDeg = lstDegFrom(utDate: Date.now, localLongitudeDeg: longitudeDeg)
    } else {
      lstValid = false
      lstDeg = 0.0
    }
  }
  
  func swapRefAndTarg() {
    let temp = refCoord
    refCoord = targetCoord
    targetCoord = temp
    let tempName = targName
    targName = refName
    refName = tempName
  }
  
  // Update all time dependent model calcs at once
  // Don't do in calculated vars, because there is too much repetition building
  // terms, and updating Views.
  // Call this everytime a new GuideDataBlock arrives from Mount
  func updateMountAngles() {
    
    updateLstDeg() // Function of time (always changing) and longitude
    
    // Positive Count's advance axes CCW, looking to Polaris or top of scope
    armCurrentDeg = guideDataBlock.armCountDeg + armOffsetDeg
    diskCurrentDeg = guideDataBlock.diskCountDeg + diskOffsetDeg
    
    // armAngle is +- ~95 deg in RA.
    // Positive armAngle is in direction of Sky Rotation (CCW).
    // Positive armAngle rotates CCW around north pole
    // When armAngle is pos: RA = LST + 90 - armCurrentDeg; DEC = diskCurrentDeg
    // When armAngle is neg: RA = LST - 90 - armCurrentDeg; DEC = -diskCurrentDeg
    // Durring tracking, LST advancement is negated by armAngle tracking
    if lstValid && (pointingKnowledge != Knowledge.none) {
      if (armCurrentDeg > 0) {
        currentPosition.ra = lstDeg + 90.0 - armCurrentDeg
        currentPosition.dec = diskCurrentDeg
      } else {
        currentPosition.ra = lstDeg - 90.0 - armCurrentDeg
        currentPosition.dec = 180.0 - diskCurrentDeg
      }
    } else {
      // TODO - add elseif block for intertial calcualtion, with confidence .estimated
      // TBD: Do inertial calc now?  Every time?
      
      currentPosition.ra = lstDeg - armCurrentDeg // RA unknown without pointing knowledge
      currentPosition.dec = diskCurrentDeg // DEC unknown without pointing knowledge
    }
  }
  
  // ArmAngleDeg given hemisphere knowledge of LST vs RA
  func armAngleDeg(lst: Double, ra: Double) -> Double {
    if (ra > lst) {
      return lst + 90.0 - ra
    } else  {
      return lst - 90.0 - ra
    }
  }
  
  // DiskAngleDeg given hemisphere knowledge of LST vs RA
  func diskAngleDeg(lst: Double, coord: RaDec) -> Double {
    if (coord.ra > lst) {
      return coord.dec
    } else  {
      return 180.0 - coord.dec
    }
  }
  
  // Uses LST, Reference, and Target to build arm angle change required to move from
  // Reference.ra to Target.ra
  // TODO - what do I do if LST or REF knowledge == .none
  func armDeltaDeg(fromDeg: Double, toDeg: Double) -> Double {
    let fromArmDeg = armAngleDeg(lst: lstDeg, ra: fromDeg)
    let toArmDeg = armAngleDeg(lst: lstDeg, ra: toDeg)
    let deltaDeg = toArmDeg - fromArmDeg
    
    return deltaDeg
  }
  
  // Uses LST, Reference, and Target to build disk angle change required to move from
  // Reference.dec to Target.dec
  func diskDeltaDeg(fromCoord: RaDec, toCoord: RaDec) -> Double {
    let fromDiskDeg = diskAngleDeg(lst: lstDeg, coord: fromCoord)
    let toDiskDeg = diskAngleDeg(lst: lstDeg, coord: toCoord)
    
    var deltaDiskDeg = toDiskDeg - fromDiskDeg
    
    // Take shorter route if |deltaDiskDeg| > 180.0
    if deltaDiskDeg > 180.0 {
      deltaDiskDeg = deltaDiskDeg - 360.0 // go -170 instead of +190
    } else if deltaDiskDeg < -180.0 {
      deltaDiskDeg = deltaDiskDeg + 360.0 // go 170 instead of -190
    }
    
    return deltaDiskDeg
  }
  
  func anglesReferenceToTarget() -> RaDec {
    return RaDec(ra: armDeltaDeg(fromDeg: refCoord.ra,
                                 toDeg: targetCoord.ra),
                 dec: diskDeltaDeg(fromCoord: refCoord,
                                   toCoord: targetCoord) )
  }
  
  func anglesCurrentToTarget() -> RaDec {
    return RaDec(ra: armDeltaDeg(fromDeg: currentPosition.ra,
                                 toDeg: targetCoord.ra),
                 dec: diskDeltaDeg(fromCoord: currentPosition,
                                   toCoord: targetCoord) )
  }
  
  
  var bleConnected: Bool {
    return statusString == "Connected"
  }
  
  /// ========== RA/Dec from References star and Current Date/Time ==========
  
  // Update arm and dec offset constants.
  // armAngle is +- ~95 deg in RA.
  // Positive armAngle is in direction of Sky Rotation (CCW).
  // Positive armAngle rotates CCW around north pole
  // The current LST increases with UTC, as increasing RA moves overhead.
  func updateOffsetsToReference() {
    let armCountDeg = guideDataBlock.armCountDeg
    let diskCountDeg = guideDataBlock.diskCountDeg
    
    let refRaDeg = refCoord.ra
    let refDecDeg = refCoord.dec
    
    updateLstDeg()
    
    // When armAngle is +: RA = LST + 90 - armAngle
    // When armAngle is -: RA = LST - 90 - armAngle
    // given: armAngle = (armCount * armDegPerStep + armOffsetDeg)
    // So when armAngle is +: RA = LST + 90 - armCount * armDegPerStep - armOffsetDeg
    // So When armAngle is -: RA = LST - 90 - armCount * armDegPerStep - armOffsetDeg
    
    // When armAngle is unknown, infer it's sign by comparing lst and RefRaDeg.
    // armAngle sign is + if refCoord.ra > lst, else armAngle sign is -
    // Bias toward negative arm angle to init to >|-90| for refRaDeg close to LST.
    let bias = 2.0 // This can be up to |NegArmLimitDeg| - 90.0
    if refRaDeg >= (lstDeg + bias) {
      // When armAngle is +:
      //  RA = LST + 90 - armCountDeg - armOffsetDeg
      //  DEC = diskCountDeg + diskOffset
      armOffsetDeg = lstDeg + 90.0 - armCountDeg - refRaDeg
      diskOffsetDeg = refDecDeg - diskCountDeg
    } else {
      // When amrAngle is -:
      //   RA = LST - 90 - armCountDeg - armOffsetDeg
      //   DEC = 180.0 - diskCountDeg - diskOffset
      armOffsetDeg = lstDeg - 90.0 - armCountDeg - refRaDeg
      diskOffsetDeg = 180.0 - diskCountDeg - refDecDeg
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
    
    // Setup initial Reference and Target
    let refIndex = 0
    refCoord = RaDec(ra: catalog[refIndex].ra, dec: catalog[refIndex].dec)
    refName = catalog[refIndex].name
    let targIndex = 1
    targetCoord = RaDec(ra: catalog[targIndex].ra, dec: catalog[targIndex].dec)
    targName = catalog[targIndex].name
    
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
      } else {
        // Reset on GDB w/o markReferenceNow
        readyForRefMark = true
      }
    }
    
    // Add code here for next specific GDB command
    if lookForRateChange {
      if abs(guideDataBlock.raRateOffsetDegPerSec - targetRateDps) < 0.0001 {
        heavyBump()
        lookForRateChange = false
      }
    }
  }
  
  
  /// ========== Transmit Commands to Mount ==========
  /// Build and transmit GuideCommandBlocks
  /// Convert native iOS app types to Arduino types here - i.e. Doubles to Int32 Counts
  /// No angle conversions or hemisphere awareness at this level.
  
  func guideCommand(_ writeBlock:GuideCommandBlock) {
    bleWizard.bleWrite(GUIDE_COMMAND_UUID, writeBlock: writeBlock)
  }
  
  // Target Command - Offset from a reference.
  // Mount will Mark Reference then move to offset.
  func guideCommandReferenceToTarget(){
    let armDeg = armDeltaDeg(fromDeg: refCoord.ra, toDeg: targetCoord.ra)
    let diskDeg = diskDeltaDeg(fromCoord: refCoord, toCoord: targetCoord)
    let refToTargetCommand = GuideCommandBlock(
      command: GuideCommand.SetTarget.rawValue,
      armOffset: Int32( Float32(armDeg) / guideDataBlock.armDegPerStep),
      diskOffset: Int32( Float32(diskDeg) / guideDataBlock.diskDegPerStep),
      raRateOffsetDps: Float32(0.0)
    )
    guideCommand(refToTargetCommand)
  }
  
  // Offset Command - Relative offset.
  // Mount moves offset amount from current position.
  func guideCommandCurrentToTarget(){
    let armDeg = armDeltaDeg(fromDeg: currentPosition.ra, toDeg: targetCoord.ra)
    let diskDeg = diskDeltaDeg(fromCoord: currentPosition, toCoord: targetCoord)
    let currentToTargetCommand = GuideCommandBlock(
      command: GuideCommand.SetOffset.rawValue,
      armOffset: Int32( Float32(armDeg) / guideDataBlock.armDegPerStep),
      diskOffset: Int32( Float32(diskDeg) / guideDataBlock.diskDegPerStep),
      raRateOffsetDps: Float32(0.0)
    )
    guideCommand(currentToTargetCommand)
  }
  
  // Send track rate adjustment to Mount.
  func guideCommandSetRaRateOffsetDps(newDps: Double) {
    let rateCommand = GuideCommandBlock(
      command: GuideCommand.SetRaOffsetDps.rawValue,
      armOffset: Int32(0),
      diskOffset: Int32(0),
      raRateOffsetDps: Float32(newDps)
    )
    targetRateDps = Float32(newDps);
    lookForRateChange = true;
    guideCommand(rateCommand)
  }
  
  // Acknolwledge Reference Mark - offset's not used
  // Marking the reference, deserved a handshake.
  // Mount holds GuideDataBlock.markRefNowInt != 0 until it receives this CommandBlock.
  func ackReference() {
    let ackCommand = GuideCommandBlock(
      command: GuideCommand.AckReference.rawValue,
      armOffset: Int32(0),
      diskOffset: Int32(0),
      raRateOffsetDps: Float32(0.0)
    )
    guideCommand(ackCommand)
  }
  
}
