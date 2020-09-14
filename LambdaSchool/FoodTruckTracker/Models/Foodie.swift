//
//  Foodie.swift
//  FoodTruckTracker
//
//  Created by Michael on 3/6/20.
//  Copyright © 2020 Michael. All rights reserved.
//

import Foundation

struct Foodie: Codable {
    var username: String
    var password: String
    var email: String
    
    init(email: String, password: String) {
        self.username = email
        self.password = password
        self.email = email
    }
}

struct UserLogin: Codable {
    var username: String
    var password: String
}
