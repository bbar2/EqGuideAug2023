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
    
  @EnvironmentObject var viewOptions: ViewOptions
  
  struct cell: View {
    var cellValue: Float
    var body: some View {
      Text(String(format: "%.2f", cellValue))
    }
  }
  
  // TODO: Put this in mountModel.  Had trouble accessing viewOptions.  It's
  // also used by GuideView, so duplicated for now.
  func pointingKnowledgeColor() -> Color {
    switch (mountModel.pointingKnowledge)
    {
      case .none:
        return viewOptions.confNoneColor
      case .estimated:
        return viewOptions.confEstColor
      case .marked:
        return viewOptions.appRedColor
    }
  }
  
  var body: some View {
//    let floatFormat = "%.2f"
    VStack {

      VStack {
        Text("Hardware View").font(viewOptions.appHeaderFont)
        
        HStack {
          Spacer()
          DegreeFormatControl()
        }
      }

      VStack {
        RaDecPairView(
          pairTitle: "Current\nPosition",
          pair: mountModel.currentPosition,
          showDmsHms: viewOptions.showDmsHms,
          pierDeg: mountModel.pierCurrentDeg,
          diskDeg: mountModel.diskCurrentDeg
        )
        .foregroundColor(pointingKnowledgeColor())
        .padding([.bottom], 1)
        
        HStack {
          Text("LST: " + Hms(mountModel.lstDeg).string(viewOptions.showDmsHms))
            .foregroundColor(lstValidColor())
          Spacer()
          let latString = Dms(mountModel.locationData.latitudeDeg ?? 0).string(viewOptions.showDmsHms)
          Text("Lat:" + latString).foregroundColor(lstValidColor())
          Spacer()
          let longString = Dms(mountModel.locationData.longitudeDeg ?? 0).string(viewOptions.showDmsHms)
          Text("Lng:" + longString).foregroundColor(lstValidColor())
        }.font(viewOptions.smallValueFont)
        
        Divider()
      }
      Spacer()
      Grid {
        GridRow {
          Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
          Text("Mount")
          Text("Pier")
          Text("Focus")
        }
        Divider().gridCellUnsizedAxes([ .vertical])
        GridRow {
          Text("Ax:")
          cell(cellValue: mountModel.xlAligned.x)
          cell(cellValue: mountModel.pierModelLink?.xlAligned.x ?? 0.0)
          cell(cellValue: mountModel.focusModelLink?.xlAligned.x ?? 0.0)
        }
        GridRow {
          Text("Ay:")
          cell(cellValue: mountModel.xlAligned.y)
          cell(cellValue: mountModel.pierModelLink?.xlAligned.y ?? 0.0)
          cell(cellValue: mountModel.focusModelLink?.xlAligned.y ?? 0.0)
        }
        GridRow {
          Text("Az:")
          cell(cellValue: mountModel.xlAligned.z)
          cell(cellValue: mountModel.pierModelLink?.xlAligned.z ?? 0.0)
          cell(cellValue: mountModel.focusModelLink?.xlAligned.z ?? 0.0)
        }
        Divider().gridCellUnsizedAxes([ .vertical])
        GridRow {
          Text("theta")
          cell(cellValue: toDeg(mountModel.theta))
          cell(cellValue: toDeg(mountModel.pierModelLink?.theta ?? 0.0))
          cell(cellValue: toDeg(mountModel.focusModelLink?.theta ?? 0.0))
        }
        GridRow {
          Text("phi")
          Text("n/a")
          cell(cellValue: toDeg(mountModel.pierModelLink?.phi ?? 0.0))
          cell(cellValue: toDeg(mountModel.focusModelLink?.phi ?? 0.0))
        }
        GridRow {
          Text("psi")
          Text("n/a")
          Text("n/a")
          cell(cellValue: toDeg(mountModel.focusModelLink?.psi ?? 0.0))
        }
      }
      Spacer()

      RawDataView(gdb: mountModel.mountDataBlock)
        .foregroundColor((mountModel.bleConnected() ? viewOptions.appRedColor : viewOptions.appDisabledColor) )
        .font(viewOptions.smallValueFont)
      
      StatusBarView(mountModel: mountModel)

    }.font(viewOptions.bigValueFont)
  }
  
  func lstValidColor() -> Color {
    return mountModel.lstValid ? viewOptions.appRedColor : viewOptions.confNoneColor
  }

  
  struct LightView_Previews: PreviewProvider {
    static let previewGuideModel = MountBleModel()
    static var previews: some View {
      HardwareView(mountModel: previewGuideModel)
    }
  }
  
}
