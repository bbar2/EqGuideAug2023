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
  
  @State private var showOptions = false
  
  // TODO: Put this in mountModel.  Had trouble accessing viewOptions.  It's
  // also used in other Views, so it's duplicated for now.
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
    
    VStack {
      
      TabTitleView(label: "Hardware View", mountModel: mountModel)
      
      VStack {
        RaDecPairView(
          pairTitle: "Current\nPosition",
          pair: mountModel.currentPosition,
          pierDeg: mountModel.pierCurrentDeg,
          diskDeg: mountModel.diskCurrentDeg,
          lstDeg: mountModel.lstDeg
        )
        .foregroundColor(pointingKnowledgeColor())
        .padding([.bottom], 1)
        
        HStack {
          let latDeg = mountModel.locationDataLink?.latitudeDeg ?? 0.0
          let (alt, az, _) = raDecToAltAz(lstDeg: mountModel.lstDeg,
                                          latDeg: latDeg,
                                          raDeg: mountModel.currentPosition.ra,
                                          decDeg: mountModel.currentPosition.dec)
          Text("Alt: " + Dms(alt).string(viewOptions.showDmsHms))
          Spacer()
          Text("Az: " + Dms(az).string(viewOptions.showDmsHms))
        }
        .font(viewOptions.smallValueFont)
        .foregroundColor(pointingKnowledgeColor())
      }
      Divider()
      if let locData = mountModel.locationDataLink {
        LocationDataView(locData: locData,
                         lstDeg: mountModel.lstDeg)
      } else {
        Text("ERROR: LocationDataView(locationDataLink)")
        Text("       locationDataLink is nil in HardwareView.swift")
      }
//        if let locationData = mountModel.locationDataLink {
//          LocationOptionSheet(locData: locationData,
//                              lstDeg: mountModel.lstDeg)
//        } else {
//          Text("ERROR: LocationOptionSheet(locationDataLink)")
//          Text("       locationDataLink is nil in HardwareView.swift")
//        }
//      }
      Divider()
      
      Spacer()

      XlGridView(mountModel: mountModel)

      XlAngleGridView(mountModel: mountModel)

      Spacer()
      
      RawDataView(gdb: mountModel.mountDataBlock)
        .foregroundColor((mountModel.bleConnected() ? viewOptions.appRedColor : viewOptions.appDisabledColor) )
        .font(viewOptions.smallValueFont)
      
    }
    .foregroundColor(viewOptions.appRedColor)
    .onAppear{
      softBump()
      // Keep focus connected to view saddle angles
      if let focusModel = mountModel.focusModelLink {
        focusModel.connectBle() // initiate connection.
        // after a little delay to let departing tab's onDisappear to run.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
          focusModel.disableBleTimeout()
        }
      }
    }
    .onDisappear{
      // Let saddle BLE go, if pointing knowledge established
      if mountModel.pointingKnowledge != .none {
        if let focusModel = mountModel.focusModelLink {
          focusModel.enableBleTimeout()
        }
      }
    }
    
  }
  
  func didDismiss() {
    print("didDismiss")
  }
      
}

struct HardwareView_Previews: PreviewProvider {
  static let previewGuideModel = MountBleModel()
  static var previews: some View {
    HardwareView(mountModel: previewGuideModel)
  }
}

