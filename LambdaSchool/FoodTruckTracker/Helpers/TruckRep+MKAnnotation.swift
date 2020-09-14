//
//  TruckRep+MKAnnotation.swift
//  FoodTruckTracker
//
//  Created by Michael on 3/15/20.
//  Copyright © 2020 Michael. All rights reserved.
//

import Foundation
import MapKit

extension TruckRepresentation: MKAnnotation {
    
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    public var title: String? {
        name
    }
    
    public var subtitle: String? {
        cuisineType
    }
}
