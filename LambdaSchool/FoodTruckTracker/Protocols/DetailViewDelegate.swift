//
//  DetailViewDelegate.swift
//  FoodTruckTracker
//
//  Created by Michael on 3/23/20.
//  Copyright © 2020 Michael. All rights reserved.
//

import Foundation

protocol DetailViewDelegate: AnyObject {
    func selectedTruckDetail(truck: TruckRepresentation)
}
