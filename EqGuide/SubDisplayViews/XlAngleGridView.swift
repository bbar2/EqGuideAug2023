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
        cell(cellValue: toDeg(mountModel.xlEstLat) )
        if let pierModel = mountModel.pierModelLink {
          cell(cellValue: toDeg(pierModel.xlEstLat))
        } else {
          Text("X").foregroundColor(viewOptions.noBleColor)
        }
        Text("n/a")
      }
      GridRow {
        Text("x:Pier").font(viewOptions.labelFont)
        // Map calcualted x rotations, phi, to Pier angle.
        Text("n/a")
        if let pierModel = mountModel.pierModelLink {
          cell(cellValue: toDeg(pierModel.xlEstPier))
        } else {
          Text("X").foregroundColor(viewOptions.noBleColor)
        }
        Text("n/a")
      }
      GridRow {
        Text("z:Disk").font(viewOptions.labelFont)
        // Map calculated z rotation, psi, to Disk angle
        Text("n/a")
        Text("n/a")
        if saddleXlConnected {
          if let focusModel = mountModel.focusModelLink {
            cell(cellValue: toDeg(focusModel.xlEstDisk))
          } else {
            Text("X").foregroundColor(viewOptions.noBleColor)
          }
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
