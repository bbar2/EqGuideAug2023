//
//  AppData.swift
//  SiderealTime
//
//  Created by Barry Bryant on 4/18/22.
//
//  Include this in the model.
//  Read current location from longitudeDeg and latitudeDeg computed vars.
//   if nil - Location Manager has not updated the location
//

import Foundation
import CoreLocation

class LocationData : NSObject, ObservableObject, CLLocationManagerDelegate{
  
  @Published private var coordinateDeg : CLLocationCoordinate2D?

  // TODO - should these be @Published, or should coordinateDeg be @Published
  var longitudeDeg : Double? {
    get {
      return coordinateDeg?.longitude
    }
  }
  
  var latitudeDeg : Double? {
    get {
      return coordinateDeg?.latitude
    }
  }

  let locationManager = CLLocationManager()

  override init() {
    super.init()

    CLLocationManager().requestWhenInUseAuthorization()
    locationManager.delegate = self
    locationManager.startUpdatingLocation()
    
    // init to last location reported, or nil of none
    // Will be updated by ...didUpdateLocations delegate func below.
    coordinateDeg = locationManager.location?.coordinate
  }
  
  deinit {
    locationManager.stopUpdatingLocation()
  }
  
  // CLLocationManagerDelegate called in response to startUpdatingLocation()
  func locationManager(_ manager: CLLocationManager,
                       didUpdateLocations locations:[CLLocation]) {
    if let location = locations.first {
      coordinateDeg = location.coordinate
    }
  }
  
  func locationManager(_ manager: CLLocationManager,
                       didFailWithError error: Error) {
    print("Location Manager Error")
  }
  
}
