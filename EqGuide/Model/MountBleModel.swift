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
import simd

enum Knowledge {
  case none
  case estimated
  case marked
}

enum ArrowMode {
  case fast
  case slow
}

class MountBleModel : MyPeripheralDelegate, ObservableObject {
  
  @Published var statusString = "Not Started"
  @Published var readCount = Int32(0)
  @Published var guideDataBlock = GuideDataBlock()
  @Published var refCoord = RaDec(ra: 0, dec: 0)
  @Published var targetCoord = RaDec(ra: 0, dec: 0)
  @Published var locationData = LocationData() // Should I @Published since elements are @Published elements?
  @Published var refName = ""
  @Published var targName = ""
  
  private var  readyForRefMark = true

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
  
  var xlAligned = simd_float3(x: 0, y: 0, z: 0)
  var theta = Float(0.0)  // Mount pitch toward Polaris, or rotation around y
  
  // ToDo: These fixed arm reference positions must advance with lst.
  // update in updateMountAngles()
  // todo - or think of them in terms of arm and dsk, then go backward to RA and DEC.
  private var refArmVert = RaDec()
  private var refArmEast = RaDec()
  private var refArmWest = RaDec()
  
  @Published var raIsTracking = true
  
  // Manual Control stuff
  @Published var arrowPadSpeed = ArrowMode.slow
  
  func bleConnected() -> Bool {
    return statusString == "Connected"
  }
  
  // All UUID strings must match the Arduino C++ RocketMount UUID strings
  private let GUIDE_DEVICE_NAME = "EqMountGuideService"
  private let GUIDE_SERVICE_UUID = CBUUID(string: "828b0010-046a-42c7-9c16-00ca297e95eb")
  private let GUIDE_DATA_BLOCK_UUID = CBUUID(string: "828b0011-046a-42c7-9c16-00ca297e95eb")
  private let GUIDE_COMMAND_UUID = CBUUID(string: "828b0012-046a-42c7-9c16-00ca297e95eb")
  
  private let rocketMount: MyPeripheral
  
  private var initialized = false
  
  private var fpic = true
  private var lstOffset = 0.0
  
  init() {
    
    self.rocketMount = MyPeripheral(
      deviceName: GUIDE_DEVICE_NAME,
      serviceUUID: GUIDE_SERVICE_UUID,
      dataUUIDs: [GUIDE_DATA_BLOCK_UUID, GUIDE_COMMAND_UUID])
    
    // Must implement all delegate methods of MyPeripheralDelegate protocol
    rocketMount.mpDelegate = self
  }
  
  func mountModelInit() {
    if (!initialized) {
      rocketMount.startBleConnection()
      statusString = "Searching for RocketMount ..."
      initLocalMembers()
      initialized = true
    }
    
    // Setup initial Reference and Target
    //    let refIndex = 0
    //    refCoord = RaDec(ra: catalog[refIndex].ra, dec: catalog[refIndex].dec)
    //    refName = catalog[refIndex].name
    let targIndex = 3
    targetCoord = RaDec(ra: catalog[targIndex].ra, dec: catalog[targIndex].dec)
    targName = catalog[targIndex].name
    
  }
  
  // Called by focusMotorInit & BleDelegate overrides on BLE Connect or Disconnect
  func initLocalMembers() {
    // Init local variables
  }
  
  //MARK: === Angle Processing ===
  
  func updateLstDeg() {
    if let longitudeDeg = locationData.longitudeDeg {
      lstValid = true
      lstDeg = lstDegFrom(utDate: Date.now, localLongitudeDeg: longitudeDeg)
      
      if fpic {
        // gen offset so LST advances from debug value
        lstOffset = 0.0 // leave this only for normal operation.
                        //lstOffset = 282.0 - lstDeg // Staunton River, Sep 14, 8:30PM
                        //lstOffset = 90.0 - lstDeg // match figure
      }
      lstDeg += lstOffset
      
      if fpic {
        // keep in mind that dec=90 corresponds to dsk=0, which counts as east looking
        //refCoord = RaDec(ra: lstDeg - 90.0, dec: 90.0) // vertical align
        //refName = "Vert Pier"
        refCoord = RaDec(ra: lstDeg, dec: 90.0) // pier east align
        refName = "East Pier"
        //refCoord = RaDec(ra: lstDeg + 180.1, dec: 90.0) // pier west align
        //refName = "West Pier"
        fpic = false
      }
      
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
    
    updateLstDeg() // LST is function of time and longitude
    
    // Positive Count's advance axes CCW, looking to Polaris or top of scope
    armCurrentDeg = guideDataBlock.armCountDeg + armOffsetDeg
    dskCurrentDeg = guideDataBlock.dskCountDeg + dskOffsetDeg
    
    // Looking to which side of pier (dsk<=0 looks east; dsk>0 looks west)
    if lstValid && (pointingKnowledge != Knowledge.none) {
      if (dskCurrentDeg <= 0) { // lens is looking to east side of pier
        currentPosition.ra = lstDeg + 90.0 - armCurrentDeg
        currentPosition.dec = dskCurrentDeg + 90.0
      } else { // looking to west side of pier
        currentPosition.ra = lstDeg + 270.0 - armCurrentDeg
        currentPosition.dec = 90.0 - dskCurrentDeg
      }
    } else {
      // TODO - add elseif block for intertial calcualtion, with confidence .estimated
      // TBD: Do inertial calc now?  Every time?
      //      print("updateMountAngles pointingKnowledge = \(pointingKnowledge)")
      
      currentPosition.ra = armCurrentDeg  // RA unknown without pointing knowledge
      currentPosition.dec = dskCurrentDeg // DEC unknown without pointing knowledge
    }
    
    // update fixed reference positions based on current lst
    // NOT USING YET - hardwired in updateLstDeg() fpic for now
    refArmVert = RaDec(ra: lstDeg - 90.0, dec: 90.0)  // pier vertical align
    refArmEast = RaDec(ra: lstDeg, dec: 90.0)         // pier east align
    refArmWest = RaDec(ra: lstDeg + 180.1, dec: 90.0) // pier west align
    
  } // end updateMountAngles
  
  // Raw Mount Angles from coord of observed target and LST
  func mountAnglesForRaDec(_ coord: RaDec) ->
  (armDeg: Double, dskDeg:Double) {
    var armDeg = 0.0
    var dskDeg = 0.0
    
    // Find angle between LST and RA
    var raLst = coord.ra - lstDeg;
    
    // Map to 0.0 <= raLst < 360.0
    if raLst < 0.0 {
      raLst += 360.0
    } else if raLst >= 360 {
      raLst -= 360.0
    }
    
    // Select arm and dsk angles based on target side of lst (raLst = ra-lst)
    // For 0 <= raLst < 360:  (360.0 maps to 0.0)
    // looking east:  0<= raLst < 180.0  (define 0 as looking east)
    // Looking west: 180.0 <= raLst < 360.0 (define 180 as looking west)
    if raLst >= 180.0 {
      armDeg = 270.0 - raLst
      dskDeg = 90.0 - coord.dec
    } else {
      armDeg = 90.0 - raLst
      dskDeg = coord.dec - 90.0
    }
    
    return (armDeg, dskDeg)
  }
  
  // Uses LST, to build mount angle changes required to move fromCoord toCoord
  // TODO - what do I do if LST or REF knowledge == .none
  func mountAngleChange(fromCoord: RaDec, toCoord: RaDec) ->
  (armAngle: Double, diskAngle: Double) {
    let (fromArmDeg, fromDskDeg) = mountAnglesForRaDec(fromCoord)
    let (toArmDeg, toDskDeg) = mountAnglesForRaDec(toCoord)
    
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
  
  // Given knowledge of current RA/DEC, and the current arm and dsk counts,
  // calculate the offsets.  Do this when looking at a reference coordinate.
  func updateOffsetsToReference() {
    
    updateLstDeg()
    
    let (refArmAngle, refDskAngle) = mountAnglesForRaDec(refCoord)
    
    // given:
    //  armAngle = guideDataBlock.armCountDeg + armOffsetDeg
    //  dskAngle = guideDataBlock.dskCountDeg + dskOffsetDeg
    armOffsetDeg = refArmAngle - guideDataBlock.armCountDeg
    dskOffsetDeg = refDskAngle - guideDataBlock.dskCountDeg
    
    // Used for color coding values that depend on references
    pointingKnowledge = lstValid ? .marked : .none
    
  }  // end updateOffsetsToReference
  
  
  /// ========== Read Data From Mount ==========
  // This runs (via Notify Handler) every time EqMount sends a new GuideDataBlock (~10Hz)
  func processDataFromMount(_ guideData: GuideDataBlock) {
    
    // Store the new GuideDataBlock
    guideDataBlock = guideData
    readCount += 1
    updateMountAngles()
    
    // Telescope Reference Frame is +Z down, +X forward (north), +Y right (east)
    // Mount Accel is mounted with +Z up, +X forward and +Y to Right
    // Map Left Handed accelerometer to Right Handed Telescope Frame by:
    // Flipping +Z to down
    let rhsMountXl = simd_float3(guideDataBlock.accel_x,
                                 guideDataBlock.accel_y,
                                 -guideDataBlock.accel_z)
    
    let rhsNormMountXl = simd_normalize(rhsMountXl)
    
    // align accelerometer so y component is zero
    let offset = rhsNormMountXl.y
    let xCorrection = rhsNormMountXl.y  // rotate theta to zero psi
    let xRotation = xRot3x3(thetaRad: xCorrection)
    xlAligned = xRotation * rhsNormMountXl
    
    // This is the only angle of with any meaming on the mount.
    theta = atan2(xlAligned.x, xlAligned.z) - PI // *BB* WHY PI (180) here
    
    // Process specific GuideDataBlock commands
    if guideDataBlock.mountState == MountState.PowerUp.rawValue {
      pointingKnowledge = .none
    }
    
    // Mark Reference on markRefNow transition away from zero
    if guideDataBlock.markReferenceNow {
      // Mark Reference on first GDB with markRefNow
      if readyForRefMark {
        readyForRefMark = false
        updateOffsetsToReference()
        ackReference()
        print("Set readyForRefMark false")
      }
    } else {
      if (readyForRefMark == false) {
        // Reset on GDB w/o markReferenceNow
        readyForRefMark = true
        print("Set readyForRefMark true")
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
  
  //MARK: === Command Processing ===
  
  /// ========== Transmit Commands to Mount ==========
  /// Build and transmit GuideCommandBlocks
  /// Convert native iOS app types to Arduino types here - i.e. Doubles to Int32 Counts
  /// No angle conversions or hemisphere awareness at this level.
  
  func guideCommand(_ writeBlock:GuideCommandBlock) {
    rocketMount.bleWrite(GUIDE_COMMAND_UUID, writeData: writeBlock)
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
  // Inform Mount of offset between Reference to Target.
  // Does not actually move at this time.  Move can be initiated by hardware joystick.
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
  
  // Issue ios joystick commands
  func guideCommandMove(ra: Int32, dec: Int32) {
    let moveCommand = GuideCommandBlock(
      command: GuideCommand.Move.rawValue,
      armOffset: ra,
      dskOffset: dec)
    guideCommand(moveCommand)
  }
  
  // This removes iOS joystick input.  Motion will decel to a stop.
  func guideCommandMoveNull() {
    let nullCommand = GuideCommandBlock(
      command: GuideCommand.Move.rawValue,
      armOffset: 0,
      dskOffset: 0)
    guideCommand(nullCommand)
  }
  
  // This will stop a guide, hardware joystick, or ios joystick command.
  func guideCommandStop() {
    let stopCommand = GuideCommandBlock(command: GuideCommand.Stop.rawValue)
    guideCommand(stopCommand)
  }

  // handle iOS UI MarkRef control.
  func guideCommandMarkRefNow() {
    updateOffsetsToReference()  // update model angles
    // Advance mount arduino to next state
    let markRefCommand = GuideCommandBlock(command: GuideCommand.MarkRefNow.rawValue)
    guideCommand(markRefCommand)
  }
  
  // Initiate a move by Offset between Ref and Target.
  // Similar to SetOffset, except this iOS UI action initiates the move.
  func guideCommandGoToTarget() {
    var armDeg = 0.0
    var diskDeg = 0.0
    (armDeg, diskDeg) = mountAngleChange(fromCoord: refCoord, toCoord: targetCoord)
    
    let goToTargetCommand = GuideCommandBlock(
      command: GuideCommand.MoveToOffset.rawValue,
      armOffset: Int32( Float32(armDeg) / guideDataBlock.armDegPerStep),
      dskOffset: Int32( Float32(diskDeg) / guideDataBlock.dskDegPerStep)
    )

    guideCommand(goToTargetCommand)
  }
  
  // Acknolwledge Reference Mark - offset's not used
  // Marking the reference, deserved a handshake.
  // Mount holds GuideDataBlock.markRefNowInt != 0 until it receives this CommandBlock.
  func ackReference() {
    let ackCommand = GuideCommandBlock(
      command: GuideCommand.AckReference.rawValue
    )
    guideCommand(ackCommand)
    print("ackReference")
  }
    
  func onFound(){
    statusString = "RocketMount Found"
  }
  
  func onConnected(){
    statusString = "Connected"
  }
  
  func onDisconnected(){
    statusString = "Disconnected"
    readCount = 0;
    
    // attmempt to restart the connection
    rocketMount.startBleConnection()  // restart after connection lost
  }
  
  func onReady(){
    rocketMount.setNotify(GUIDE_DATA_BLOCK_UUID) { [weak self] (buffer:Data)->Void in
      
      // Copy the Data to a local GuideDataBlock structure
      let numBytes = min(buffer.count,
                         MemoryLayout.size(ofValue: self!.guideDataBlock))
      withUnsafeMutableBytes(of: &self!.guideDataBlock) { pointer in
        _ = buffer.copyBytes(to:pointer, from:0..<numBytes)
      }
      
      // Process the received GuideDataBlock
      self?.processDataFromMount(self!.guideDataBlock)
    }
    
  }
  
}
