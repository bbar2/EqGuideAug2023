//
//  XlData.swift
//  EqGuide
//
//  Created by Barry Bryant on 5/28/23.
//

// Need a three 32 bit word struct to accept the data from BLE.
// simd_float3 does work, but I don't trust it's size or word alignment to not change

struct BleXlData {
  var x: Float
  var y: Float
  var z: Float
}


