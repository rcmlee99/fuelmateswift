//
//  StationView.swift
//  fuelapp
//
//  Created by Roger Lee on 14/7/20.
//  Copyright © 2020 JR Lee Pty Ltd. All rights reserved.
//

import SwiftUI
import CoreLocation
import Combine

struct StationDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedAnnotation: CustomPointAnnotation?
    @ObservedObject var pricesVM = StationDetailViewModel()
    
    init(selectedAnnotation:Binding<CustomPointAnnotation?>) {
        _selectedAnnotation = selectedAnnotation
    }

    var body: some View {
        NavigationView {
            VStack {
                StationDetailRowView(station: selectedAnnotation!.station)
                ForEach(pricesVM.prices, id: \.self ) { prices in
                    StationPriceRowView(fuelprice:prices)
                }
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                  Text("Dismiss")
                    .frame(minWidth: 0, maxWidth: 300)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    
                }.font(Font.system(size: 19, weight: .semibold))
                
                Spacer()
            }
            .navigationBarTitle(Text("Station Detail"))
            
        }.onAppear {
            self.pricesVM.priceByStationCode(self.selectedAnnotation!.station.code)
        }
    }
}

struct StationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        StatefulPreviewWrapper(CustomPointAnnotation(station: PriceByNearbyStation.stations[0])) { StationDetailView(selectedAnnotation: $0) }
    }
}

class StationDetailViewModel: ObservableObject {
    @Published var prices: [StationFuelPrices] = []
    var cancellable: AnyCancellable?
    
    func priceByStationCode(_ stationCode:Int) {
        cancellable = FuelService().getStationDetail(String(stationCode))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    fatalError(error.localizedDescription)
                }
            }, receiveValue: { stationprices in
                self.prices = stationprices.prices
            })
    }
}

// Wrapper preview that takes bindings as inputs
struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State var value: Value
    var content: (Binding<Value>) -> Content

    var body: some View {
        content($value)
    }

    init(_ value: Value, content: @escaping (Binding<Value>) -> Content) {
        self._value = State(wrappedValue: value)
        self.content = content
    }
}
