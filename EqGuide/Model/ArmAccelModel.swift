//
//  ArmAccelModel.swift
//  EqGuide
//
//  Created by Barry Bryant on 5/24/23.
//

import SwiftUI
import CoreBluetooth
import simd

class ArmAccelModel : MyPeripheralDelegate,
                      ObservableObject {
    
  var armTheta: Float = 0.0 // roll around X
  var armPhi: Float = 0.0   // pitch around Y

  // Acceleration Structure received from Focus Motor
  struct XlData {
    var x: Float32
    var y: Float32
    var z: Float32
  }

  // Focus Service provides focus motor control and focus motor accelerations
  private let ARM_ACCEL_DEVICE_NAMED = "ArmAccel"
  private let ARM_ACCEL_SERVICE_UUID = CBUUID(string: "828b0020-046a-42c7-9c16-00ca297e95eb")
  
  // Parameter Characteristic UUIDs
  private let ARM_ACCEL_XYZ_UUID = CBUUID(string: "828b0021-046a-42c7-9c16-00ca297e95eb")
  
  private let armAccel: MyPeripheral

  private let PI = Float(3.1415927)

  private var rawArmXlData = XlData(x: 0.0, y: 0.0, z: 0.0)    // is left handed
  var rhsArmXlData = XlData(x: 0.0, y: 0.0, z: 0.0)    // mapped to RHS
  
  private var alignArmAccelTransform = matrix_identity_float3x3

  func toDeg(_ rad:Float) -> Float {
    return rad * 180 / PI
  }

  func toRad(_ deg:Float) -> Float {
    return deg * PI / 180
  }

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
  }
  
  func onDisconnected(){
//    armAccel.startBleConnection()
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
  }

  //MARK: Called by delegate

  // This runs everytime an ArmAccel data struct arrives via BLE.  Nominally at 5Hz.
  // Called by setNotify Closure
  func calcArmAngles() {
    
    // Telescope Reference Frame is +Z down, +X forward (north), +Y right (east)
    // Arm Accel is mounted with +Z down, +X to back and +Y to Right
    // Map Left Handed accelerometer to Right Handed Telescope Frame by:
    // Flipping +X to forward along line of sight
    rhsArmXlData.x = -rawArmXlData.x;
    rhsArmXlData.y = rawArmXlData.y;
    rhsArmXlData.z = rawArmXlData.z;
    
    // normalize
    let mag = sqrt(powf(rhsArmXlData.x, 2) + powf(rhsArmXlData.y, 2) + powf(rhsArmXlData.z, 2))
    let armAx = rhsArmXlData.x / mag
    let armAy = rhsArmXlData.y / mag
    let armAz = rhsArmXlData.z / mag

    // align accelerometer with Telescope Frame - corrects mounting errors
    let unAlignedAccel = simd_float3(armAx, armAy, armAz)
    let correctedAccel = alignArmAccelTransform * unAlignedAccel
        
    // From algebra of inverse transform mapping [0 0 -1] gravity to Telescope frame
    // based on Rx' * Ry' and fixed psi.
    armTheta = asin(-correctedAccel[X])
    armPhi = asin(correctedAccel[Y] / cos(armTheta))
  }
  
  // Tranform aligns accelerometer so X axis does not move as psi rotates from 90E to 90W
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
