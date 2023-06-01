//
//  Hardware.swift
//  EqGuide
//
//  Created by Barry Bryant on 5/27/23.
//

import SwiftUI
import simd


struct HardwareView: View {
  @ObservedObject var mountModel: MountBleModel
  @ObservedObject var focusModel: FocusBleModel
  @ObservedObject var armModel: ArmBleModel
    
  @EnvironmentObject var viewOptions: ViewOptions
  
 struct AccelGridRow: View {
    var label: String
    var mount: Float
    var arm: Float
    var focus: Float
    let accelFormat = "%.2f"
    var body: some View {
      HStack {
        Spacer()
        Text(label)
        Spacer()
        Text(String(format: accelFormat, mount))
        Spacer()
        Text(String(format: accelFormat, arm))
        Spacer()
        Text(String(format: accelFormat, focus))
        Spacer()
      }
    }
  }
  
  struct AccelGridView: View {
    var mount: simd_float3
    var arm: simd_float3
    var focus: simd_float3
    var body: some View {
      VStack {
        HStack {
          Spacer()
          Text("Mount")
          Spacer()
          Text("Arm")
          Spacer()
          Text("Focus")
        }
        AccelGridRow(label: "Ax:", mount: mount.x, arm: arm.x, focus: focus.x)
        AccelGridRow(label: "Ay:", mount: mount.y, arm: arm.y, focus: focus.y)
        AccelGridRow(label: "Az:", mount: mount.z, arm: arm.z, focus: focus.z)
      }
    }
  }
  
  var body: some View {
    VStack {
      Text("Hardware View").bold().font(.title)
      Spacer()
      BleStatusView(mountModel: mountModel, focusModel: focusModel, armModel: armModel)
      Spacer()
      AccelGridView(mount: mountModel.xlAligned,
                    arm: armModel.xlAligned,
                    focus: focusModel.xlAligned)
      AccelGridRow(label: "theta",
                   mount: toDeg(mountModel.theta),
                   arm: toDeg(armModel.theta),
                   focus: toDeg(focusModel.theta))
      AccelGridRow(label: "phi",
                   mount: 0,
                   arm: toDeg(armModel.phi),
                   focus: toDeg(focusModel.phi))
      AccelGridRow(label: "psi",
                   mount: 0,
                   arm: 0,
                   focus: toDeg(focusModel.psi))

      Spacer()
    }.font(viewOptions.bigValueFont)
  }
  
  struct LightView_Previews: PreviewProvider {
    static let previewGuideModel = MountBleModel()
    static let previewFocusModel = FocusBleModel()
    static let previewArmModel = ArmBleModel()
    static var previews: some View {
      HardwareView(mountModel: previewGuideModel,
                   focusModel: previewFocusModel,
                   armModel: previewArmModel)
    }
  }
  
}
