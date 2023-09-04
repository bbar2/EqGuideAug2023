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
          diskDeg: mountModel.diskCurrentDeg
        )
        .foregroundColor(pointingKnowledgeColor())
        .padding([.bottom], 1)
        
        HStack {
          let (alt, az, _) = raDecToAltAz(lstDeg: mountModel.lstDeg,
                                          latDeg: mountModel.locationData.latitudeDeg,
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
      Button {
        showOptions = true
      } label: {
        LocationDataView(mountModel: mountModel)
      }
      .sheet(isPresented: $showOptions,
             onDismiss: didDismiss) {
        LocationOptionSheet(locData: mountModel.locationData)
      }
      Divider()
      
      Spacer()

      XlGridView(mountModel: mountModel)

      XlAngleGridView(mountModel: mountModel)

      Spacer()
      
      RawDataView(gdb: mountModel.mountDataBlock)
        .foregroundColor((mountModel.bleConnected() ? viewOptions.appRedColor : viewOptions.appDisabledColor) )
        .font(viewOptions.smallValueFont)
      
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

