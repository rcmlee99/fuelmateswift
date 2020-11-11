//
//  ApiFuelCheck.swift
//  fuelapp
//
//  Created by Roger Lee on 10/7/20.
//  Copyright © 2020 JR Lee Pty Ltd. All rights reserved.
//

import Foundation
import Combine
import CoreLocation

class FuelService: ObservableObject {
    private let session: URLSession
    private var accessToken: String?
    private let apiKey = Bundle.main.object(forInfoDictionaryKey: "apiKey") as? String
    private let apiSecret = Bundle.main.object(forInfoDictionaryKey: "apiSecret") as? String
    
    @Published var fuelBrands = FuelRefData.brands.items
    @Published var fuelTypes = FuelRefData.fueltypes.items
    
    init(session: URLSession = .shared) {
        self.session = session
        guard let _ = apiKey else {
            fatalError("Couldn't read apiKey in Info.plist")
        }
        guard let _ = apiSecret else {
            fatalError("Couldn't read apiSecret in Info.plist")
        }
    }
    
    func validate(_ data: Data, _ response: URLResponse) throws -> Data {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw APIError.statusCode(httpResponse.statusCode)
        }
        return data
    }
     
    func getNearbyStations(_ location: CLLocationCoordinate2D) -> AnyPublisher<NearbyStation, Error> {
        return getToken()
            .tryMap { output in
                return output.access_token
            }
            .flatMap { token in
                return self.postPriceNearby(token, location: location)
            }
            .eraseToAnyPublisher()
    }
    
    func getStationDetail(_ stationCode: String) -> AnyPublisher<StationPrices, Error>  {
        return getToken()
            .tryMap { output in
                return output.access_token
            }
            .flatMap { token in
                return self.getPriceByStationCode(token, stationCode: stationCode)
            }
            .eraseToAnyPublisher()

    }
    
    func getToken() -> AnyPublisher<Credentials, Error> {
        let url = URL(string: "https://api.onegov.nsw.gov.au/oauth/client_credential/accesstoken?grant_type=client_credentials")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Basic \(apiSecret!)", forHTTPHeaderField: "Authorization")
        
        return session.dataTaskPublisher(for: request)
            .tryMap{ try self.validate($0.data, $0.response) }
            .decode(type: Credentials.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func getRefData(_ token: String) -> AnyPublisher<FuelRef, Error> {
        let url = URL(string: "https://api.onegov.nsw.gov.au/FuelCheckRefData/v1/fuel/lovs")!
        var request = buildRequest(url, accessToken: token)
        request.httpMethod = "GET"
        
        return session.dataTaskPublisher(for: request)
            .tryMap{ try self.validate($0.data, $0.response) }
            .decode(type: FuelRef.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func getPriceByStationCode(_ token: String, stationCode: String) -> AnyPublisher<StationPrices, Error> {
        let url = URL(string: "https://api.onegov.nsw.gov.au/FuelPriceCheck/v1/fuel/prices/station/\(stationCode)")!
        var request = self.buildRequest(url, accessToken: token)
        request.httpMethod = "GET"
        
        return session.dataTaskPublisher(for: request)
            .tryMap{ try self.validate($0.data, $0.response) }
            .decode(type: StationPrices.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func postPriceNearby(_ token: String, location: CLLocationCoordinate2D) -> AnyPublisher<NearbyStation, Error> {
        let favouriteFuelTypes = UserDefaults.standard.array(forKey: "favouriteFuelTypes") as? [String] ?? []
        let favouriteBrands = UserDefaults.standard.array(forKey: "favouriteBrands") as? [String] ?? []
        print(favouriteFuelTypes)
        let json: [String: Any] = [
          "fueltype": favouriteFuelTypes.first ?? "P95",
          "brand": favouriteBrands,
          "namedlocation": "2217",
          "latitude": location.latitude,
          "longitude": location.longitude,
          "radius": "5",
          "sortby": "price",
          "sortascending": "true"
        ]
        print(json)
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        let url = URL(string: "https://api.onegov.nsw.gov.au/FuelPriceCheck/v1/fuel/prices/nearby")!
        var request = self.buildRequest(url, accessToken: token)
        request.httpMethod = "POST"
        request.httpBody = jsonData
       
        return session.dataTaskPublisher(for: request)
        .tryMap{ try self.validate($0.data, $0.response) }
        .decode(type: NearbyStation.self, decoder: JSONDecoder())
        .eraseToAnyPublisher()
        
    }
    
    func buildRequest(_ url: URL, accessToken: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        request.setValue(UUID().uuidString, forHTTPHeaderField: "transactionid")
        request.setValue(getCurrentDateTime(), forHTTPHeaderField: "requesttimestamp")
        request.setValue("07/07/2001 00:00:00 AM", forHTTPHeaderField: "if-modified-since")
        return request
    }
    
    func getCurrentDateTime() -> String {
        let utcDateFormatter = DateFormatter()
        utcDateFormatter.dateFormat = "dd/MM/yyyy hh:mm:ss a"
        utcDateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let currentDateTime = utcDateFormatter.string(from: Date())
        print(currentDateTime)
        return currentDateTime
    }
}
