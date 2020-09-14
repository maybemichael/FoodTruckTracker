//
//  TruckMenuTableViewCell.swift
//  FoodTruckTracker
//
//  Created by Michael on 3/7/20.
//  Copyright © 2020 Michael. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Kingfisher

class TruckMenuTableViewCell: UITableViewCell {

    var menuItem: MenuItem? {
        didSet {
            updateViews()
        }
    }
    
    @IBOutlet weak var dishNameLabel: UILabel!
    @IBOutlet weak var dishImageView: UIImageView!
    @IBOutlet weak var dishDescriptionLabel: UILabel!
    @IBOutlet weak var averageRatingLabel: UILabel!
    

    func updateViews() {
        guard let menuItem = menuItem, let urlString = menuItem.image, let url = URL(string: urlString) else { return }
        dishNameLabel.text = menuItem.name
        dishDescriptionLabel.text = menuItem.dishDescription
        if let ratings = menuItem.dishRatings {
            let total = ratings.reduce(0, +)
            let count = Double(ratings.count)
            let starRating = total / count
            let roundedValue = (starRating * 100).rounded() / 100
            averageRatingLabel.text = "\(roundedValue) ★'s"
        }
        
//        let queue = DispatchQueue.global()
//        queue.async {
//            if let data = try? Data(contentsOf: url) {
//                DispatchQueue.main.async {
//                    self.dishImageView.image = UIImage(data: data)
//                }
//            }
//        }
    }
}
