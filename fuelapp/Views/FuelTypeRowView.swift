//
//  FuelTypeRowView.swift
//  fuelapp
//
//  Created by Roger Lee on 9/7/20.
//  Copyright © 2020 JR Lee Pty Ltd. All rights reserved.
//

import SwiftUI

struct FuelTypeRowView: View {
    @EnvironmentObject private var userData: UserData
    var fuelType: FuelType
    private let userDefault = UserDefaults.standard
    
    func appendFavourite() {
        if userData.favouriteFuelTypes.contains(fuelType.code) {
            userData.favouriteFuelTypes.removeAll{$0 == fuelType.code}
        } else {
            userData.favouriteFuelTypes.append(fuelType.code)
        }
        userDefault.set(userData.favouriteFuelTypes, forKey: "favouriteFuelTypes")
        print(userData.favouriteFuelTypes)
    }
    
    var body: some View {
        HStack {
            Text(fuelType.name)
                .font(.body)
            Spacer()
            Button(action: {
                self.appendFavourite()
            }) {
                if userData.favouriteFuelTypes.contains(fuelType.code) {
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

struct FuelTypeRowView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FuelTypeRowView(fuelType: FuelRefData.fueltypes.items[0]).environmentObject(UserData())
            FuelTypeRowView(fuelType: FuelRefData.fueltypes.items[1]).environmentObject(UserData())
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
