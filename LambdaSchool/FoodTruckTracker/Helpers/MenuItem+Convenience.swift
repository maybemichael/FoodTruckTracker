//
//  MenuItem+Convenience.swift
//  FoodTruckTracker
//
//  Created by Michael on 3/7/20.
//  Copyright © 2020 Michael. All rights reserved.
//

import Foundation
import CoreData

extension MenuItem {
    
    var menuItemRepresentation: MenuItemRepresentation? {
        
        guard
            let id = identifier,
            let name = name,
            let dishDescription = dishDescription,
            let image = image
            else { return nil }
        
        return MenuItemRepresentation(name: name, price: price, description: dishDescription, id: id, image: URL(string: image), customerRatings: dishRatings)
    }
    
    @discardableResult convenience init?(id: UUID,
                                        name: String,
                                        description: String,
                                        price: Double,
                                        image: String?,
                                        dishRatings: [Double]? = [5],
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(context: context)
        self.identifier = id
        self.name = name
        self.dishDescription = description
        self.price = price
        self.image = image
        self.dishRatings = dishRatings
    }
    
    @discardableResult convenience init?(menuItemRepresentation: MenuItemRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(id: menuItemRepresentation.id,
                  name: menuItemRepresentation.name,
                  description: menuItemRepresentation.description,
                  price: menuItemRepresentation.price,
                  image: menuItemRepresentation.image?.absoluteString,
                  dishRatings: menuItemRepresentation.customerRatings,
                  context: context)
    }
}
