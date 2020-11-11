//
//  LocationManager.swift
//  landmarknotes
//
//  Created by Roger Lee on 9/11/20.
//  Copyright © 2020 JR Lee. All rights reserved.
//

import Foundation
import Combine
import CoreLocation

class LocationManager: NSObject, ObservableObject {
  private let locationManager = CLLocationManager()
  let objectWillChange = PassthroughSubject<Void, Never>()
  private let geocoder = CLGeocoder()

  @Published var status: CLAuthorizationStatus? {
    willSet { update() }
  }

  @Published var location: CLLocation? {
    willSet { update() }
  }
    
  @Published var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0,0) {
    willSet { update() }
  }
    
  @Published var placemark: CLPlacemark? {
    willSet { update() }
  }
    
  func update() {
    objectWillChange.send()
  }

  override init() {
    super.init()
    self.locationManager.delegate = self
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    self.locationManager.showsBackgroundLocationIndicator = true
    getLocation()
  }
    
  private func geocode() {
    guard let location = self.location else { return }
    geocoder.reverseGeocodeLocation(location, completionHandler: { (places, error) in
      if error == nil {
        self.placemark = places?[0]
      } else {
        self.placemark = nil
      }
    })
  }
}

extension CLLocation {
    var latitude: Double {
        return self.coordinate.latitude
    }
    
    var longitude: Double {
        return self.coordinate.longitude
    }
}

extension LocationManager: CLLocationManagerDelegate {

    func requestWhenInUseAuthorization() {
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func getLocation() {
        if CLLocationManager.authorizationStatus() == .notDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        } else if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.status = status
        if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            self.locationManager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        if let coordinate = locationManager.location?.coordinate {
            self.coordinate = coordinate
        }
        // self.geocode()
    }
}
