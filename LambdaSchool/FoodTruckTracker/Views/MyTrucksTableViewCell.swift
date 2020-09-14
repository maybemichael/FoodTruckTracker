//
//  MyTrucksTableViewCell.swift
//  FoodTruckTracker
//
//  Created by Michael on 3/7/20.
//  Copyright © 2020 Michael. All rights reserved.
//

import UIKit
import FirebaseFirestore

class MyTrucksTableViewCell: UITableViewCell {
    
    var truck: Truck? {
        didSet {
            updateViews()
        }
    }
    
    @IBOutlet weak var truckNameLabel: UILabel!
    @IBOutlet weak var truckImageView: UIImageView!
    @IBOutlet weak var truckCuisineType: UILabel!
    @IBOutlet weak var averageRatingLabel: UILabel!
    

    func updateViews() {
        guard let truck = truck, let urlString = truck.image, let url = URL(string: urlString), let ratings = truck.customerRatings else { return }
        
        truckNameLabel.text = truck.name
        truckCuisineType.text = truck.cuisineType
        let total = ratings.reduce(0, +)
        let count = Double(ratings.count)
        let starRating = total / count
        let roundedValue = (starRating * 100).rounded() / 100
        averageRatingLabel.text = "\(roundedValue) ★'s"
        
        
//        if let data = try? Data(contentsOf: url) {
//            DispatchQueue.main.async {
//                self.truckImageView.image = UIImage(data: data)
//            }
//        }
    }
}
