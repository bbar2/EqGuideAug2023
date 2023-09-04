//
//  XlGridView.swift
//  EqGuide
//
//  Created by Barry Bryant on 9/1/23.
//

import SwiftUI

struct XlGridView: View {
  @ObservedObject var mountModel: MountBleModel
  
  @EnvironmentObject var viewOptions: ViewOptions
  
  struct cell: View {
    var cellValue: Float
    var body: some View {
      Text(String(format: "%.2f", cellValue))
    }
  }
  
  var body: some View {
    let saddleXlConnected = mountModel.focusModelLink?.bleConnected() ?? false
    Grid {
      Divider().gridCellUnsizedAxes([ .vertical])
      GridRow {
        Text("XL Data").font(viewOptions.sectionHeaderFont)
        Text("Mount")
        Text("Pier")
        Text("Saddle")
      }.font(viewOptions.labelFont)
      GridRow {
        Text("Ax:").font(viewOptions.labelFont)
        cell(cellValue: mountModel.xlAligned.x)
        cell(cellValue: mountModel.pierModelLink?.xlAligned.x ?? 8.88)
        if saddleXlConnected {
          cell(cellValue: mountModel.focusModelLink?.xlAligned.x ?? 8.88)
        } else {
          Text("-").foregroundColor(viewOptions.appDisabledColor)
        }
      }
      GridRow {
        Text("Ay:").font(viewOptions.labelFont)
        cell(cellValue: mountModel.xlAligned.y)
        cell(cellValue: mountModel.pierModelLink?.xlAligned.y ?? 8.88)
        if saddleXlConnected {
          cell(cellValue: mountModel.focusModelLink?.xlAligned.y ?? 8.88)
        } else {
          Text("-").foregroundColor(viewOptions.appDisabledColor)
        }
      }
      GridRow {
        Text("Az:").font(viewOptions.labelFont)
        cell(cellValue: mountModel.xlAligned.z)
        cell(cellValue: mountModel.pierModelLink?.xlAligned.z ?? 8.88)
        if saddleXlConnected {
          cell(cellValue: mountModel.focusModelLink?.xlAligned.z ?? 8.88)
        } else {
          Text("-").foregroundColor(viewOptions.appDisabledColor)
        }
      }
      
    }.font(viewOptions.smallValueFont)
  }
}

struct XlGridView_Previews: PreviewProvider {
  static var previews: some View {
    XlGridView(mountModel: MountBleModel())
  }
}
