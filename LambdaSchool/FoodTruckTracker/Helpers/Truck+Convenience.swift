//
//  Truck+Convenience.swift
//  FoodTruckTracker
//
//  Created by Michael on 3/7/20.
//  Copyright © 2020 Michael. All rights reserved.
//

import Foundation
import CoreData

extension Truck {
    
    var truckRepresentation: TruckRepresentation? {
        
        guard
            let id = identifier,
            let name = name,
            let cuisineType = cuisineType,
            let customerRatings = customerRatings,
            let image = image
            else { return nil }
        
        var menuItemsArray = [MenuItemRepresentation]()
        
        if let menu = menuItem {
            for item in menu {
                if let menuItem = item as? MenuItem, let menuItemRep = menuItem.menuItemRepresentation {
                    menuItemsArray.append(menuItemRep)
                }
            }
        }
        
        return TruckRepresentation(id: id, name: name, image: URL(string: image), cuisineType: cuisineType, latitude: latitude, longitude: longitude, customerRatings: customerRatings, menu: menuItemsArray)
    }
    
    @discardableResult convenience init?(name: String,
                                        menu: NSSet?,
                                        image: String?,
                                        id: UUID,
                                        customerRatings: [Double]?,
                                        cuisineType: String,
                                        latitude: Double?,
                                        longitude: Double?,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(context: context)
        self.name = name
        self.image = image
        self.identifier = id
        self.customerRatings = customerRatings
        self.cuisineType = cuisineType
        self.latitude = latitude ?? 0
        self.longitude = longitude ?? 0
    }
    
    @discardableResult convenience init?(truckRepresentation: TruckRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        var items: [MenuItem] = []
        
        if let menuItemsRep = truckRepresentation.menu, menuItemsRep.count > 0 {
            for item in menuItemsRep {
                if let menuItem = MenuItem(menuItemRepresentation: item, context: context) {
                    items.append(menuItem)
                }
            }
        }
        
        var menuItemsSet: NSSet?
        
        if items.count > 0 {
            menuItemsSet = NSSet(array: items)
        }
        
        self.init(name: truckRepresentation.name,
                  menu: menuItemsSet,
                  image: truckRepresentation.image?.absoluteString,
                  id: truckRepresentation.id,
                  customerRatings: truckRepresentation.customerRatings,
                  cuisineType: truckRepresentation.cuisineType,
                  latitude: truckRepresentation.latitude,
                  longitude: truckRepresentation.longitude,
                  context: context)
    }
}
