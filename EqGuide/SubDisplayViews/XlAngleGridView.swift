//
//  XlAngleGridView.swift
//  EqGuide
//
//  Created by Barry Bryant on 9/1/23.
//

import SwiftUI

struct XlAngleGridView: View {
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
        HStack {
          Text("XL Estimated Rotations").font(viewOptions.sectionHeaderFont)
          Spacer()
        }.gridCellColumns(4)}
      GridRow {
        Text("y:Lat").font(viewOptions.labelFont)
        // Map calculated y rotataions, theta, to latitude
        let mountXlLatDeg = -toDeg(mountModel.theta)
        cell(cellValue: mountXlLatDeg)
        let pierXlLatDeg  = -toDeg(mountModel.pierModelLink?.theta ?? 8.88)
        cell(cellValue: pierXlLatDeg)
        if saddleXlConnected {
          let saddleXlLatDeg = -toDeg(mountModel.focusModelLink?.theta ?? 8.88)
          cell(cellValue: saddleXlLatDeg)
        } else {
          Text("-").foregroundColor(viewOptions.appDisabledColor)
        }
      }
      GridRow {
        Text("x:Pier").font(viewOptions.labelFont)
        // Map calcualted x rotations, phi, to Pier angle.
        Text("n/a")
        let pierXlPierDeg  = -toDeg(mountModel.pierModelLink?.phi ?? 8.88)
        cell(cellValue: pierXlPierDeg)
        if saddleXlConnected {
          let saddleXlPierDeg = -toDeg(mountModel.focusModelLink?.phi ?? 8.88)
          cell(cellValue: saddleXlPierDeg)
        } else {
          Text("-").foregroundColor(viewOptions.appDisabledColor)
        }
      }
      GridRow {
        Text("z:Disk").font(viewOptions.labelFont)
        // Map calculated z rotation, psi, to Disk angle
        Text("n/a")
        Text("n/a")
        if saddleXlConnected {
          let saddleXlDiskDeg = 90.0-toDeg(mountModel.focusModelLink?.psi ?? 8.88)
          cell(cellValue: saddleXlDiskDeg)
        } else {
          Text("-").foregroundColor(viewOptions.appDisabledColor)
        }
      }
    }.font(viewOptions.smallValueFont)
  }
}

struct XlAngleGridView_Previews: PreviewProvider {
  static var previews: some View {
    XlAngleGridView(mountModel: MountBleModel())
  }
}
