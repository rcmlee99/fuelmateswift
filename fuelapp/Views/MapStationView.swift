//
//  MapStationView.swift
//  fuelapp
//
//  Created by Roger Lee on 14/7/20.
//  Copyright © 2020 JR Lee Pty Ltd. All rights reserved.
//

import SwiftUI
import MapKit
import Combine

struct MapStationView: View {
    @State var isPresented: Bool = false
    @State var isLoading: Bool = false
    @State var showAlert: Bool = false
    @State var message: String = ""
    @State var selectedAnnotation: CustomPointAnnotation?
    @State var centerCoordinate: CLLocationCoordinate2D

    var body: some View {
        VStack(spacing: 30) {
            ActivityIndicatorView(isAnimating: isLoading).configure { $0.color = .red }
            MapView(centerCoordinate: centerCoordinate, isSelected: $isPresented, selectedAnnotation: $selectedAnnotation, isLoading: $isLoading, showAlert: $showAlert, message: $message)
        }.sheet(isPresented: $isPresented) {
            StationDetailView(selectedAnnotation: self.$selectedAnnotation)
        }.alert(isPresented: $showAlert) {
            Alert(title: Text(message))
        }
    }
}

struct MapStationView_Previews: PreviewProvider {
    static var previews: some View {
        MapStationView(centerCoordinate:CLLocationCoordinate2DMake(-33.87563, 151.204841))
    }
}
