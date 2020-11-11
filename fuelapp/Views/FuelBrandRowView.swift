//
//  FuelStationBrandRowView.swift
//  fuelapp
//
//  Created by Roger Lee on 8/7/20.
//  Copyright © 2020 JR Lee Pty Ltd. All rights reserved.
//

import SwiftUI

struct FuelBrandRowView: View {
    @State private var imageName: String
    @State private var fuelBrand: String
    @EnvironmentObject private var userData: UserData
    private let userDefault = UserDefaults.standard
    
    init(withName fuelBrand:FuelBrand) {
        let escapeString = "stnicon_" + fuelBrand.name.lowercased().addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        _imageName = State(initialValue: escapeString)
        _fuelBrand = State(initialValue: fuelBrand.name)
    }
    
    func addRemoveFavourite() {
        if userData.favouriteBrands.contains(fuelBrand) {
            userData.favouriteBrands.removeAll{$0 == fuelBrand}
        } else {
            userData.favouriteBrands.append(fuelBrand)
        }
        userDefault.set(userData.favouriteBrands, forKey: "favouriteBrands")
        print(userData.favouriteBrands)
    }
    
    var body: some View {
        HStack {
            Image(imageName)
                .resizable()
                .frame(width: 50, height: 50)
            Text(fuelBrand)
                .font(.body)
            Spacer()
            Button(action: {
                self.addRemoveFavourite()
            }) {
               
                if userData.favouriteBrands.contains(fuelBrand) {
                    Image(systemName: "star.fill")
                        .imageScale(.medium)
                        .foregroundColor(.yellow)
                } else {
                    Image(systemName: "star")
                        .imageScale(.medium)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
    }
}

struct FuelBrandRowView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FuelBrandRowView(withName: FuelRefData.brands.items[0]).environmentObject(UserData())
            FuelBrandRowView(withName: FuelRefData.brands.items[1]).environmentObject(UserData())
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
