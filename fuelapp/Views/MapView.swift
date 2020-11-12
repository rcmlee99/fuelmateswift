//
//  MapView.swift
//  fuelapp
//
//  Created by Roger Lee on 8/7/20.
//  Copyright © 2020 JR Lee Pty Ltd. All rights reserved.
//

import SwiftUI
import MapKit
import Combine

class CustomPointAnnotation: MKPointAnnotation {
    var imageName: String = ""
    var price: Float = 0.0
    var station: StationData
        
    init(station: StationData) {
        self.station = station
    }
}

class MapViewCoordinator: NSObject, MKMapViewDelegate {
    var parent: MapView
    var cancellable = Set<AnyCancellable>()
    
    init(_ parent: MapView) {
        self.parent = parent
    }
        
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !annotation.isKind(of: MKUserLocation.self) else {
            // Make a fast exit if the annotation is the `MKUserLocation`, as it's not an annotation view we wish to customize.
            return nil
        }
        
        var annotationView: MKAnnotationView?
        
        if let annotation = annotation as? CustomPointAnnotation {
            annotationView = setupFuelStation(for: annotation, on: mapView)
        }
        return annotationView
    }
    
    private func setupFuelStation (for annotation: MKPointAnnotation, on mapView: MKMapView) -> MKAnnotationView {
        
        let pin = annotation as! CustomPointAnnotation
        let imageName = "stnicon_" + pin.imageName.lowercased().addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        let newImageSize = CGSize(width: 54, height: 54)
        let newView = UIView.init(frame: CGRect(x: 0, y: 0, width: 54, height: 54))
        newView.backgroundColor = .clear
        let newLabel = UILabel.init(frame: CGRect(x: 9, y: 3, width: 38, height: 18))
        newLabel.textColor = .white
        newLabel.adjustsFontSizeToFitWidth = true
        newLabel.font = .boldSystemFont(ofSize: 14)
        newLabel.textAlignment = .center
        
        let pinImageView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 54, height: 54))
        pinImageView.image = UIImage(named: "pin_blue.png")
        newLabel.text = "\(pin.price)"
        newView.addSubview(pinImageView)
        newView.addSubview(newLabel)
        
        let newImageView = UIImageView.init(frame: CGRect(x: 17, y: 21, width: 20, height: 20))
        newImageView.image = UIImage(named: imageName)
        newView.addSubview(newImageView)
        
        UIGraphicsBeginImageContextWithOptions(newImageSize, false, 0.0)
        newView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "customView")
        annotationView.canShowCallout = true
        annotationView.image = newImage
        annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        return annotationView
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        parent.isSelected = true
        parent.selectedAnnotation = view.annotation as? CustomPointAnnotation
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if !animated {
            nearbyStation(mapView)
        }
    }
    
    func nearbyStation(_ mapView: MKMapView) {
        mapView.removeAnnotations(mapView.annotations)
        parent.isLoading = true
        print("region changed make api call")
        parent.centerCoordinate = mapView.centerCoordinate
        FuelService().getNearbyStations(mapView.centerCoordinate)
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { completion in
            self.parent.isLoading = false
            switch completion {
            case .finished:
                break
            case .failure(let error):
                self.parent.showAlert = true
                self.parent.message = "Error in API Call"
                print("Error ! Error ! :::")
                print(error)
                print(error.localizedDescription)
            }
        }, receiveValue: { NearbyStation in

            NearbyStation.stations.forEach { station in
                let info = CustomPointAnnotation(station: station)
                info.coordinate = CLLocationCoordinate2DMake(station.location.latitude, station.location.longitude)
                info.imageName = station.brand
                info.title = station.brand
                info.subtitle = station.address
                let fuelprice = NearbyStation.prices.filter { $0.stationcode == station.code }
                info.price = fuelprice[0].price
                mapView.addAnnotation(info)
            }
        })
        .store(in: &cancellable)
    }
}

struct MapView: UIViewRepresentable {

    var centerCoordinate: CLLocationCoordinate2D
    @Binding var isSelected: Bool
    @Binding var selectedAnnotation: CustomPointAnnotation?
    @Binding var isLoading: Bool
    @Binding var showAlert: Bool
    @Binding var refreshView: Bool
    @Binding var message: String
    @ObservedObject var locationManager = LocationManager()
    
    init(centerCoordinate: CLLocationCoordinate2D, isSelected: Binding<Bool> = .constant(true), selectedAnnotation: Binding<CustomPointAnnotation?>, isLoading: Binding<Bool> = .constant(false), showAlert: Binding<Bool> = .constant(false), message: Binding<String>, refreshView: Binding<Bool> = .constant(false)) {
        _isSelected = isSelected
        _selectedAnnotation = selectedAnnotation
        self.centerCoordinate = centerCoordinate
        _isLoading = isLoading
        _showAlert = showAlert
        _message = message
        _refreshView = refreshView
   }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: locationManager.location?.coordinate ?? centerCoordinate, span: span)
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
        
        return mapView
    }

    func makeCoordinator() -> MapViewCoordinator{
        MapViewCoordinator(self)
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        if (refreshView) {
            print("UpdateUI")
            context.coordinator.nearbyStation(uiView)
            refreshView = false
        }
    }
}
