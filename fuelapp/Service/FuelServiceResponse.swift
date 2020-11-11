//
//  FuelServiceResponse.swift
//  fuelapp
//
//  Created by Roger Lee on 10/11/20.
//  Copyright © 2020 JR Lee Pty Ltd. All rights reserved.
//

import Foundation

struct FuelBrand: Hashable, Codable {
    var name: String
}

struct FuelBrandItems: Hashable, Codable {
    var items: [FuelBrand]
}

struct FuelType: Hashable, Codable {
    var name: String
    var code: String
}

struct FuelTypeItems: Hashable, Codable {
    var items: [FuelType]
}

struct FuelRef: Hashable, Codable {
    var brands: FuelBrandItems
    var fueltypes: FuelTypeItems
}

struct Credentials: Codable {
    let access_token: String
    let client_id: String
}

struct FuelPrices: Hashable, Codable {
    var stationcode: Int
    var fueltype: String
    var price: Float
    var priceunit: String
    var lastupdated: String
}

struct StationFuelPrices: Hashable, Codable {
    var fueltype: String
    var price: Float
    var lastupdated: String
}


struct LocationData: Hashable, Codable {
    var latitude: Double
    var longitude: Double
    var distance: Float
}

extension LocationData {
    init(lat: Double, long: Double, dis: Float) {
        latitude = lat
        longitude = long
        distance = dis
    }
}

struct StationData: Hashable, Codable {
    var stationid: String
    var brandid: String
    var brand: String
    var code: Int
    var name: String
    var address: String
    var location: LocationData
}

extension StationData {
    init(stationid: String, brandid: String, brand: String, code: Int, name: String, address: String, location: LocationData?) {
        self.stationid = stationid
        self.brandid = stationid
        self.brand = brand
        self.code = code
        self.name = name
        self.address = address
        self.location = LocationData(lat: location?.latitude ?? 0.0, long: location?.longitude ?? 0.0, dis: location?.distance ?? 0.0)
    }
}

struct NearbyStation: Hashable, Codable {
    var stations: [StationData]
    var prices: [FuelPrices]
}

struct StationPrices: Hashable, Codable {
    var prices: [StationFuelPrices]
}
