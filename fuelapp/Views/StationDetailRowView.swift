//
//  StationDetailRowView.swift
//  fuelapp
//
//  Created by Roger Lee on 14/7/20.
//  Copyright © 2020 JR Lee Pty Ltd. All rights reserved.
//

import SwiftUI

struct StationDetailRowView: View {
    var station: StationData
    private var imageName: String
    @State private var favouriteStations: [Int] = UserDefaults.standard.array(forKey: "favouriteStations") as? [Int] ?? []
    
    init(station:StationData) {
        let escapeString = "stnicon_" + station.brand.lowercased().addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        self.imageName = escapeString
        self.station = station
    }
    
    func appendFavourite() {
        if favouriteStations.contains(station.code) {
            favouriteStations.removeAll{$0 == station.code}
        } else {
            favouriteStations.append(station.code)
        }
        UserDefaults.standard.set(favouriteStations, forKey: "favouriteStations")
        
        print(favouriteStations)
    }
    
    var body: some View {
        HStack {
            Image(imageName)
                .resizable()
                .frame(width: 50, height: 50)
            VStack(alignment: .leading) {
                Text(station.name)
                    .font(.body)
                Text(station.address)
                    .font(.caption)
                    .fixedSize(horizontal: false, vertical: true)

            }
            Spacer()
            Button(action: {
                self.appendFavourite()
            }) {
                if favouriteStations.contains(station.code) {
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

struct StationDetailRowView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StationDetailRowView(station: PriceByNearbyStation.stations[0])
            StationDetailRowView(station: PriceByNearbyStation.stations[1])
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}

