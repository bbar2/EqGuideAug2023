//
//  LocationOptionView.swift
//  EqGuide
//
//  Created by Barry Bryant on 9/1/23.
//

import SwiftUI

struct LocationOptionSheet: View {
  @ObservedObject var locData: LocationData

  @EnvironmentObject var viewOptions: ViewOptions

  @Environment(\.dismiss) private var dismiss
  
  @State var useAltTime = false
  @State var altTime = Date.now
  
  var body: some View {
    VStack {
      
      VStack {
        Text("Local Coordinate").font(viewOptions.appHeaderFont)
        Text("Manual Entry").font(viewOptions.appHeaderFont)
        HStack {
          Spacer()
          DegreeFormatControl()
        }
      }
      
      VStack {
        
        Divider()
        Text("Phone GPS Local Coordinates\n").font(.title2)//.bold()
        if let coord = locData.reportedCoord {
          HStack {
            Text("Lat:" + Dms(coord.latitude).string(viewOptions.showDmsHms))
            Spacer()
            Text("Lng:" + Dms(coord.longitude).string(viewOptions.showDmsHms))
          }.font(viewOptions.bigValueFont)
        } else {
          Text("NO Phone GPS Location Data")
        }
        Divider()

        
        Text("Alternate Local Coordinates").font(.title2)//.bold()
        VStack {
          if viewOptions.showDmsHms {
            DmInputView(decimalDegrees: $locData.altLatDeg, prefix: "Alt Lat")
            DmInputView(decimalDegrees: $locData.altLonDeg, prefix: "Alt Lon")
          } else {
            DoubleInputView(doubleValue: $locData.altLatDeg, prefix: "Alt Lat")
            DoubleInputView(doubleValue: $locData.altLonDeg, prefix: "Alt Lon")
          }
        }
        Toggle(isOn: $locData.useAltLocation) {
          Text("Use Alternate Local Coordinates")
        }
        Divider()
      }
      
      Spacer()
      Button {
        dismiss()
      } label: {
        Text("OK").font(viewOptions.appHeaderFont)
      }
      Spacer()
      
    }
  }
}

struct LocationOptionSheet_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      LocationOptionSheet(locData: LocationData())
    }
  }
}




