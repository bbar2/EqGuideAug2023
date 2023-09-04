//
//  LocationOptionView.swift
//  EqGuide
//
//  Created by Barry Bryant on 9/1/23.
//

import SwiftUI
import MapKit

// Make CLLocationCoordinate2D conform to Identifiable for the Marker.
extension CLLocationCoordinate2D: Identifiable {
  public var id: String {
    "\(latitude)-\(longitude)"
  }
}

struct LocationOptionSheet: View {
  @ObservedObject var locData: LocationData

  @EnvironmentObject var viewOptions: ViewOptions

  @State private var region = MKCoordinateRegion(
    center: CLLocationCoordinate2D(
      latitude: 0.0,
      longitude: 0.0),
    span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
  )

  @Environment(\.dismiss) private var dismiss
  
  @State var useAltTime = false
  @State var altTime = Date.now
  
  var body: some View {
    VStack {
      
      VStack {
        Text("Manual Entry").font(viewOptions.appHeaderFont)
        Text("Time and Location").font(viewOptions.appHeaderFont)
        HStack {
          Spacer()
          DegreeFormatControl()
        }
      }
      
      VStack {
//        let centerMark = CLLocationCoordinate2D(latitude: region.center.latitude,
//      longitude: region.center.longitude)
//        ZStack(alignment: .topLeading) {
//          Map(coordinateRegion: $region, annotationItems: [centerMark]) { mark in
//            MapAnnotation(coordinate: mark) {
//              Circle().stroke(Color.blue, lineWidth: 4.0)
//                .frame(width: 20, height: 20)
//            }
//          }.ignoresSafeArea()
//          Text("anchor here").padding()
//        }
        

        Divider()
        Text("Site Coordinates").font(.title2)
        
//        Text("Alt Longitude = \(region.center.longitude)º")
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
          Text("Use Manualy Entered Coordinates")
        }
        Divider()
      }
      
      VStack {
        Divider()
        DatePicker("Alternate Date", selection:  $altTime,
                   displayedComponents: [.date] )
        DatePicker("Alternate Local Time", selection: $altTime,
                   displayedComponents: [.hourAndMinute] )
        Toggle(isOn: $useAltTime) {
          Text("Use Alternate Time")
        }
        Divider()
      }
//      .padding([.bottom], 50)
      Spacer()
      Button {
        dismiss()
      } label: {
        Text("OK")
      }
      Spacer()
      
    }
//    .ignoresSafeArea()
    .onAppear() {
//      useAltLocation = locData.useAltLocation

      region.center.latitude = locData.altLatDeg
      region.center.longitude = locData.altLonDeg
//     useAltTime = mountModel.useAltTime
//      altTime = mountModel.altTime
    }
    .onDisappear() {
//      locData.useAltLocation = useAltLocation
//      mountModel.altLatDeg = region.center.latitude
//      mountModel.altLongDeg = region.center.longitude
//      mountModel.useAltTime = useAltTime
//      mountModel.altLatDeg = altLatDeg
//      mountModel.altLongDeg = altLonDeg
 //     mountModel.altTime = altTime
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




