//
//  PierAccelModel.swift
//  EqGuide
//
//  Created by Barry Bryant on 5/24/23.
//

import SwiftUI
import CoreBluetooth
import simd

class PierBleModel : MyPeripheralDelegate,
                    ObservableObject {
  enum BleState {
    case disconnected
    case connecting
    case ready
  }
  
  @Published var bleState = BleState.disconnected
  
  func bleConnected() -> Bool {
    return bleState == .ready
  }
  
  // Focus Service provides focus motor control and focus motor accelerations
  private let ARM_ACCEL_DEVICE_NAMED = "ArmAccel"
  private let ARM_ACCEL_SERVICE_UUID = CBUUID(string: "828b0020-046a-42c7-9c16-00ca297e95eb")
  
  // Parameter Characteristic UUIDs
  private let ARM_ACCEL_XYZ_UUID = CBUUID(string: "828b0021-046a-42c7-9c16-00ca297e95eb")
  
  private let pierPeripheral: MyPeripheral
  
  private var xlRaw = BleXlData(x: 0.0, y: 0.0, z: 0.0) // left handed
  @Published var xlAligned = simd_float3(x: 0.0, y: 0.0, z: 0.0)   // axis aligned
  @Published var theta: Float = 0.0  // roll around X
  @Published var phi:   Float = 0.0  // pitch around Y
  @Published var xlEstLat:  Float = 0.0  // estimate latitude from theta
  @Published var xlEstPier: Float = 0.0  // estimate pier angle from phi

  private var alignPierAccelTransform = matrix_identity_float3x3

  init() {
    pierPeripheral = MyPeripheral(deviceName: ARM_ACCEL_DEVICE_NAMED,
                            serviceUUID: ARM_ACCEL_SERVICE_UUID,
                            dataUUIDs: [ARM_ACCEL_XYZ_UUID])
    pierPeripheral.mpDelegate = self
    pierPeripheral.startBleConnection()
    
    // only need to do this once
    alignPierAccelTransform = buildCalTform() // TODO: need to update
  }
  
  //MARK: MyPeripheralDelegate
  
  func onFound(){
  }
  
  // BLE Connected, but have not yet scanned for services and characeristics
  func onConnected(){
    bleState = BleState.connecting
  }
  
  func onDisconnected(){
    //    pierAccel.startBleConnection()
    bleState = BleState.disconnected
    
    // attmempt to restart the connection
    pierPeripheral.startBleConnection()  // restart after connection lost
  }
  
  func onReady() {
    // Setup Notifications, to process writes from the FocusMotor peripheral
    
    // Common closure signature using Swift Data type.
    pierPeripheral.setNotify(ARM_ACCEL_XYZ_UUID) { [weak self] (buffer:Data)->Void in
      let numBytes = min(buffer.count, MemoryLayout.size(ofValue: self!.xlRaw))
      withUnsafeMutableBytes(of: &self!.xlRaw) { pointer in
        _ = buffer.copyBytes(to:pointer, from:0..<numBytes)
      }
      self?.calcPierAngles()
    }
    
    bleState = BleState.ready
  }
  
  //MARK: Called by delegate
  
  // This runs everytime an PierAccel data struct arrives via BLE.  Nominally at 5Hz.
  // Called by setNotify Closure
  func calcPierAngles() {
    
    // Pier Reference Frame is: +X forward (north), +Y left (west), +Z up
    // Pier Accel is mounted:   +X back,            +Y right,       +Z down
    // Map Left Handed accelerometer to Right Handed Telescope Frame
    let rhsPierXl = simd_float3(-xlRaw.x, -xlRaw.y, -xlRaw.z)
        
    // align accelerometer with Telescope Frame - corrects mounting errors
    let rhsNormPierXl = simd_normalize(rhsPierXl)
    xlAligned = alignPierAccelTransform * rhsNormPierXl
    
    // From algebra of inverse transform mapping [0 0 -1] gravity to Telescope frame
    // based on Rx' * Ry' and fixed psi.
    theta = asin(-xlAligned.x)
    xlEstLat = -theta  // theta maps to latitude

    let denom = cos(theta)
    var asinTerm: Float
    if denom != 0 {
      asinTerm = xlAligned.y / denom
    } else {
      asinTerm = 0.0 // if denom == 0; theta=90 so .x=1 and .y=0; so asinTerm=0
    }
    // avoid nan when XL noise causes |asinTerm| to exceed.  I've seen 1.0000001
    if abs(asinTerm) > 1.0 {
      asinTerm = 1.0 * sign(asinTerm)
    }
    phi = asin(asinTerm)
    xlEstPier = -phi // phi maps to pier angle
  }
  
  // Build calibration transform to align pier accelerometer so pier X axis
  // is aligned with the ideal telescope frame of reference. With this calibration
  // applied, the x axis of the accelerations reported does not move as psi
  // rotates from 90E to 90W, and psi = 0 will be established.  There may still be
  // psi offsets at psi = +- 90 degrees.
  //
  // Any re-mounting of declination motor control box may require re measuring
  // these four calibration points.
  // - Tilt to some representative theta - about 36 will do.
  // - With identity calibration measure:
  //   1. theta with pier at 90E, determined with bubble level
  //   2. theta with pier at 90W, determined with bubble level
  // - Build and apply zRotation based on 1 and 2.
  // - theta90W should now = -theta90E
  // - Get 3rd calibration point:
  //   3. theta with pier vertical (at 0), determined by bubble level
  // - Build and apply yRotation*zRotation
  // - X axis is now aligned, and theta should not change as function of roll().
  // - Measure:
  //   4. psi at pier at 0 (vertical), determined by bubble level
  // - Build and apply xRotation to zero psi
  // This procedure alligns x axis and zero's roll.
  // It does not calibrate the accelerations, so there may be noticable (1 to 2 deg)
  // offsets at psi = +-90 degrees of roll around X.
  
  // Really, all I care about is using Az = 0 to find East, or Ay = 0 to find Home.
  // 1. Find Home with bubble.  Rotate X to get Y = 0.
  // 2. Find East with bubble.
  func buildCalTform() -> simd_float3x3 {
    
    // Two calibration points measured before applying correction, to estimate Z rotation
    // correction to center up phi at using phi=90E and phi=90W readings
    let theta90EDeg = Float(-35.80)  // Theta reported while pier East by bubble level
    let theta90WDeg = Float(-39.57)  // Theta reported while pier West by bubble level
    let zCorrection = toRad((theta90EDeg - theta90WDeg)/2)
    
    // Rotation required to cancel out Z mounting rotational offset
    let zRotation = zRot3x3(psiRad: zCorrection)   // offset makes theta90E = -theta90W
    
    // Use theta at phi=0 (measured after Z correction alone) to correct y pointing
    let thetaAtPhi90Deg = Float(-37.32) // both 90E and 90W report this after z correction
    let thetaAtPhi0Deg = Float(-36.88)
    let yCorrection = -(toRad(thetaAtPhi0Deg - thetaAtPhi90Deg))
    let yRotation = yRot3x3(thetaRad: yCorrection)
    
    // TODO: this is not right yet - the z and y corrections help a lot.  Not this.
    // After applying z and y corrections, measure phi at phi=0(by bubble level)
//    let phi0Deg = Float(-1.56)
//    let xCorrection = toRad(phi0Deg)  // rotate phi to zero phi
//    let xRotation = xRot3x3(phiRad: xCorrection)
    
    // PreMultiply to Concatinate transforms
    let accelAlign = /* xRotation */ yRotation * zRotation * matrix_identity_float3x3
    
    return accelAlign
  }
  
}
