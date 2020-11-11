//
//  FuelTypeListView.swift
//  fuelapp
//
//  Created by Roger Lee on 9/7/20.
//  Copyright © 2020 JR Lee Pty Ltd. All rights reserved.
//

import SwiftUI

struct FuelTypeListView: View {
    @EnvironmentObject private var fuelData: FuelService
    
    var body: some View {
        NavigationView {
            List {
                ForEach(fuelData.fuelTypes, id: \.self ) { fuelType in
                    FuelTypeRowView(fuelType: fuelType)
                }
            }
            .navigationBarTitle(Text("Fuel Type"))
        }
    }
}

struct FuelTypeListView_Previews: PreviewProvider {
    static var previews: some View {
        FuelTypeListView().environmentObject(FuelService())
            .environmentObject(UserData())
    }
}
