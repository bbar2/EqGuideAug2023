//
//  BitVector.swift
//  EqGuide
//
//  Created by Barry Bryant on 6/2/22.
//

struct BitVector {
  private var bitVector:Int32
  
  init() {
    bitVector = Int32(0)
  }
  
  mutating func set(_ bitNum: Int32)
  {
    let setMask = Int32(1) << bitNum
    bitVector = bitVector | setMask
  }
  
  mutating func clear(_ bitNum: Int32)
  {
    let clearMask = ~(Int32(1) << bitNum)
    bitVector = bitVector & clearMask
  }
  
  func isSet(_ bitNum: Int32) -> Bool {
    let testMask = Int32(1) << bitNum
    return (bitVector & testMask) != 0
  }
  
  func isClear(_ bitNum: Int32) -> Bool {
    let testMask = Int32(1) << bitNum
    return (bitVector & testMask) == 0
  }
}
