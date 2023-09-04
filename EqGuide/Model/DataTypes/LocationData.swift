//
//  LocationData.swift
//
//  Created by Barry Bryant on 4/18/22.
//
//  CLLocationManager updates GPS location.
//  Read current location from longitudeDeg and latitudeDeg computed vars.
//  Manual entry altLocation can be provided.
//  - altLocation good for testing, or when GPS (cell service) not available.
//  If no GPS and no useAltLocation selected, return 0.0
//  Use LocationKnowledge to color UI elements to indicate location confidence.

import CoreLocation

enum LocationKnowledge {
  case none       // assume nothing is valid
  case alt        // warn, useAltLocation true, assume valid alt location entered
  case gps        // CLLocationManager reporting Lattitude and Longitude
}

class LocationData : NSObject, ObservableObject, CLLocationManagerDelegate{
  
  // CLLocationCoordinate2D is simply two Doubles
  @Published private var coordDeg2D : CLLocationCoordinate2D?

  // allow LocationOptionSheet to access these
  @Published var useAltLocation = false
  @Published var altLonDeg = -76.4
  @Published var altLatDeg = 36.9
  
  private let cllManager = CLLocationManager()

  public var knowledge : LocationKnowledge {
    get {
      if useAltLocation {
        return .alt
      } else if let _ = coordDeg2D {
        return .gps
      } else {
        return .none
      }
    }
  }
  
  var longitudeDeg : Double {
    get {
      if useAltLocation {
        return altLonDeg
      }
      if let coord2D = coordDeg2D {
        return coord2D.longitude
      } else {
        return 0.0
      }
    }
  }
  
  var latitudeDeg : Double {
    get {
      if useAltLocation {
        return altLatDeg
      }
      if let coord2D = coordDeg2D {
        return coord2D.latitude
      } else {
        return 0.0
      }
    }
  }
  
  override init() {
    super.init()

    CLLocationManager().requestWhenInUseAuthorization()
    cllManager.delegate = self
    cllManager.startUpdatingLocation()
    
    // init to last location reported, or nil if none
    // Will be updated by ...didUpdateLocations delegate func below.
    coordDeg2D = cllManager.location?.coordinate
  }
  
  deinit {
    cllManager.stopUpdatingLocation()
  }
  
  // CLLocationManagerDelegate called in response to startUpdatingLocation()
  func locationManager(_ manager: CLLocationManager,
                       didUpdateLocations locations:[CLLocation]) {
    if let location = locations.first {
      coordDeg2D = location.coordinate
//      print("LocationManager.didUpdatelocation()")
    }
  }
  
  func locationManager(_ manager: CLLocationManager,
                       didFailWithError error: Error) {
    print("LocationManager.didFailWithError")
  }
  
}
