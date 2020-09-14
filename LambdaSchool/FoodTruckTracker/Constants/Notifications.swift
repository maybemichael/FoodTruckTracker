//
//  Notifications.swift
//  FoodTruckTracker
//
//  Created by Michael on 3/22/20.
//  Copyright © 2020 Michael. All rights reserved.
//

import Foundation
enum MyNotifications: String {
    case detailRequested = "detailRequested"
    case performSegue = "performSegue"
}

extension NSNotification.Name {
    static let detailRequested = NSNotification.Name("detailRequested")
    static let performSegue = NSNotification.Name("performSegue")
}
