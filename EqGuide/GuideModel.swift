//
//  GuideModel.swift
//  EqGuide
//
//  Created by Barry Bryant on 1/7/22.
//

import SwiftUI
import CoreBluetooth

struct GuideDataBlock {
  var mountState:Int32 = 0
  var mountTimeMs:UInt32 = 0
  var raCount:Int32 = 0
  var decCount:Int32 = 0
}

struct GuideCommandBlock {
  var command:Int32
  var raOffset:Int32
  var decOffset:Int32
}

enum GuideCommand:Int32 {
  case noOp = 0
  case elAdd1Deg = 1
  case elSub1Deg = 2
}

class GuideModel : BleWizardDelegate, ObservableObject  {

  @Published var statusString = "Not Started"
  @Published var var1:Int32 = 0
  @Published var readCount = 0
  @Published var guideDataBlock = GuideDataBlock()
  
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
    bleWizard.setNotify(uuid: GUIDE_DATA_BLOCK_UUID) { [weak self] guideData in
      self?.guideDataBlock = guideData
      self?.readCount += 1
    }
    
  }
  func guideCommand(_ writeBlock:GuideCommandBlock) {
    bleWizard.bleWrite(GUIDE_COMMAND_UUID, writeBlock: writeBlock)
  }
  
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
  
}
