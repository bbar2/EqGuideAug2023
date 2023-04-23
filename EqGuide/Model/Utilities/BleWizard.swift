//
//  BleDelegates.swift
//  FocusControl
//
//  Created by Barry Bryant on 12/5/21
//  Class sets iOS app as BLE Central to communicate with BLE Peripheral
//
//  1. Include this object in project Model class.
//  2. Make the model comply to the BleWizardDelagate protocol.
//  3. Construct with service and characteristic UUID's
//  4. Set BleWizard's delegate property to the Model class.
//  5. Then Call:
//     1. start - to initiate CBCentralManager and CBPeripheral Delegates
//     2. bleWrite - to write data to a Peripheral
//     3. bleRead - to initiate a noWait read from Peripheral.
//     4. Handle events and status with the delagate methods.

import CoreBluetooth
import UIKit

protocol BleWizardDelegate: AnyObject {
  func reportBleScanning()
  func reportBleNotAvailable()
  func reportBleServiceFound()
  func reportBleServiceConnected()
  func reportBleServiceDisconnected()
  func reportBleServiceCharaceristicsScanned()
}

class BleWizard: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
  
  weak var delegate: BleWizardDelegate?

  private var service_uuid: CBUUID     // UUID of desired service
  private var ble_data_uuids: [CBUUID]  // UUID for each BLE data value

  // Use dictionary's for uuid to characteristic mapping
  private var dataDictionary: [CBUUID: CBCharacteristic?] = [:]
  private var readResponderDictionary: [CBUUID: (Int32)->Void] = [:]
  private var notifyResponderDictionary: [CBUUID: (GuideDataBlock)->Void] = [:]

  // Core Bluetooth variables
  private var cbCentralManager     : CBCentralManager!
  private var focusMotorPeripheral : CBPeripheral?

  init(serviceUUID: CBUUID, bleDataUUIDs: [CBUUID])
  {
    self.service_uuid = serviceUUID
    self.ble_data_uuids = bleDataUUIDs
    super.init()
  }
  
  // Called by BleWizard's owning model to initialize BLE communication
  public func start() {
    cbCentralManager = CBCentralManager(delegate: self, queue: nil)
  }

//MARK:- CBCentralManagerDelegate

  // Step 1 - Start scanning for BLE DEVICE advertising required SERVICE
  func centralManagerDidUpdateState(_ central: CBCentralManager)
  {
    if (central.state == .poweredOn)
    {
      delegate?.reportBleScanning()
      central.scanForPeripherals(withServices: [service_uuid], options: nil)
    }
    else
    {
      delegate?.reportBleNotAvailable()
    }
  }

  // Step 2 - Once SERVICE found, stop scanning and connect Peripheral
  func centralManager(_ central: CBCentralManager,
                      didDiscover peripheral: CBPeripheral,
                      advertisementData: [String : Any],
                      rssi RSSI: NSNumber)
  {
    cbCentralManager.stopScan()
    cbCentralManager.connect(peripheral, options: nil)
    focusMotorPeripheral = peripheral
    delegate?.reportBleServiceFound()
  }
  

  
  // Step 3 - Once connected to peripheral, Find desired service
  func centralManager(_ central: CBCentralManager,
                      didConnect peripheral: CBPeripheral)
  {
    peripheral.delegate = self
    peripheral.discoverServices([service_uuid]) // already know it has it!

    delegate?.reportBleServiceConnected()
  }
  

  
  // If disconnected - resume scanning for Focus Motor peripheral
  func centralManager(_ central: CBCentralManager,
                      didDisconnectPeripheral peripheral: CBPeripheral,
                      error: Error?)
  {
    if let e = error {
      print("error not nil in centralManager.didDisconnectPeripheral")
      print(e.localizedDescription)
    }

    cbCentralManager.scanForPeripherals(withServices: [service_uuid],
                                        options: nil)

    delegate?.reportBleServiceDisconnected()
  }




//MARK:- CBPeripheralDelegate

  // Step 4 - Once service found, look for specific parameter characteristics
  func peripheral(_ peripheral: CBPeripheral,
                  didDiscoverServices error: Error?)
  {
    if let e = error {
      print("error not nil in peripheral.didDiscoverServices")
      print(e.localizedDescription)
      return
    }

    if let services = peripheral.services {
      for service in services {
        peripheral.discoverCharacteristics(ble_data_uuids, for: service)
      }
    }
  }

  // Step 5 - Store CBCharacterstic values for future communication
  func peripheral(_ peripheral: CBPeripheral,
                  didDiscoverCharacteristicsFor service: CBService,
                  error: Error?)
  {
    if let e = error {
      print("error not nil in peripheral.didDiscoverCharacteristicsFor")
      print(e.localizedDescription)
      return
    }

    // Create a dictionary to find characteristics, via UUID
    if let characteristic = service.characteristics {
      for characteristic in characteristic {
        dataDictionary[characteristic.uuid] = characteristic
      }
    }
    delegate?.reportBleServiceCharaceristicsScanned()
  }
  

  
//MARK:- Write(UUID) and Read(UUID) calls

  // Called by owner to write data to BLE
  func bleWrite(_ write_uuid: CBUUID, writeData: Int32) {
    if let write_characteristic = dataDictionary[write_uuid] {
      let data = Data(bytes: [writeData], count: 4) // Int32 writeData is 4 bytes
      focusMotorPeripheral?.writeValue(data,
                                       for: write_characteristic!,
                                       type: .withoutResponse)
    }
  }

  // Called by GuideModel to write data to BLE
  func bleWrite(_ write_uuid: CBUUID, writeBlock: GuideCommandBlock) {
    if let write_characteristic = dataDictionary[write_uuid] {
      let data = Data(bytes: [writeBlock],
                      count: MemoryLayout<GuideDataBlock>.size)
      focusMotorPeripheral?.writeValue(data,
                                       for: write_characteristic!,
                                       type: .withoutResponse)
    }
  }

  enum BluetoothReadError: LocalizedError {
    case characteristicNotFound
  }
  
  func bleRead(uuid: CBUUID, onReadResult: @escaping (Int32)->Void) throws {
    guard let read_characteristic = dataDictionary[uuid] else {      // find characteristic
      throw BluetoothReadError.characteristicNotFound
    }
    focusMotorPeripheral?.readValue(for: read_characteristic!) // issue the read
    readResponderDictionary[uuid] = onReadResult              // handle data when read completes
  }
  
  func setNotify(uuid: CBUUID, onNotify: @escaping (GuideDataBlock)->Void) {
    if let read_characteristic = dataDictionary[uuid] {
      focusMotorPeripheral?.setNotifyValue(true, for: read_characteristic!)
      notifyResponderDictionary[uuid] = onNotify
   }
//    print("size of GuideDataBlock = \(MemoryLayout<GuideDataBlock>.size) bytes")
  }
  
  func peripheral(_ peripheral: CBPeripheral,
                  didUpdateNotificationStateFor characteristic:CBCharacteristic,
                  error: Error?)
  {
  }

  // Called by peripheral.readValue,
  // or after updates if using peripheral.setNotifyValue
  func peripheral(_ peripheral: CBPeripheral,
                  didUpdateValueFor characteristic: CBCharacteristic,
                  error: Error?)
  {
    if let e = error {
      print("error not nil in peripheral.didUpdateValueFor")
      print(e.localizedDescription)
      return
    }
    
    // call UUID's responder with the Int32 Data
    if let readResponder = readResponderDictionary[characteristic.uuid] {
      // assume all read values are Int32
      // - else require each responder to perform appropriate .getBytes mapping
      var readData:Int32 = -1  // if I see this, I know nothing read
      // Copy Data buffer to Int32
      if let data = characteristic.value {
        (data as NSData).getBytes(&readData, length:4)
      }
      readResponder(readData)
    }
    
    // or .. call UUID's notify responder
    if let notifyResponder = notifyResponderDictionary[characteristic.uuid] {
      // assume all notify responders are handling the GuideDataBlock struct
      var dataBlock = GuideDataBlock()
      // Copy Data buffer to Int32
      if let data = characteristic.value {
        (data as NSData).getBytes(
          &dataBlock, length:MemoryLayout<GuideDataBlock>.size)
      }
      notifyResponder(dataBlock)
    }
  }

}
