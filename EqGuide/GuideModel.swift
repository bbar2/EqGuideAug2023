//
//  GuideModel.swift
//  EqGuide
//
//  Created by Barry Bryant on 1/7/22.
//

import SwiftUI
import CoreBluetooth

struct GuideDataBlock {
  var word1:Int32 = 0
  var word2:Int32 = 0
}

class GuideModel : BleWizardDelegate, ObservableObject  {

  @Published var statusString = "Not Started"
  @Published var var1:Int32 = 0
  @Published var readCount = 0
  @Published var guideDataBlock = GuideDataBlock()

  // All UUID strings must match the Arduino C++ RocketMount UUID strings
  private let GUIDE_SERVICE_UUID = CBUUID(string: "828b0010-046a-42c7-9c16-00ca297e95eb")
  private let GUIDE_VAR1_UUID    = CBUUID(string: "828b0011-046a-42c7-9c16-00ca297e95eb")
  private let GUIDE_DATA_STRUCT_UUID = CBUUID(string: "828b0012-046a-42c7-9c16-00ca297e95eb")

  private let bleWizard: BleWizard  //contain a BleWizard
  
  
  init() {
    self.bleWizard = BleWizard(
      serviceUUID: GUIDE_SERVICE_UUID,
      bleDataUUIDs: [GUIDE_VAR1_UUID, GUIDE_DATA_STRUCT_UUID])

    // Force self implement all delegate methods of BleWizardDelegate protocol
    bleWizard.delegate = self
  }

  func guideModelInit() {
    bleWizard.start()
    statusString = "Searching for RocketMount ..."
    initViewModel()
  }
  
  // Called by focusMotorInit & BleDelegate overrides on BLE Connect or Disconnect
  func initViewModel(){
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
//    bleWizard.setNotify(uuid: GUIDE_VAR1_UUID) { [weak self] resultInt in
//      self?.var1 = resultInt
//      self?.readCount += 1
////      self?.readVar1()
//    }
    bleWizard.setNotify(uuid: GUIDE_DATA_STRUCT_UUID) { [weak self] guideData in
      self?.guideDataBlock = guideData
      self?.readCount += 1
    }
    
//    readVar1()
  }
  
  func readVar1()  {
    do {
      try bleWizard.bleRead(uuid: GUIDE_VAR1_UUID) { [weak self] resultInt in
        self?.var1 = resultInt
        self?.readCount += 1
        self?.readVar1()
      }
    } catch {
      print(error)
    }
  }
  
}
