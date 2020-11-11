//
//  UserData.swift
//  fuelapp
//
//  Created by Roger Lee on 8/7/20.
//  Copyright © 2020 JR Lee Pty Ltd. All rights reserved.
//

import Combine
import SwiftUI

final class UserData: ObservableObject {
    @Published var favouriteBrands: [String] = UserDefaults.standard.array(forKey: "favouriteBrands") as? [String] ?? []
    @Published var favouriteFuelTypes: [String] = UserDefaults.standard.array(forKey: "favouriteFuelTypes") as? [String] ?? []
}
