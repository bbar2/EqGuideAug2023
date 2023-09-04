//
//  LocationDataView.swift
//  EqGuide
//
//  Created by Barry Bryant on 9/1/23.
//

import SwiftUI

struct LocationDataView: View {
  @ObservedObject var mountModel: MountBleModel
  
  @EnvironmentObject var viewOptions: ViewOptions
  
  var body: some View {
    VStack {
      HStack {
        Text("Location Data")
          .font(viewOptions.sectionHeaderFont)
          .foregroundColor(viewOptions.appActionColor)
        Spacer()
      }
      HStack {
        Text("LST: " + Hms(mountModel.lstDeg).string(viewOptions.showDmsHms))
        Spacer()
        let latString = Dms(mountModel.locationData.latitudeDeg).string(viewOptions.showDmsHms)
        Text("Lat:" + latString)
        Spacer()
        let longString = Dms(mountModel.locationData.longitudeDeg).string(viewOptions.showDmsHms)
        Text("Lng:" + longString)
      }
      .font(viewOptions.smallValueFont)
//      .foregroundColor(lstValidColor())
    }
  }

}



struct LocationDataView_Previews: PreviewProvider {
  static var previews: some View {
    LocationDataView(mountModel: MountBleModel())
  }
}
