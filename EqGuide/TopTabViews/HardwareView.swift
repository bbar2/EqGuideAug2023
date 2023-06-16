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
  
  struct cell: View {
    var cellValue: Float
    var body: some View {
      Text(String(format: "%.2f", cellValue))
    }
  }
  
  var body: some View {
    let floatFormat = "%.2f"
    VStack {
      Text("Hardware View").bold().font(.title)
      Spacer()
      BleStatusView(mountModel: mountModel, focusModel: focusModel, armModel: armModel)
      Spacer()
      Grid {
        GridRow {
          Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
          Text("Mount")
          Text("Arm")
          Text("Focus")
        }
        Divider().gridCellUnsizedAxes([ .vertical])
        GridRow {
          Text("Ax:")
          cell(cellValue: mountModel.xlAligned.x)
          cell(cellValue: armModel.xlAligned.x)
          cell(cellValue: focusModel.xlAligned.x)
        }
        GridRow {
          Text("Ay:")
          cell(cellValue: mountModel.xlAligned.y)
          cell(cellValue: armModel.xlAligned.y)
          cell(cellValue: focusModel.xlAligned.y)
        }
        GridRow {
          Text("Az:")
          cell(cellValue: mountModel.xlAligned.z)
          cell(cellValue: armModel.xlAligned.z)
          cell(cellValue: focusModel.xlAligned.z)
        }
        Divider().gridCellUnsizedAxes([ .vertical])
        GridRow {
          Text("theta")
          cell(cellValue: toDeg(mountModel.theta))
          cell(cellValue: toDeg(armModel.theta))
          cell(cellValue: toDeg(focusModel.theta))
        }
        GridRow {
          Text("phi")
          Text("n/a")
          cell(cellValue: toDeg(armModel.phi))
          cell(cellValue: toDeg(focusModel.phi))
        }
        GridRow {
          Text("psi")
          Text("n/a")
          Text("n/a")
          cell(cellValue: toDeg(focusModel.psi))
        }
      }
      Spacer()

      RawDataView(gdb: mountModel.guideDataBlock)
        .foregroundColor((mountModel.bleConnected() ? viewOptions.appRedColor : viewOptions.appDisabledColor) )
        .font(viewOptions.smallValueFont)

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
