//
//  TruckRepresentation.swift
//  FoodTruckTracker
//
//  Created by Michael on 3/7/20.
//  Copyright © 2020 Michael. All rights reserved.
//

import Foundation
import MapKit

class TruckRepresentation: NSObject, Codable {
    let id: UUID
    let name: String
    var image: URL?
    var cuisineType: String
    var latitude: Double
    var longitude: Double
//    var address: String
    var customerRatings: [Double]
    var menu: [MenuItemRepresentation]?
    
    enum TruckKeys: String, CodingKey {
        case id
        case name
        case image
        case cuisineType
        case latitude
        case longitude
        case customerRatings
        case menu
    }
    
    init(id: UUID, name: String, image: URL?, cuisineType: String, latitude: Double, longitude: Double, customerRatings: [Double], menu: [MenuItemRepresentation]?) {
        
        self.id = id
        self.name = name
        self.image = image
        self.cuisineType = cuisineType
        self.latitude = latitude
        self.longitude = longitude
//        self.address = address
        self.customerRatings = customerRatings
        self.menu = menu
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TruckKeys.self)
        
        let id = try container.decode(UUID.self, forKey: .id)
        let name = try container.decode(String.self, forKey: .name)
        let image = try container.decode(URL.self, forKey: .image)
        let cuisineType = try container.decode(String.self, forKey: .cuisineType)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        
        var ratingsArray: [Double] = []
        var ratingsContainer = try container.nestedUnkeyedContainer(forKey: .customerRatings)
        
        while ratingsContainer.isAtEnd == false {
            let ratings = try ratingsContainer.decode(Double.self)
            ratingsArray.append(ratings)
        }
        
//        var menu = [MenuItemRepresentation]()
//        if container.contains(.menu) {
//            var menuContainer = try container.nestedUnkeyedContainer(forKey: .menu)
//
//            while !menuContainer.isAtEnd {
//                let menuItem = try menuContainer.decode(MenuItemRepresentation.self)
//                menu.append(menuItem)
//            }
//        }
        
        let menu = try container.decode([MenuItemRepresentation].self, forKey: .menu)
        
//        if let menu = try menuContainer.decodeIfPresent([String : MenuItemRepresentation].self, forKey: <#TruckRepresentation.TruckKeys#>) {
//            self.menu = Array(menu.values)
//        } else {
//            self.menu = []
//        }
        self.id = id
        self.name = name
        self.image = image
        self.cuisineType = cuisineType
        self.latitude = latitude
        self.longitude = longitude
        self.customerRatings = ratingsArray
        self.menu = menu
    }
    
//    struct MenuItemRepresentation: Codable {
//        var name: String
//        var price: Double
//        var description: String
//        var id: UUID
//        var image: URL?
//        var customerRatings: [Double]?
//
//        enum MenuKeys: String, CodingKey {
//            case name
//            case price
//            case description
//            case id
//            case image
//            case customerRatings
//        }
//
//        init(name: String, price: Double, description: String, id: UUID, image: URL?, customerRatings: [Double]?) {
//            self.name = name
//            self.price = price
//            self.description = description
//            self.id = id
//            self.image = image
//            self.customerRatings = customerRatings
//        }
//
//        init(from decoder: Decoder) throws {
//            let container = try decoder.container(keyedBy: MenuKeys.self)
//
//            let name = try container.decode(String.self, forKey: .name)
//            let price = try container.decode(Double.self, forKey: .price)
//            let description = try container.decode(String.self, forKey: .description)
//            let id = try container.decode(UUID.self, forKey: .id)
//            let image = try container.decode(URL.self, forKey: .image)
//
//            var ratingsArray: [Double] = []
//            var ratingsContainer = try container.nestedUnkeyedContainer(forKey: .customerRatings)
//
//            while ratingsContainer.isAtEnd == false {
//                let ratings = try ratingsContainer.decode(Double.self)
//                ratingsArray.append(ratings)
//            }
//
//            self.name = name
//            self.price = price
//            self.description = description
//            self.id = id
//            self.image = image
//            self.customerRatings = ratingsArray
//        }
//    }
}

