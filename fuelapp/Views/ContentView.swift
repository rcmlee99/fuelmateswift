//
//  ContentView.swift
//  fuelapp
//
//  Created by Roger Lee on 8/7/20.
//  Copyright © 2020 JR Lee Pty Ltd. All rights reserved.
//

import SwiftUI
import MapKit
import CoreLocation

struct ContentView: View {
    @State private var selection = 2
    @State private var image: Image?
    
    // Default center location
    @State var centerCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(-33.87563, 151.204841)
    
    var body: some View {
        TabView(selection: $selection){
            FuelBrandListView()
                .font(.title)
                .tabItem {
                    VStack {
                        Image(systemName: "flame")
                        Text("Brand")
                    }
                }
                .tag(0)
            FuelTypeListView()
                .font(.title)
                .tabItem {
                    VStack {
                        Image(systemName: "car")
                        Text("FuelType")
                    }
                }
                .tag(1)
            MapStationView(centerCoordinate: centerCoordinate)
                .font(.title)
                .tabItem {
                    VStack {
                        Image(systemName: "map")
                        Text("Map")
                    }
                }
                .tag(2)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(UserData())
    }
}
