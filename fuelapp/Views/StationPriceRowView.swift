//
//  StationPriceRowView.swift
//  fuelapp
//
//  Created by Roger Lee on 14/7/20.
//  Copyright © 2020 JR Lee Pty Ltd. All rights reserved.
//

import SwiftUI

struct StationPriceRowView: View {
    var fuelprice : StationFuelPrices
    
    var body: some View {
        HStack {
            Text(fuelprice.fueltype)
                .font(.body)
                .fontWeight(.bold)
            Spacer()
            Text("\(fuelprice.price, specifier: "%.1f")")
                .font(.body)
            }.padding()
    }
}

struct StationPriceRowView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StationPriceRowView(fuelprice: StationPricesData.prices[0])
            StationPriceRowView(fuelprice: StationPricesData.prices[1])
            StationPriceRowView(fuelprice: StationPricesData.prices[2])
        }
        .previewLayout(.fixed(width: 300, height: 70))
        
    }
}
