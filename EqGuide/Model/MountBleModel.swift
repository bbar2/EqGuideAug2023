//
//  MountBleModel.swift - manage astro angles.  RocketMount only knows about stepper
//    motor counts.  This model maps stepper motor counts from known reference
//    positions to RA/DEC angles.
//
//  Created by Barry Bryant on 1/7/22.
//
// See CoordinateSystems.md for reference frame definitions
// See AstroTermsDefined.md for definitions of common terms (Pier Mode, Hour Angle, ..)

import SwiftUI
import CoreBluetooth
import Combine
import CoreLocation
import simd

enum PierMode {
  case unknown  // arbitrarily use .east calulations when unknown
  case east     // target on west, calculations normal
  case west     // target on east, calculations flipped
}

enum PointingKnowledge {
  case none
  case estimated  // estimated by accelerometers only
  case marked     // determined by visually Marking a reference star
}

enum ManualControlSpeeed {
  case fast
  case slow
}

class MountBleModel : MyPeripheralDelegate, ObservableObject {
  
  @Published var statusString = "Not Started"
  @Published var readCount = Int32(0)
  @Published var mountDataBlock = MountDataBlock()
  @Published var refCoord = RaDec(ra: 0, dec: 0)
  @Published var targetCoord = RaDec(ra: 0, dec: 0)
  @Published var locationData = LocationData() // Should I @Published since elements are @Published elements?
  @Published var refName = ""
  @Published var targName = ""
  
  let catalog: [Target] = loadJson("TargetData.json")
  
  var pierModelLink: PierBleModel?
  var focusModelLink: FocusBleModel?
  
  // These offsets, with current counts (in MountDataBlock), determine angles.
  // xxAngleDeg = (xxOffsetCount * xxDegPerStep) + xxOffsetDeg
  // Offsets are established when Marking a known object, in updateOffsetsToReference()
  private var pierOffsetDeg = 0.0
  private var diskOffsetDeg = 0.0
  
  private var lookForRateChange = false
  private var targetRateDps = Float32(0.0)
  
  // Mount Angles
  var lstDeg = 0.0
  var pierCurrentDeg = 0.0
  var diskCurrentDeg = 0.0
  @Published var pierMode = PierMode.unknown
  
  // FIXME: this is not quite right.  look into diskCurrentDeg, vs Current....
  func setPierMode() {
//    print("diskCurrentDeg = \(diskCurrentDeg)")
    if fabs(diskCurrentDeg) > 90 {
      pierMode = .west
    } else {
      pierMode = .east
    }
  }
  
  var currentPosition = RaDec()
  @Published var pointingKnowledge = PointingKnowledge.none
  @Published var lstValid = false
  
  @Published var xlAligned = simd_float3(x: 0, y: 0, z: 0)
  @Published var theta = Float(0.0)  // Mount pitch toward Polaris, or rotation around Mount_Y
  
  @Published var raIsTracking = true
  
  // Manual Control stuff
  @Published var arrowPadSpeed = ManualControlSpeeed.fast
  
  func bleConnected() -> Bool {
    return statusString == "Connected"
  }
  
  // All UUID strings must match the Arduino C++ RocketMount UUID strings
  private let GUIDE_DEVICE_NAME = "EqMountGuideService"
  private let GUIDE_SERVICE_UUID = CBUUID(
    string: "828b0010-046a-42c7-9c16-00ca297e95eb")
  private let MOUNT_DATA_UUID = CBUUID(
    string: "828b0011-046a-42c7-9c16-00ca297e95eb")
  private let GUIDE_COMMAND_UUID = CBUUID(
    string: "828b0012-046a-42c7-9c16-00ca297e95eb")
  
  private let rocketMount: MyPeripheral
  private var initialized = false
  
  private var lstOffset = 0.0  // must be 0.0 for normal operation.
                  //lstOffset = 282.0 - lstDeg // Staunton River, Sep 14, 8:30PM
                  //lstOffset = 90.0 - lstDeg // match figure

  private var xlControlTimer = Timer()
  @Published var xlControlActive = false
  private var raOnXlTarget = false
  
  init() {
    
    self.rocketMount = MyPeripheral(
      deviceName: GUIDE_DEVICE_NAME,
      serviceUUID: GUIDE_SERVICE_UUID,
      dataUUIDs: [MOUNT_DATA_UUID, GUIDE_COMMAND_UUID])
    
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
    let refIndex = 5 // mizar
    refCoord = RaDec(ra: catalog[refIndex].ra, dec: catalog[refIndex].dec)
    refName = catalog[refIndex].name
    let targIndex = 13 // m101 Pinwheel Galaxy
    targetCoord = RaDec(ra: catalog[targIndex].ra, dec: catalog[targIndex].dec)
    targName = catalog[targIndex].name
  }

  // ContentView.onAppear calls these to tie models together.
  func linkPierModel(_ pierModel: PierBleModel) {
    pierModelLink = pierModel
  }
  
  func linkFocusModel(_ focusModel: FocusBleModel){
    focusModelLink = focusModel
  }
  
  // Called by focusMotorInit & BleDelegate overrides on BLE Connect or Disconnect
  func initLocalMembers() {
    // Init local variables
  }
  
  //MARK: === UI Control Actions ===
  
  func swapRefAndTarg() {
    let temp = refCoord
    refCoord = targetCoord
    targetCoord = temp
    let tempName = targName
    targName = refName
    refName = tempName
  }
  
  func pauseTracking() {
    guideCommandPauseTracking()
  }
  
  func resumeTracking() {
    guideCommandResumeTracking()
  }
  
  func goHome() -> Bool {
    raOnXlTarget = false
    return beginXlControl(controlAction: goHomeTimerHandler)
  }
  
  // Simulate Arrow presses, until Pier Y acceleration = 0.0.
  // if Ay is possitive, go West; else go East
  func goHomeTimerHandler() {

    if raOnXlTarget || goHomeRa()
    {
      if focusModelLink?.bleConnected() ?? false {
        if goHomeDec()
        {
          endXlControl()
          updateLstDeg()
          let homeCoord = RaDec(ra: lstDeg - 90.0, dec: 0.0)
          updateOffsetsTo(reference: homeCoord)
          pointingKnowledge = lstValid ? .estimated : .none
          setPierMode()
          
          if let focusModel = focusModelLink {
            focusModel.enableBleTimeout()  // let focus disconnect after timeout
          }
        }
      } // focusModelLink?.bleConnected()
    }
  }
  
  func goHomeRa() -> Bool {
    let ay = pierModelLink?.xlAligned.y ?? 0.0

    // Use this offset until Pier accelAlign rotation transform is improved.
    // This is adequate for HOME/EAST finding.  Not for general reverse solution.
    let yOffset = Float(0.035)
    let ayCal = ay - yOffset

    let slowThreshold = Float(0.1)
    let stopThreshold = Float(0.005)
    let west_fast = Int32(-2)
    let west_slow = Int32(-1)
    let east_fast = Int32(2)
    let east_slow = Int32(1)

    if (ayCal > slowThreshold) {
      guideCommandMove(ra: west_fast, dec: 0)
      return false;
    } else if (ayCal < -slowThreshold) {
      guideCommandMove(ra: east_fast, dec: 0)
      return false;
    }
    else if (ayCal > stopThreshold) {
      guideCommandMove(ra: west_slow, dec: 0)
      return false;
    } else if (ayCal < -stopThreshold) {
      guideCommandMove(ra: east_slow, dec: 0)
      return false;
    }
    else {
      guideCommandMoveNull();
      raOnXlTarget = true;
      return true;
    }

  }
  
  func goHomeDec() -> Bool {
    let ax = focusModelLink?.xlAligned.x ?? 0.0

    let slowThreshold = Float(0.3)
    let stopThreshold = Float(0.005)
    let north_fast = Int32(2)
    let north_slow = Int32(1)
    let south_fast = Int32(-2)
    let south_slow = Int32(-1)

    if (ax > slowThreshold) {
      guideCommandMove(ra: 0, dec: north_fast)
      return false;
    } else if (ax < -slowThreshold) {
      guideCommandMove(ra: 0, dec: south_fast)
      return false;
    }
    else if (ax > stopThreshold) {
      guideCommandMove(ra: 0, dec: north_slow)
      return false;
    } else if (ax < -stopThreshold) {
      guideCommandMove(ra: 0, dec: south_slow)
      return false;
    }
    else {
      guideCommandMoveNull();
      return true;
    }
  }
  
  func goEastPier() -> Bool {
    raOnXlTarget = false
    return beginXlControl(controlAction: goEastPierTimerHandler)
  }
  
  func goEastPierTimerHandler() ->Void {
    if raOnXlTarget || goEastPierRa()
    {
      if focusModelLink?.bleConnected() ?? false {
        if goEastPierDec()
        {
          endXlControl()
          updateLstDeg()
          let eastPierCoord = RaDec(ra: lstDeg, dec: 0.0)
          updateOffsetsTo(reference: eastPierCoord)
          pointingKnowledge = lstValid ? .estimated : .none
          setPierMode()
          
          if let focusModel = focusModelLink {
            focusModel.enableBleTimeout()  // can let focus timeout now
          }
          
        }
      } // focusModelLink?.bleConnected()
    }
  }
  
  // Simulate Arrow presses, until Pier Z acceleration = 0.0.
  // if Az is possitive, go east; else go west
  // Use Ay to detect arm beyond 90
  func goEastPierRa() -> Bool {
    let az = pierModelLink?.xlAligned.z ?? 0.0
    let ay = pierModelLink?.xlAligned.y ?? 0.0

    // Use this offset until Pier accelAlign rotation transform is improved.
    // This is adequate for HOME/EAST finding.  Not for general reverse solution.
    let zOffset = Float(-0.005)
    let azCal = az - zOffset

    let slowThreshold = Float(0.1)
    let stopThreshold = Float(0.005)
    let west_fast = Int32(-2)
    let west_slow = Int32(-1)
    let east_fast = Int32(2)
    let east_slow = Int32(1)
    if (ay < Float(0.0) || azCal >= slowThreshold) {
      guideCommandMove(ra: east_fast, dec: 0)
      return false
    } else if (azCal < -slowThreshold) {
      guideCommandMove(ra: west_fast, dec: 0)
      return false
    }
    else if (azCal > stopThreshold) {
      guideCommandMove(ra: east_slow, dec: 0)
      return false
    } else if (azCal < -stopThreshold) {
      guideCommandMove(ra: west_slow, dec: 0)
      return false
    } else {
      guideCommandMoveNull()
      raOnXlTarget = true
      return true
    }
  }
  
  // Align by matching -FocusY with PierX
  func goEastPierDec() -> Bool {
    let focusY = focusModelLink?.xlAligned.y ?? 0.0
    let targetY = (pierModelLink?.xlAligned.x ?? 0.0) * -1.0

    let slowThreshold = Float(0.3)
    let stopThreshold = Float(0.005)
    let north_fast = Int32(2)
    let north_slow = Int32(1)
    let south_fast = Int32(-2)
    let south_slow = Int32(-1)

    if ((focusY-targetY) > slowThreshold) {
      guideCommandMove(ra: 0, dec: north_fast)
      return false;
    } else if ((focusY-targetY) < -slowThreshold) {
      guideCommandMove(ra: 0, dec: south_fast)
      return false;
    }
    else if ((focusY-targetY) > stopThreshold) {
      guideCommandMove(ra: 0, dec: north_slow)
      return false;
    } else if ((focusY-targetY) < -stopThreshold) {
      guideCommandMove(ra: 0, dec: south_slow)
      return false;
    }
    else {
      guideCommandMoveNull();
      return true;
    }
  }

  //MARK: === XL Control ===

  // Auto control uses XL in PierModel to position RA
  // Auto control uses XL in FocusModel to position DEC
  func beginXlControl(controlAction: @escaping ()->Void) -> Bool
  {
    if xlControlActive {
      endXlControl()
    }
    
    // Something very wrong if pier not connected
    if let pierModel = pierModelLink {
      if !pierModel.bleConnected() {
        print("Pier BLE Not Connected")
        return false
      }
    } else {
      print("PierModel nil")
      return false
    }
 
    // It's normal for FocusBle to timeout.  Start reconnection.
    // Test for focusModel.bleConnected() before trying to control DEC.
    if let focusModel = focusModelLink {
      focusModel.disableBleTimeout()
      if !focusModel.bleConnected() {
        focusModel.connectBle() // initiate connection.
      }
    } else {
      print("FocusModel nil")
      return false
    }
    
    pauseTracking() // no need to track while under XlControl
    
    xlControlActive = true
    xlControlTimer = Timer.scheduledTimer(withTimeInterval: 0.4, // 2.5 Hz
                                            repeats: true) { _ in
      controlAction()
    }
    
    return true // XL Control Stated
  }
  
  func endXlControl() {
    guideCommandMoveNull()
    xlControlTimer.invalidate()
    xlControlActive = false
    //resumeTracking() // TODO: definitely overwrites MoveNull command - sometimes.
    // TODO: Requires buffering, or handshake acknowledment of commands or use of .withResponse.
  }
  

  //MARK: === Angle Processing ===
  
  func updateLstDeg() {
    if let longitudeDeg = locationData.longitudeDeg {
      lstValid = true
      lstDeg = lstDegFrom(utDate: Date.now, localLongitudeDeg: longitudeDeg)
      
      lstDeg += lstOffset // used for testing offsets from current LST
            
    } else {
      lstValid = false
      lstDeg = 0.0
    }
  }
  
  // Update all time dependent model calcs at once
  // Update mount angles, and Current RA/DEC from new Counts.
  // Don't do in calculated vars, because there is too much repetition building
  // terms, and updating Views.
  // Call this everytime a new MountDataBlock arrives from Mount
  func updateMountAngles() {
    
    updateLstDeg() // LST is function of time and longitude
    
    // TODO: Confirm this description with CoordinateSystems.md
    // Positive Count's advance axes CCW, looking to Polaris or top of scope
    pierCurrentDeg = (mountDataBlock.pierCountDeg + pierOffsetDeg).mapAnglePm180()
    diskCurrentDeg = (mountDataBlock.diskCountDeg + diskOffsetDeg).mapAnglePm180()

    // TODO: use HA and/or PierMode for this mountAnglesToRaDec mapping
    // Looking to which side of pier |disk|<=90 no flip; |disk|>90 DEC Flip
    if lstValid && (pointingKnowledge != PointingKnowledge.none) {
      if (fabs(diskCurrentDeg) <= 90.0) { // lens is looking to west side of pier
        currentPosition.ra = lstDeg - 90.0 - pierCurrentDeg
        currentPosition.dec = diskCurrentDeg
      } else { // looking to east side of pier
        currentPosition.ra = lstDeg + 90.0 - pierCurrentDeg
        currentPosition.dec = 180.0 - diskCurrentDeg
      }
    } else {
      currentPosition.ra = pierCurrentDeg  // RA unknown without pointing knowledge
      currentPosition.dec = diskCurrentDeg // DEC unknown without pointing knowledge
    }
    
    currentPosition.ra = currentPosition.ra.mapAngle0To360()
    currentPosition.dec = currentPosition.dec.mapAnglePm180()
  } // end updateMountAngles

  // Raw Mount Angles from coord of observed target and LST
  // All angles in degrees
  func raDecToMountAngles(_ coord: RaDec, lst: Double) ->
  (pierDeg: Double, diskDeg:Double, decModeUsed:PierMode) {
    var pierDeg = 0.0
    var diskDeg = 0.0
    var decModeUsed = PierMode.unknown
    
    // Find Hour Angle (ha) of coordinate
    // ha = angle from RA to LST = (end - start) = (LST - RA)
    let ha = (lst - coord.ra).mapAnglePm180()
    
    // Select pier and disk angles based on coordinate side of lst
    // looking east:  ha < 0
    // Looking west: ha >= 0 (defines ha = 0 as looking west)
    if ha < 0  { // looking east
      decModeUsed = PierMode.west
      pierDeg = 90.0 + ha     // pierDeg = +90 is horizontal west
      diskDeg = 180.0 - coord.dec
    } else {                             // looking west
      decModeUsed = PierMode.east
      pierDeg = -90.0 + ha    // pierDeg = -90 is horizontal east
      diskDeg = coord.dec
    }

    pierDeg = pierDeg.mapAnglePm180()
    diskDeg = diskDeg.mapAnglePm180()
    
    return (pierDeg, diskDeg, decModeUsed)
  }
  
  // TODO: lstToRa approach worked.  Refactored to use HA.  Keep until tested.
  // // Raw Mount Angles from coord of observed target and LST
  //    func raDecToMountAngles(_ coord: RaDec) ->
  //    (pierDeg: Double, diskDeg:Double, decModeUsed:PierMode) {
  //      var pierDeg = 0.0
  //      var diskDeg = 0.0
  //      var decModeUsed = PierMode.unknown
  //
  //      // Find angle from LST to RA = (end - start) = (RA-LST)
  //      var lstToRa = coord.ra - lstDeg;
  //
  //      // Map to 0.0 <= lstToRa < 360.0
  //      lstToRa = lstToRa.mapAngle0To360()
  //
  //      // Select pier and disk angles based on target side of lst (lstToRa = RA-LST)
  //      // For 0 <= raLst < 360:  (360.0 maps to 0.0)
  //      // looking east:  0 < raLst < 180.0
  //      // Looking west: 180.0 <= raLst <= 360.0 (define 360=0 and 180 as looking west)
  //      if lstToRa > 0 && lstToRa < 180.0  { // looking east
  //        decModeUsed = PierMode.west
  //        pierDeg = 90.0 - lstToRa
  //        diskDeg = 180.0 - coord.dec
  //      } else {                             // looking west
  //        decModeUsed = PierMode.east
  //        pierDeg = -90.0 - lstToRa
  //        diskDeg = coord.dec
  //      }
  //
  //      pierDeg = pierDeg.mapAnglePm180()
  //      diskDeg = diskDeg.mapAnglePm180()
  //
  //      return (pierDeg, diskDeg, decModeUsed)
  //    }
  
  // Uses LST, to build mount angle changes required to move fromCoord toCoord
  // TODO: what do I do if LST or REF knowledge == .none
  func mountAngleChange(fromCoord: RaDec, toCoord: RaDec) ->
  (pierAngle: Double, diskAngle: Double) {
    let (fromPierDeg, fromDiskDeg, _) = raDecToMountAngles(fromCoord, lst: lstDeg)
    let (toPierDeg, toDiskDeg, _) = raDecToMountAngles(toCoord, lst: lstDeg)
    
    let deltaPierDeg = toPierDeg - fromPierDeg
    var deltaDiskDeg = toDiskDeg - fromDiskDeg
    
    // Take shorter route if |deltaDiskDeg| > 180.0
    deltaDiskDeg = deltaDiskDeg.mapAnglePm180()
    
    return (deltaPierDeg, deltaDiskDeg)
  }
  
  func anglesReferenceToTarget() -> RaDec {
    let (pierDeg, diskDeg) = mountAngleChange(fromCoord: refCoord,
                                              toCoord: targetCoord)
    return RaDec(ra:pierDeg, dec: diskDeg)
  }
  
  func anglesCurrentToTarget() -> RaDec {
    let (pierDeg, diskDeg) = mountAngleChange(fromCoord: currentPosition,
                                              toCoord: targetCoord)
    return RaDec(ra:pierDeg, dec: diskDeg)
  }
  
  /// ========== RA/Dec from References star and Current Date/Time ==========
  
  // Given knowledge of current RA/DEC, and the current pier and disk counts,
  // calculate the offsets.  Do this when looking at a reference coordinate.
  func updateOffsetsTo(reference: RaDec) {
    
    updateLstDeg()
    
    let (refPierAngle, refDiskAngle, _) = raDecToMountAngles(reference, lst: lstDeg)
    
    // given:
    //  pierAngle = guideDataBlock.pierCountDeg + pierOffsetDeg
    //  diskAngle = guideDataBlock.diskCountDeg + diskOffsetDeg
    pierOffsetDeg = refPierAngle - mountDataBlock.pierCountDeg
    diskOffsetDeg = refDiskAngle - mountDataBlock.diskCountDeg
    
    // not sure these need to be mapped, but it shouldn't hurt.
    pierOffsetDeg = pierOffsetDeg.mapAnglePm180()
    diskOffsetDeg = diskOffsetDeg.mapAnglePm180()
    
//    print("refPierAngle = \(refPierAngle)  pierOffsetDeg = \(pierOffsetDeg)  pierAngle = \(mountDataBlock.pierCountDeg + pierOffsetDeg)")
//    print("refDiskAngle = \(refDiskAngle)  diskOffsetDeg = \(diskOffsetDeg)  diskAngle = \(mountDataBlock.diskCountDeg + diskOffsetDeg)")
    
    // Used for color coding values that depend on references
//    pointingKnowledge = lstValid ? .marked : .none
    
  }  // end updateOffsetsTo
  
  //MARK: === Read Data From Mount ==========
  
  // This runs (via Notify Handler) every time EqMount sends a new MountDataBlock (~10Hz)
  func processDataFromMount(_ guideData: MountDataBlock) {
    
    // Store the new MountDataBlock
    mountDataBlock = guideData
    readCount += 1
    updateMountAngles()
    
    // trackingPaused is non zero when tracking.
    raIsTracking = mountDataBlock.trackingPaused == 0 ? true : false;
    
    // Mount Reference Frame: +X forward/polaris, +Y left/west, +Z up/equatorial
    // Mount Accel is mounted +X forward,         +Y Right,     +Z up
    // Map Left Handed accelerometer to Right Handed Telescope
    let rhsMountXl = simd_float3(mountDataBlock.accel_x,
                                 -mountDataBlock.accel_y,
                                 mountDataBlock.accel_z)
    
    let rhsNormMountXl = simd_normalize(rhsMountXl)
    
    // align accelerometer so y component is zero
    //let offset = rhsNormMountXl.y
    let xCorrection = rhsNormMountXl.y  // rotate theta to zero psi
    let xRotation = xRot3x3(phiRad: xCorrection)
    xlAligned = xRotation * rhsNormMountXl
    
    // This is the only angle with any meaming on the mount.
    theta = -atan2(xlAligned.x, xlAligned.z)
    
    // Process specific MountDataBlock commands
    if mountDataBlock.mountState == MountState.PowerUp.rawValue {
      pointingKnowledge = .none
    }
        
    // Add code here for next specific GDB command
    if lookForRateChange {
      let oneArcSecPerMin = Float32(1.0 / (3600.0 * 60.0))
      if abs(mountDataBlock.raRateOffsetDegPerSec - targetRateDps) < oneArcSecPerMin {
        heavyBump()
        lookForRateChange = false
      }
    }
  }
  
  //MARK: === Issue Commands to Mount ===
  
  /// ========== Transmit Commands to Mount ==========
  /// Build and transmit GuideCommandBlocks
  /// Convert native iOS app types to Arduino types here - i.e. Doubles to Int32 Counts
  /// No angle conversions or SideOfPier awareness at this level.

  private var cmdId = Int32(0)
  func guideCommand(_ writeBlock:GuideCommandBlock) {
    var cmdBlock = writeBlock
    cmdId += 1
    cmdBlock.id = cmdId
    rocketMount.bleWrite(GUIDE_COMMAND_UUID, writeData: cmdBlock, withResponse: true)
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
      pierOffset: ra,
      diskOffset: dec)
    guideCommand(moveCommand)
  }
  
  // This removes iOS joystick input.  Motion will decel to a stop.
  func guideCommandMoveNull() {
    let nullCommand = GuideCommandBlock(
      command: GuideCommand.Move.rawValue,
      pierOffset: 0,
      diskOffset: 0)
    guideCommand(nullCommand)
  }
  
  // This will stop a guide, hardware joystick, or ios joystick command.
  // Motion decels to a stop, then Mount goes thru PowerUp states.
  func guideCommandReset() {
    // stop any local timer driven movements
    xlControlTimer.invalidate()
    
    // Tell the mount to Reset
    let resetCommand = GuideCommandBlock(command: GuideCommand.Reset.rawValue)
    guideCommand(resetCommand)
  }

  // Update model angle offsets after manually fine aligning telescope view to target
  func guideCommandMarkTarget() {
    updateOffsetsTo(reference: targetCoord)  // update model angles
    pointingKnowledge = lstValid ? .marked : .none

    setPierMode()
  }
  
  // Initiate a move by Offset between Current and Target.
  func guideCommandGoToTarget() {
    let (pierDeg, diskDeg) = mountAngleChange(fromCoord: currentPosition,
                                              toCoord: targetCoord)
    
    let goToTargetCommand = GuideCommandBlock(
      command: GuideCommand.GuideToOffset.rawValue,
      pierOffset: Int32( Float32(pierDeg) / mountDataBlock.pierDegPerStep),
      diskOffset: Int32( Float32(diskDeg) / mountDataBlock.diskDegPerStep)
    )
    guideCommand(goToTargetCommand)

    setPierMode()
  }
  
  //MARK: === MyPeripheral Delegate Methods ===

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
    rocketMount.setNotify(MOUNT_DATA_UUID) { [weak self] (buffer:Data)->Void in
      
      // Copy the Data to a local MountDataBlock structure
      let numBytes = min(buffer.count,
                         MemoryLayout.size(ofValue: self!.mountDataBlock))
      withUnsafeMutableBytes(of: &self!.mountDataBlock) { pointer in
        _ = buffer.copyBytes(to:pointer, from:0..<numBytes)
      }
      
      // Process the received MountDataBlock
      self?.processDataFromMount(self!.mountDataBlock)
    }
  }
  
}
