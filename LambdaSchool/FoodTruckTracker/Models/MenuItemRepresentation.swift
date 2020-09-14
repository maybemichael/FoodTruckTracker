//
//  MenuItemRepresentation.swift
//  FoodTruckTracker
//
//  Created by Michael on 3/7/20.
//  Copyright © 2020 Michael. All rights reserved.
//

import Foundation

struct MenuItemRepresentation: Codable {
    var name: String
    var price: Double
    var description: String
    var id: UUID
    var image: URL?
    var customerRatings: [Double]?
    
    enum MenuKeys: String, CodingKey {
        case name
        case price
        case description
        case id
        case image
        case customerRatings
    }
}
