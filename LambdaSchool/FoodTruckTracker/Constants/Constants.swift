//
//  Constants.swift
//  FoodTruckTracker
//
//  Created by Michael on 3/8/20.
//  Copyright © 2020 Michael. All rights reserved.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}

enum Choice: String {
    case foodTruckOperator
    case foodie
}

let truckDetail = "truckDetail"
let performSegue = "performSegue"
