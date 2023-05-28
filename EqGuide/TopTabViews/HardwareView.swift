//
//  Hardware.swift
//  EqGuide
//
//  Created by Barry Bryant on 5/27/23.
//

import SwiftUI
import simd


struct HardwareView: View {
  @ObservedObject var mountModel: MountPeripheralModel
  @ObservedObject var focusModel: FocusPeripheralModel
  @ObservedObject var armModel: ArmPeripheralModel
    
  @EnvironmentObject var viewOptions: ViewOptions
  
  struct AccelView: View {
    var label: String
    var value: Float
    var format: String = "%.2f"
    
    var body: some View {
      Text(String(format: label + format, value))
    }
  }
  
  struct Accel3View: View {
    var xlData: simd_float3
    var body: some View {
      HStack {
        AccelView(label: "x", value: xlData.x)
        AccelView(label: "y", value: xlData.y)
        AccelView(label: "z", value: xlData.z)
      }
    }
    
  }
  
  var body: some View {
    VStack {
      Text("Hardware View").bold()
      BleStatusView(mountModel: mountModel, focusModel: focusModel, armModel: armModel)
      HStack {
        Text("Mount: ")
        Accel3View(xlData: mountModel.rhsMountXlData)
      }
      HStack {
        Text("Focuser: ")
        Accel3View(xlData: focusModel.rhsXlData)
      }
      HStack {
        Text("Arm: ")
        Accel3View(xlData: armModel.rhsArmXlData)
      }
    }
  }
  
  struct LightView_Previews: PreviewProvider {
    static let previewGuideModel = MountPeripheralModel()
    static let previewFocusModel = FocusPeripheralModel()
    static let previewArmModel = ArmPeripheralModel()
    static var previews: some View {
      HardwareView(mountModel: previewGuideModel,
                   focusModel: previewFocusModel,
                   armModel: previewArmModel)
    }
  }
  
}
