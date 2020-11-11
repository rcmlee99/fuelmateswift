//
//  FuelBrandListView.swift
//  fuelapp
//
//  Created by Roger Lee on 8/7/20.
//  Copyright © 2020 JR Lee Pty Ltd. All rights reserved.
//

import SwiftUI

struct FuelBrandListView: View {
    @EnvironmentObject private var fuelData: FuelService
    
    var body: some View {
        NavigationView {
            List {
                ForEach(fuelData.fuelBrands, id: \.self ) { fuelBrands in
                    
                    FuelBrandRowView(withName: fuelBrands)
                }
            }
            .navigationBarTitle(Text("Fuel Brand"))
        }
    }
}

struct FuelBrandListView_Previews: PreviewProvider {
    static var previews: some View {
        FuelBrandListView().environmentObject(FuelService())
            .environmentObject(UserData())
    }
}
