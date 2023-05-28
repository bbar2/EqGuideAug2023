//
//  ArmAccelModel.swift
//  EqGuide
//
//  Created by Barry Bryant on 5/24/23.
//

import SwiftUI
import CoreBluetooth
import simd

class ArmPeripheralModel : MyPeripheralDelegate,
                           ObservableObject {
  enum BleState {
    case disconnected
    case connecting
    case ready
  }
  private var bleState = BleState.disconnected

  func bleConnected() -> Bool {
    return bleState == .ready
  }

  var armTheta: Float = 0.0 // roll around X
  var armPhi: Float = 0.0   // pitch around Y
  
  // Focus Service provides focus motor control and focus motor accelerations
  private let ARM_ACCEL_DEVICE_NAMED = "ArmAccel"
  private let ARM_ACCEL_SERVICE_UUID = CBUUID(string: "828b0020-046a-42c7-9c16-00ca297e95eb")
  
  // Parameter Characteristic UUIDs
  private let ARM_ACCEL_XYZ_UUID = CBUUID(string: "828b0021-046a-42c7-9c16-00ca297e95eb")
  
  private let armAccel: MyPeripheral

  private var rawArmXlData = simd_float3(x: 0.0, y: 0.0, z: 0.0) // is left handed
  var rhsArmXlData = simd_float3(x: 0.0, y: 0.0, z: 0.0)         // RHS and normalized
  var alignedArmXlData = simd_float3(x: 0.0, y: 0.0, z: 0.0)       // axis aligned
  
  private var alignArmAccelTransform = matrix_identity_float3x3

  init() {
    armAccel = MyPeripheral(deviceName: ARM_ACCEL_DEVICE_NAMED,
                              serviceUUID: ARM_ACCEL_SERVICE_UUID,
                              dataUUIDs: [ARM_ACCEL_XYZ_UUID])
    armAccel.mpDelegate = self
    armAccel.startBleConnection()
    
    // only need to do this once
    alignArmAccelTransform = buildCalTform()
  }

  //MARK: MyPeripheralDelegate
  
  func onFound(){
  }
  
  // BLE Connected, but have not yet scanned for services and characeristics
  func onConnected(){
    bleState = BleState.connecting
  }
  
  func onDisconnected(){
//    armAccel.startBleConnection()
    bleState = BleState.disconnected
  }
  
  func onReady() {
    // Setup Notifications, to process writes from the FocusMotor peripheral
    
    // Common closure signature using Swift Data type.
    armAccel.setNotify(ARM_ACCEL_XYZ_UUID) { [weak self] (buffer:Data)->Void in
      let numBytes = min(buffer.count, MemoryLayout.size(ofValue: self!.rawArmXlData))
      withUnsafeMutableBytes(of: &self!.rawArmXlData) { pointer in
        _ = buffer.copyBytes(to:pointer, from:0..<numBytes)
      }
      self?.calcArmAngles()
    }

    bleState = BleState.ready
  }

  //MARK: Called by delegate

  // This runs everytime an ArmAccel data struct arrives via BLE.  Nominally at 5Hz.
  // Called by setNotify Closure
  func calcArmAngles() {
    
    // Telescope Reference Frame is +Z down, +X forward (north), +Y right (east)
    // Arm Accel is mounted with +Z down, +X to back and +Y to Right
    // Map Left Handed accelerometer to Right Handed Telescope Frame
    rhsArmXlData.x = -rawArmXlData.x;
    rhsArmXlData.y = rawArmXlData.y;
    rhsArmXlData.z = rawArmXlData.z;
    
    // Normalize unaligned accel data
    let unAlignedArmXlData = simd_normalize(rhsArmXlData)

    // align accelerometer with Telescope Frame - corrects mounting errors
    alignedArmXlData = alignArmAccelTransform * unAlignedArmXlData
        
    // From algebra of inverse transform mapping [0 0 -1] gravity to Telescope frame
    // based on Rx' * Ry' and fixed psi.
    armTheta = asin(-alignedArmXlData.x)
    armPhi = asin(alignedArmXlData.y / cos(armTheta))
  }
  
  // Build calibration transform to aligns the arm accelerometer so it's X axis
  // is aligned with the ideal telescope frame of reference. With this calibration
  // applied, the x axis of the accelerations reported will not does not move as psi
  // rotates from 90E to 90W, and psi = 0 will be established.  There may still be
  // psi offsets at psi = +- 90 degrees.
  //
  // Any movement of declination motor control box may necessitate re measuring
  // these four calibration points.
  // - With identity calibration measure:
  //   1. theta with arm at 90E, determined with bubble level
  //   2. theta with arm at 90W, determined with bubble level
  // - Build and apply zRotation based on 1 and 2.
  // - theta90W should now = -theta90E
  // - Get 3rd calibration point:
  //   3. theta with arm vertical (at 0), determined by bubble level
  // - Build and apply yRotation*zRotation
  // - X axis is now aligned, and theta should not change as function of roll().
  // - Measure:
  //   4. psi at arm at 0 (vertical), determined by bubble level
  // - Build and apply xRotation to zero psi
  // This procedure alligns x axis and zero's roll.
  // It does not calibrate the accelerations, so there may be noticable (1 to 2 deg)
  // offsets at psi = +-90 degrees of roll around X.
  func buildCalTform() -> simd_float3x3 {
    
    // Two calibration points measured before applying correction, to estimate Z rotation
    // correction to center up theta at psi=90E and psi=90W readings
    let theta90EDeg = Float(-23.4)  // Theta reported while arm East by bubble level
    let theta90WDeg = Float(-27.3)  // Theta reported while arm West by bubble level
    let zCorrection = (toRad(-(theta90EDeg - theta90WDeg)/2))
    
    // Rotation required to cancel out Z mounting rotational offset
    let zRotation = zRot3x3(psiRad: zCorrection)   // offset in rads to make theta90E = -theta90W
    
    // Use theta at psi=0 (measured after Z correction alone) to correct y pointing
    let theta90Deg = Float(-25.3) // both 90E and 90W report -25.3 after z correction
    let theta0Deg = Float(-25.0)
    let yCorrection = (toRad(theta0Deg - theta90Deg))
    let yRotation = yRot3x3(phiRad: yCorrection)
    
    // After applying z and y corrections, measure psi at psi=0(by bubble level)
    let psi0 = Float(-3.2)
    let xCorrection = psi0  // rotate theta to zero psi
    let xRotation = xRot3x3(thetaRad: xCorrection)

    // PreMultiplyt to Concatinate transforms
    let accelAlign = xRotation * yRotation * zRotation

    return accelAlign
  }

}
