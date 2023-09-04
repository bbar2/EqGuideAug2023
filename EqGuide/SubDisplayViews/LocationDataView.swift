//
//  LocationDataView.swift
//  EqGuide
//
//  Created by Barry Bryant on 9/1/23.
//

import SwiftUI

struct LocationDataView: View {
  @ObservedObject var locData: LocationData
  var lstDeg : Double
  
  @EnvironmentObject var viewOptions: ViewOptions
  
  var body: some View {
    VStack {
      HStack {
        Text("Location Data")
          .font(viewOptions.sectionHeaderFont)
          .foregroundColor(viewOptions.appRedColor)
        Spacer()
      }
      HStack {
        Text("LST: " + Hms(lstDeg).string(viewOptions.showDmsHms))
        Spacer()
        let latString = Dms(locData.latitudeDeg).string(viewOptions.showDmsHms)
        Text("Lat:" + latString)
        Spacer()
        let longString = Dms(locData.longitudeDeg).string(viewOptions.showDmsHms)
        Text("Lng:" + longString)
      }
      .font(viewOptions.smallValueFont)
//      .foregroundColor(lstValidColor())
    }
  }

}



struct LocationDataView_Previews: PreviewProvider {
  static var previews: some View {
    LocationDataView(locData: LocationData(),
                     lstDeg: 0.0)
  }
}
