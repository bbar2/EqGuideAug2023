//
//  GuideModel.swift - manage astro angles.  RocketMount only knows about stepper
//    motor counts.  This model maps stepper motor counts from known reference
//    positions to RA/DEC angles.
//
//  Created by Barry Bryant on 1/7/22.

// Local Reference Frame - Right Handed Coordinate System
//   Local_X Level North
//   Local_Y Level West
//   Local_Z Up Opposite Gravity

// Mount Reference Frame - Local Reference Frame rotated around Local_Y to point
// to north celestial pole, near Polaris
//   Mount_X rotated around Local_Y to north celestial pole.  theta = -(local latitude)
//   Mount_Y level out left toward west, remains aligned with Local_Y
//   Mount_Z rotated around Local_Y southward to equitorial

// Pier Reference Frame - Mount reference frame rotated by phi around Mount_X
//   Pier_X remains aligned with Mount_X
//   Pier_Y and Pier_Z rotate around Mount_X,
//   X rotation (phi) aligns target RA, and is function of target RA and LST

// Telescope Reference Frame - Pier Reference frame rotated by psi around Pier_Z axis.
//   Tele_X forward out optical axis of telescope
//   Tele_Y out left side of telescope (left defined when aligned with Local frame)
//   Tele_Z remains aligned with Pier_Z. Out top of telescope
//   Z rotation (psi) aligns target DEC, and is function of RA, LST and DEC.

// Mount hardware order of rotations, defined by cascaded hardware design:
//   theta: +CW pitch around Local_Y/Mount_Y to point to Polaris (theta = -Latitude)
//   phi: +CW roll around Mount_X/Pier_X to align RA (phi = -pierDeg)
//   psi: +CW yaw around Pier_Z/Tele_Z to align DEC (psi = 90 - diskDeg)

//  Mount pier angle (pierDeg) rotates in Right Ascension, around Mount_X/Pier_X
//  Increases CCW looking out Mount_X, away from mount, toward polaris.
//  I suspect the origin of this CCW is the westward tracking advance.
//  pierDeg is:
//   +90º when pier is horizontal on west side
//   -90º when pier is horizontal on east side
//     0 when pier is vertical
//  -180 <= pierDeg < +180.  Add or subtract 360 to keep in this range.
//  Pier angle range of motion mechanically limited to +- ~95º
//  phi = -pierDeg; // due to CCW direction of pierDeg.

//  Mount Disk angle (diskDeg) rotates in Declination, around Pier_Z/Tele_Z
// FIXME: seems backwards.  Look at hardware view and counts.
//  + is CCW looking up from bottom of disk.
//  diskDeg is:
//   +90 pointing at north end of pier
//   -90 pointing at south end of pier
//     0 pointing to west side of pier
// -180 <= diskDeg < 180. Add or subtract 360 to keep in this range.
// Disk angle is not mechanically limited.  Can do 360's all day.
// psi = (90 - diskDeg); // Due to 90 degree offset and CCW direction of diskDeg.

// LST runs North to South and is always straight up f(time, longitude)
//   0 <= LST < 360º (0 <= LST < 24 hr)
// RA is fixed to celstial sphere
//   0 <= RA < 360º (0 <= RA < 24 hr)
//   increases CW looking at Polaris
// (RA-LST) is always = 0 up.  = 90º East.  = 270º West. = 180º down into ground.
//    0 <= (RA-LST) < 360
//    increases CW looking at Polaris

// DEC is fixed to celestial sphere
//   +90 at north pole
//     0 at equator
//   -90 at south pole
//   -90 <= DEC <= +90
//    if |DEC| == 90, RA rotates FOV but does not change where telescope is pointing

//  RA/DEC to pierDeg/diskDeg mapping depends on target's side of pier
//  determined by (RA-LST)
//    // If target is west use normal declination (NW or SW Quadrants)
//    If (RA-LST) >= 180   // Define as DEC Normal
//      (RA-LST) = -90 - pierDeg
//      pierDeg = -90 - (RA-LST) = LST - 90 - RA
//      RA = LST - 90 - pierDeg
//      Note that pierDeg decreases as RA increases.
//      This fits since pierDeg increases CCW and RA increases CW.
//      diskDeg = DEC   //-90 <= diskDeg <= +90
//      DEC = diskDeg
//      |diskDeg| <= 90
//    Else If (RA-LST) < 180 // target is east, declination flip (NE or SE Quadrant)
//      (RA-LST) = 90 - pierDeg
//      pierDeg = 90 - (RA-LST) = LST + 90 - RA
//      RA = LST + 90 - pierDeg
//      diskDeg = 180 - DEC // |Dec| == 90 is forced to normal decliation.
//      DEC = 180 - diskDeg
//      // Although diskDeg = |90| is valid for normal or flipped declination,
//      // I elect to interpret that situation as normal declination.
//      |diskDeg| > 90
//   After these calcs, always map:
//     -180 <= pierDeg < 180
//     -180 <= diskDeg < 180
//     0 <= (RA-LST) < 360
//     -90 <= DEC <= +90

//  TODO: consider adding ~2 degree padding on pier declination flip.
//  Upgrade: For eastern targets near LST, use normal declination to prevent
//    westward tracking from quickly running into 95º hardware limit
//    - If eastern target is within padº of vertical, start with pier on east.
//    - Detect with (RA-LST) < padº, or (RA-LST) < (180º+pad)
//    - Do I need pierDeg/diskDeg to RA/DEC calcs to have opposite logic?

// HOME Position:
//   - pier Vertical: pierDeg = 0
//   - disk points West: diskDeg = 0.  Supports focus motor setup.
//   - x axis now points west.  y axis now points south.
//   - Since dskDeg < 90, use normal declination mapping
//     (RA-LST) = -90º - pierDeg = -90º;  RA = LST - 90º
//     DEC = dskDeg = 0º

// EAST PIER Position:
//   - pier Horizontal with mount on east side of pier:  pierDeg = -90º
//   - disk points up at LST. diskDeg = 0.
//   - x axis points up at equitorial plane
//   - y axis points at north pole
//   - z axis is horizontal
//   - since dskDeg < 90, use normal declination mapping
//     (RA-LST) = -90º - pierDeg = -90º - (-90º) = 0;  RA = LST
//     DEC = dskDeg = 0º

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
  
  let catalog: [Target] = loadJson("TargetData.json")
  
  var pierModelLink: PierBleModel?
  var focusModelLink: FocusBleModel?
  
  // These offsets, with current counts (in GuideDataBlock), determine angles.
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
  
  var currentPosition = RaDec()
  @Published var pointingKnowledge = Knowledge.none
  @Published var lstValid = false
  
  var xlAligned = simd_float3(x: 0, y: 0, z: 0)
  var theta = Float(0.0)  // Mount pitch toward Polaris, or rotation around Mount_Y
  
  @Published var raIsTracking = true
  
  // Manual Control stuff
  @Published var arrowPadSpeed = ArrowMode.fast
  
  func bleConnected() -> Bool {
    return statusString == "Connected"
  }
  
  // All UUID strings must match the Arduino C++ RocketMount UUID strings
  private let GUIDE_DEVICE_NAME = "EqMountGuideService"
  private let GUIDE_SERVICE_UUID = CBUUID(
    string: "828b0010-046a-42c7-9c16-00ca297e95eb")
  private let GUIDE_DATA_BLOCK_UUID = CBUUID(
    string: "828b0011-046a-42c7-9c16-00ca297e95eb")
  private let GUIDE_COMMAND_UUID = CBUUID(
    string: "828b0012-046a-42c7-9c16-00ca297e95eb")
  
  private let rocketMount: MyPeripheral
  private var initialized = false
  
  private var lstOffset = 0.0  // leave this 0.0 for normal operation.
                  //lstOffset = 282.0 - lstDeg // Staunton River, Sep 14, 8:30PM
                  //lstOffset = 90.0 - lstDeg // match figure

  private var autoControlTimer = Timer()
  @Published var autoControlActive = false
  
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
  
  func beginAutoControl(controlAction: @escaping ()->Void)
  {
    if autoControlActive {
      endAutoControl()
    }
    
    autoControlActive = true
    autoControlTimer = Timer.scheduledTimer(withTimeInterval: 0.2, // 5 Hz
                                            repeats: true) { _ in
      controlAction()
    }
  }
  
  func endAutoControl() {
    guideCommandMoveNull()
    autoControlTimer.invalidate()
    autoControlActive = false
  }

  func goHome(){
    beginAutoControl(controlAction: goHomeTimerHandler)
  }

  // Simulate Arrow presses, until Pier Y acceleration = 0.0.
  // if Ay is possitive, go West; else go East
  func goHomeTimerHandler() {

    if goHomeRa()
    {
      if goHomeDec()
      {
        endAutoControl()
        updateLstDeg()
        let homeCoord = RaDec(ra: lstDeg - 90.0, dec: 0.0)
        updateOffsetsTo(reference: homeCoord)
        pointingKnowledge = lstValid ? .estimated : .none
      }
    }
  }
  
  func goHomeRa() -> Bool {
    let ay = pierModelLink?.xlAligned.y ?? 0.0

    let slowThreshold = Float(0.1)
    let stopThreshold = Float(0.005)
    let west_fast = Int32(-2)
    let west_slow = Int32(-1)
    let east_fast = Int32(2)
    let east_slow = Int32(1)

    if (ay > slowThreshold) {
      guideCommandMove(ra: west_fast, dec: 0)
      return false;
    } else if (ay < -slowThreshold) {
      guideCommandMove(ra: east_fast, dec: 0)
      return false;
    }
    else if (ay > stopThreshold) {
      guideCommandMove(ra: west_slow, dec: 0)
      return false;
    } else if (ay < -stopThreshold) {
      guideCommandMove(ra: east_slow, dec: 0)
      return false;
    }
    else {
      guideCommandMoveNull();
      return true;
    }

  }
  
  func goHomeDec() -> Bool {
    let ax = focusModelLink?.xlAligned.x ?? 0.0

    let slowThreshold = Float(0.1)
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
  
  func goEastPier() {
    beginAutoControl(controlAction: goEastPierTimerHandler )
  }
  
  func goEastPierTimerHandler() ->Void {
    if goEastPierRa()
    {
      if goEastPierDec()
      {
        endAutoControl()
        updateLstDeg()
        let eastPierCoord = RaDec(ra: lstDeg, dec: 0.0)
        print("eastPierCoord.ra = \(eastPierCoord.ra)  dec = \(eastPierCoord.dec)")
        updateOffsetsTo(reference: eastPierCoord)
        pointingKnowledge = lstValid ? .estimated : .none
      }
    }
  }
  
  // Simulate Arrow presses, until Pier Z acceleration = 0.0.
  // if Az is possitive, go east; else go west
  // Use Ay to detect arm beyond 90
  func goEastPierRa() -> Bool {
    let az = pierModelLink?.xlAligned.z ?? 0.0
    let ay = pierModelLink?.xlAligned.y ?? 0.0

    let slowThreshold = Float(0.1)
    let stopThreshold = Float(0.005)
    let west_fast = Int32(-2)
    let west_slow = Int32(-1)
    let east_fast = Int32(2)
    let east_slow = Int32(1)
    if (ay < Float(0.0) || az > slowThreshold) {
      guideCommandMove(ra: east_fast, dec: 0)
      return false
    } else if (az < -slowThreshold) {
      guideCommandMove(ra: west_fast, dec: 0)
      return false
    }
    else if (az > stopThreshold) {
      guideCommandMove(ra: east_slow, dec: 0)
      return false
    } else if (az < -stopThreshold) {
      guideCommandMove(ra: west_slow, dec: 0)
      return false
    } else {
      guideCommandMoveNull()
      return true
    }
  }
  
  // Align by matching -FocusY with PierX
  func goEastPierDec() -> Bool {
    let focusY = focusModelLink?.xlAligned.y ?? 0.0
    let targetY = (pierModelLink?.xlAligned.x ?? 0.0) * -1.0

    let slowThreshold = Float(0.1)
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
  // Call this everytime a new GuideDataBlock arrives from Mount
  func updateMountAngles() {
    
    updateLstDeg() // LST is function of time and longitude
    
    // Positive Count's advance axes CCW, looking to Polaris or top of scope
    pierCurrentDeg = guideDataBlock.pierCountDeg + pierOffsetDeg
    diskCurrentDeg = guideDataBlock.diskCountDeg + diskOffsetDeg
    
    pierCurrentDeg = pierCurrentDeg.mapAnglePm180()
    diskCurrentDeg = diskCurrentDeg.mapAnglePm180()
    
    // Looking to which side of pier |disk|<=90 no flip; |disk|>90 DEC Flip
    if lstValid && (pointingKnowledge != Knowledge.none) {
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

    //    // Looking to which side of pier (disk<=0 looks east; disk>0 looks west)
//    if lstValid && (pointingKnowledge != Knowledge.none) {
//      if (diskCurrentDeg <= 0) { // lens is looking to east side of pier
//        currentPosition.ra = lstDeg + 90.0 - pierCurrentDeg
//        currentPosition.dec = diskCurrentDeg + 90.0
//      } else { // looking to west side of pier
//        currentPosition.ra = lstDeg + 270.0 - pierCurrentDeg
//        currentPosition.dec = 90.0 - diskCurrentDeg
//      }
//    } else {
//      currentPosition.ra = pierCurrentDeg  // RA unknown without pointing knowledge
//      currentPosition.dec = diskCurrentDeg // DEC unknown without pointing knowledge
//    }
    
  } // end updateMountAngles
  
  // Raw Mount Angles from coord of observed target and LST
  func raDecToMountAngles(_ coord: RaDec) ->
  (pierDeg: Double, diskDeg:Double) {
    var pierDeg = 0.0
    var diskDeg = 0.0
    
    // Find angle from LST to RA = (end - start) = (RA-LST)
    var lstToRa = coord.ra - lstDeg;
    
    // Map to 0.0 <= raLst < 360.0
    lstToRa = lstToRa.mapAngle0To360()

    // Select pier and disk angles based on target side of lst (lstToRa = RA-LST)
    // For 0 <= raLst < 360:  (360.0 maps to 0.0)
    // looking east:  0 <= raLst < 180.0  (define 0 as looking east)
    // Looking west: 180.0 <= raLst < 360.0 (define 180 as looking west)
    // Note that lstToRa == 0 is straight up and could be looked at Dec Normnal or Flip
    //   Treat straight up like west target and star looking using Dec Normal
    if lstToRa >= 180.0 || lstToRa < 0.001 { // Normal Declination - looking west
      pierDeg = -90.0 - lstToRa                 //270.0 - lstToRa
      // FIXME: I think these are backwards.  It looks like disk actually increases CW.
      diskDeg = coord.dec                       //90.0 - coord.dec
    } else {  // Declination Flip - looking east
      pierDeg = 90.0 - lstToRa                  // 90.0 - lstToRa
      // FIXME: I think these are backwards.  It looks like disk actually increases CW.
      diskDeg = 180.0 - coord.dec               // coord.dec - 90.0
    }
    
    pierDeg = pierDeg.mapAnglePm180()
    diskDeg = diskDeg.mapAnglePm180()
    
    return (pierDeg, diskDeg)
  }
    
  // Uses LST, to build mount angle changes required to move fromCoord toCoord
  // TODO: what do I do if LST or REF knowledge == .none
  func mountAngleChange(fromCoord: RaDec, toCoord: RaDec) ->
  (pierAngle: Double, diskAngle: Double) {
    let (fromPierDeg, fromDiskDeg) = raDecToMountAngles(fromCoord)
    let (toPierDeg, toDiskDeg) = raDecToMountAngles(toCoord)
    
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
    
    let (refPierAngle, refDiskAngle) = raDecToMountAngles(reference)
    
    // given:
    //  pierAngle = guideDataBlock.pierCountDeg + pierOffsetDeg
    //  diskAngle = guideDataBlock.diskCountDeg + diskOffsetDeg
    pierOffsetDeg = refPierAngle - guideDataBlock.pierCountDeg
    diskOffsetDeg = refDiskAngle - guideDataBlock.diskCountDeg
    
    // not sure these need to be mapped, but it shouldn't hurt.
    pierOffsetDeg = pierOffsetDeg.mapAnglePm180()
    diskOffsetDeg = diskOffsetDeg.mapAnglePm180()
    
    print("refPierAngle = \(refPierAngle)  pierOffsetDeg = \(pierOffsetDeg)  pierAngle = \(guideDataBlock.pierCountDeg + pierOffsetDeg)")
    print("refDiskAngle = \(refDiskAngle)  diskOffsetDeg = \(diskOffsetDeg)  diskAngle = \(guideDataBlock.diskCountDeg + diskOffsetDeg)")
    
    // Used for color coding values that depend on references
//    pointingKnowledge = lstValid ? .marked : .none
    
  }  // end updateOffsetsTo
  
  //MARK: === Read Data From Mount ==========
  
  // This runs (via Notify Handler) every time EqMount sends a new GuideDataBlock (~10Hz)
  func processDataFromMount(_ guideData: GuideDataBlock) {
    
    // Store the new GuideDataBlock
    guideDataBlock = guideData
    readCount += 1
    updateMountAngles()
    
    // trackingPaused is non zero when tracking.
    raIsTracking = guideDataBlock.trackingPaused == 0 ? true : false;
    
    // Mount Reference Frame: +X forward/polaris, +Y left/west, +Z up/equatorial
    // Mount Accel is mounted +X forward,         +Y Right,     +Z up
    // Map Left Handed accelerometer to Right Handed Telescope
    let rhsMountXl = simd_float3(guideDataBlock.accel_x,
                                 -guideDataBlock.accel_y,
                                 guideDataBlock.accel_z)
    
    let rhsNormMountXl = simd_normalize(rhsMountXl)
    
    // align accelerometer so y component is zero
    //let offset = rhsNormMountXl.y
    let xCorrection = rhsNormMountXl.y  // rotate theta to zero psi
    let xRotation = xRot3x3(thetaRad: xCorrection)
    xlAligned = xRotation * rhsNormMountXl
    
    // This is the only angle with any meaming on the mount.
    theta = atan2(xlAligned.x, xlAligned.z) - PI // TODO: WHY PI (180) here
    
    // Process specific GuideDataBlock commands
    if guideDataBlock.mountState == MountState.PowerUp.rawValue {
      pointingKnowledge = .none
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
  
  //MARK: === Issue Commands to Mount ===
  
  /// ========== Transmit Commands to Mount ==========
  /// Build and transmit GuideCommandBlocks
  /// Convert native iOS app types to Arduino types here - i.e. Doubles to Int32 Counts
  /// No angle conversions or hemisphere awareness at this level.
  
  func guideCommand(_ writeBlock:GuideCommandBlock) {
    rocketMount.bleWrite(GUIDE_COMMAND_UUID, writeData: writeBlock)
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
  // Motion decels to a stop, then Mount goes thru PowerUp state.
  func guideCommandReset() {
    // stop any local timer driven movements
    autoControlTimer.invalidate()
    
    // Tell the mount to Reset
    let resetCommand = GuideCommandBlock(command: GuideCommand.Reset.rawValue)
    guideCommand(resetCommand)
  }

  // Update model angle offsets after manually fine aligning telescope view to target
  func guideCommandMarkTarget() {
    updateOffsetsTo(reference: targetCoord)  // update model angles
    pointingKnowledge = lstValid ? .marked : .none
  }
  
  // Initiate a move by Offset between Current and Target.
  func guideCommandGoToTarget() {
    let (pierDeg, diskDeg) = mountAngleChange(fromCoord: currentPosition,
                                         toCoord: targetCoord)
    
    let goToTargetCommand = GuideCommandBlock(
      command: GuideCommand.GuideToOffset.rawValue,
      pierOffset: Int32( Float32(pierDeg) / guideDataBlock.pierDegPerStep),
      diskOffset: Int32( Float32(diskDeg) / guideDataBlock.diskDegPerStep)
    )

    guideCommand(goToTargetCommand)
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
