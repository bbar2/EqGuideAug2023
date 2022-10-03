//
//  GuideModel.swift
//  EqGuide
//
//  Created by Barry Bryant on 1/7/22.
//
//  The mount Arm Angle rotates in Right Ascension.
//  + is CCW looking at North pole, is direction of sky rotation.
//  Arm angle is:
//    90 when arm is horizontal on west side
//   -90 when arm is horizontal on east side
//     0 when arm is vertical
//  Arm Angle range of motion is +- ~95 deg in RA.
//
//  The mount Disk Angle (aka dsk) rotates in Declination.
//  + is CCW looking up from bottom of disk.
//  Disk angle is:
//    90 pointing at north pole
//   -90 at south pole
//     0 at equatorial plane
//
//  The RA/DEC to arm/disk relationship depends on wich side of pier the target is on,
//  or arm hemisphere determined by RA vs LST
//    If RA >= LST (Local Sidereal Time)
//      armAngle = LST + 90 - RA
//      diskAngle = DEC
//    Else If RA <= LST
//      armAngle = LST - 90 - RA
//      diskAngle = 180 - DEC
//
//  ArmFlip - To look into the wedge of sky below polaris, fabs(armAngle) must be > 90.0.
//  The arm can't go far into this wedge due to mechanical interference with the mount
//  starting near +-95 degrees.
//  To look into this wedge, flip both armAngle and diskAngle by 180 degrees.
//  - When calculating angles from RaDec, ArmFlip if armAngle exceeds hardware limits.
//  - When calculating RaDec from angles, detect ArmFlip if |DEC| > 90

//  TODO: What is impact of ~2 degree padding on pier hemisphere flip.


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
  private var dskOffsetDeg = 0.0
  
  private var lookForRateChange = false
  private var targetRateDps = Float32(0.0)
  
  // Mount Angles
  var lstDeg = 0.0
  var armCurrentDeg = 0.0
  var dskCurrentDeg = 0.0
  
  var currentPosition = RaDec()
  @Published var pointingKnowledge = Knowledge.none
  @Published var lstValid = false
  
  var bleConnected: Bool {
    return statusString == "Connected"
  }
  
  // All UUID strings must match the Arduino C++ RocketMount UUID strings
  private let GUIDE_SERVICE_UUID = CBUUID(string: "828b0010-046a-42c7-9c16-00ca297e95eb")
  private let GUIDE_DATA_BLOCK_UUID = CBUUID(string: "828b0011-046a-42c7-9c16-00ca297e95eb")
  private let GUIDE_COMMAND_UUID = CBUUID(string: "828b0012-046a-42c7-9c16-00ca297e95eb")
  
  private let bleWizard: BleWizard  //contain a BleWizard
  
  private var initialized = false
  
  func updateLstDeg() {
    if let longitudeDeg = locationData.longitudeDeg {
      lstValid = true
      lstDeg = lstDegFrom(utDate: Date.now, localLongitudeDeg: longitudeDeg)
//      lstDeg = 282.0 // Staunton River, Sep 14, 8:30PM
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
  // Update mount angles, and Current RA/DEC from new Counts.
  // Don't do in calculated vars, because there is too much repetition building
  // terms, and updating Views.
  // Call this everytime a new GuideDataBlock arrives from Mount
  func updateMountAngles() {
    
    updateLstDeg() // Function of time (always changing) and longitude
    
    // Positive Count's advance axes CCW, looking to Polaris or top of scope
    armCurrentDeg = guideDataBlock.armCountDeg + armOffsetDeg
    dskCurrentDeg = guideDataBlock.dskCountDeg + dskOffsetDeg
    
    // Side of Pier determination
    if lstValid && (pointingKnowledge != Knowledge.none) {
      if (armCurrentDeg > 0) { // pointing toward east side of pier
        currentPosition.ra = lstDeg + 90.0 - armCurrentDeg
        currentPosition.dec = dskCurrentDeg
      } else { // pointing to west side of pier
        currentPosition.ra = lstDeg - 90.0 - armCurrentDeg
        currentPosition.dec = 180.0 - dskCurrentDeg
      }
    } else {
      // TODO - add elseif block for intertial calcualtion, with confidence .estimated
      // TBD: Do inertial calc now?  Every time?
      
      currentPosition.ra = armCurrentDeg  // RA unknown without pointing knowledge
      currentPosition.dec = dskCurrentDeg // DEC unknown without pointing knowledge
    }
    
    // TODO:  Test this azimuth flip detection
    // Check for azimuth flip; aka unreachable arm angle (not side of pier flip)
    if fabs(currentPosition.dec) > 90.0 { // in an azimuth flip.
      if currentPosition.ra > 180.0 {
        currentPosition.ra -= 180.0
      } else {
        currentPosition.ra += 180.0
      }
      
      if currentPosition.dec > 90.0 {
        currentPosition.dec -= 180.0
      } else {
        currentPosition.dec += 180.0
      }
    }
    
  } // end updateMountAngles
  
  // Mount Angles from RaDec given hemisphere knowledge of LST vs RA
  func mountAnglesForRaDec(lst: Double, coord: RaDec) ->
  (armDeg: Double, dskDeg:Double, isFlipped:Bool) {
    var armDeg = 0.0
    var dskDeg = 0.0
    var isFlipped = false

    // Side of pier consideration
    if (coord.ra > lst) {
      armDeg = lst + 90.0 - coord.ra
      dskDeg = coord.dec
    } else  {
      armDeg = lst - 90.0 - coord.ra
      dskDeg = 180.0 - coord.dec
    }

    // If arm angle unreachable, flip both axis by 180
    if fabs(armDeg) > 90.0 {
      armDeg = armDeg > 0.0 ? armDeg - 180.0 : armDeg + 180.0
      dskDeg = dskDeg > 0.0 ? dskDeg - 180.0 : dskDeg + 180.0
      isFlipped = true
    }
    
    return (armDeg, dskDeg, isFlipped)
  }
  
  // Uses LST, to build mount angle changes required to move fromCoord toCoord
  // TODO - what do I do if LST or REF knowledge == .none
  func mountAngleChange(fromCoord: RaDec, toCoord: RaDec) ->
  (armAngle: Double, diskAngle: Double) {
    let (fromArmDeg, fromDskDeg, _) = mountAnglesForRaDec(lst: lstDeg, coord: fromCoord)
    let (toArmDeg, toDskDeg, _) = mountAnglesForRaDec(lst: lstDeg, coord: toCoord)

    let deltaArmDeg = toArmDeg - fromArmDeg
    var deltaDskDeg = toDskDeg - fromDskDeg
    
    // Take shorter route if |deltaDiskDeg| > 180.0
    if deltaDskDeg > 180.0 {
      deltaDskDeg = deltaDskDeg - 360.0 // go -170 instead of +190
    } else if deltaDskDeg < -180.0 {
      deltaDskDeg = deltaDskDeg + 360.0 // go 170 instead of -190
    }
    
    return (deltaArmDeg, deltaDskDeg)
  }
  
  func anglesReferenceToTarget() -> RaDec {
    var armDeg = 0.0
    var diskDeg = 0.0
    (armDeg, diskDeg) = mountAngleChange(fromCoord: refCoord, toCoord: targetCoord)
    return RaDec(ra:armDeg, dec: diskDeg)
  }
  
  func anglesCurrentToTarget() -> RaDec {
    var armDeg = 0.0
    var diskDeg = 0.0
    (armDeg, diskDeg) = mountAngleChange(fromCoord: currentPosition, toCoord: targetCoord)
    return RaDec(ra:armDeg, dec: diskDeg)
  }
  
  /// ========== RA/Dec from References star and Current Date/Time ==========
  
  //////////////////////////////////
  /// DIFFERENT FIX NEEDED in updateOffsetsToReference() - must integrate the unreachable RA flip.
  //////////////////////////////////
  // Update arm and dec offset constants.
  // armAngle is +- ~95 deg in RA.
  // Positive armAngle is in direction of Sky Rotation (CCW).
  // Positive armAngle rotates CCW around north pole
  // The current LST increases with UTC, as increasing RA moves overhead.
  func updateOffsetsToReference() {
    let armCountDeg = guideDataBlock.armCountDeg
    let dskCountDeg = guideDataBlock.dskCountDeg
    
    let refRaDeg = refCoord.ra
    let refDecDeg = refCoord.dec
    
    updateLstDeg()
    
    // For pos armAngle: RA = LST + 90 - armAngle
    // For neg armAngle: RA = LST - 90 - armAngle
    // given: armAngle = (armCount * armDegPerStep + armOffsetDeg)
    // So for pos armAngle: RA = LST + 90 - armCount * armDegPerStep - armOffsetDeg
    // So for neg armAngle: RA = LST - 90 - armCount * armDegPerStep - armOffsetDeg
    
    // When armAngle is unknown, infer its sign by comparing LST and RefRaDeg.
    // armAngle sign is + if refCoord.ra > LST, else armAngle sign is -
    // Bias toward negative arm angle to init to >|-90| for refRaDeg close to LST.
    let bias = 2.0 // This can be up to |NegArmLimitDeg| - 90.0 = ~ 5.0 deg
    if refRaDeg >= (lstDeg + bias) {
      // When armAngle is +:
      //  RA = LST + 90 - armCountDeg - armOffsetDeg
      //  DEC = dskCountDeg + diskOffset
      armOffsetDeg = lstDeg + 90.0 - armCountDeg - refRaDeg
      dskOffsetDeg = refDecDeg - dskCountDeg
    } else {
      // When amrAngle is -:
      //   RA = LST - 90 - armCountDeg - armOffsetDeg
      //   DEC = 180.0 - (dskCountDeg + diskOffset)
      armOffsetDeg = lstDeg - 90.0 - armCountDeg - refRaDeg
      dskOffsetDeg = 180.0 - dskCountDeg - refDecDeg
    }
    
    // Used for color coding values that depend on references
    pointingKnowledge = lstValid ? .marked : .none
    print("armOffsetDeg = \(armOffsetDeg)")
    print("decOffsetDeg = \(dskOffsetDeg)")

  }  // end updateOffsetsToReference
  
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
    let refIndex = 1
    refCoord = RaDec(ra: catalog[refIndex].ra, dec: catalog[refIndex].dec)
    refName = catalog[refIndex].name
    let targIndex = 20
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
      let oneArcSecPerMin = Float32(1.0 / (3600.0 * 60.0))
      if abs(guideDataBlock.raRateOffsetDegPerSec - targetRateDps) < oneArcSecPerMin {
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
    var armDeg = 0.0
    var diskDeg = 0.0
    (armDeg, diskDeg) = mountAngleChange(fromCoord: refCoord, toCoord: targetCoord)

//    let armDeg = armDeltaDeg(fromCoord: refCoord, toCoord: targetCoord)
//    let diskDeg = diskDeltaDeg(fromCoord: refCoord, toCoord: targetCoord)
    let refToTargetCommand = GuideCommandBlock(
      command: GuideCommand.SetTarget.rawValue,
      armOffset: Int32( Float32(armDeg) / guideDataBlock.armDegPerStep),
      dskOffset: Int32( Float32(diskDeg) / guideDataBlock.dskDegPerStep),
      raRateOffsetDps: Float32(0.0)
    )
    guideCommand(refToTargetCommand)
  }
  
  // Offset Command - Relative offset.
  // Mount moves offset amount from current position.
  func guideCommandCurrentToTarget(){
    var armDeg = 0.0
    var diskDeg = 0.0
    (armDeg, diskDeg) = mountAngleChange(fromCoord: refCoord, toCoord: targetCoord)
    
//    let armDeg = armDeltaDeg(fromCoord: currentPosition, toCoord: targetCoord)
//    let diskDeg = diskDeltaDeg(fromCoord: currentPosition, toCoord: targetCoord)
    let currentToTargetCommand = GuideCommandBlock(
      command: GuideCommand.SetOffset.rawValue,
      armOffset: Int32( Float32(armDeg) / guideDataBlock.armDegPerStep),
      dskOffset: Int32( Float32(diskDeg) / guideDataBlock.dskDegPerStep)
    )
    guideCommand(currentToTargetCommand)
  }
  
  // Send track rate adjustment to Mount.
  func guideCommandSetRaRateOffsetDps(newDps: Double) {
    let rateCommand = GuideCommandBlock(
      command: GuideCommand.SetRaOffsetDps.rawValue,
      raRateOffsetDps: Float32(newDps)
    )
    targetRateDps = Float32(newDps);
    lookForRateChange = true;
    guideCommand(rateCommand)
  }
  
  func guideCommandPauseTracking() {
    let pauseCommand = GuideCommandBlock(
      command: GuideCommand.PauseTracking.rawValue)
    guideCommand(pauseCommand)
  }
  
  func guideCommandResumeTracking() {
    let resumeCommand = GuideCommandBlock(
      command: GuideCommand.ResumeTracking.rawValue)
    guideCommand(resumeCommand)
  }
  
  // Acknolwledge Reference Mark - offset's not used
  // Marking the reference, deserved a handshake.
  // Mount holds GuideDataBlock.markRefNowInt != 0 until it receives this CommandBlock.
  func ackReference() {
    let ackCommand = GuideCommandBlock(
      command: GuideCommand.AckReference.rawValue
    )
    guideCommand(ackCommand)
  }
  
}
