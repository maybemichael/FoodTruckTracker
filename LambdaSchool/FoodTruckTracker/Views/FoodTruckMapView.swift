//
//  FoodTruckMapView.swift
//  FoodTruckTracker
//
//  Created by Michael on 3/17/20.
//  Copyright © 2020 Michael. All rights reserved.
//

import UIKit
import Contacts
import MapKit

class FoodTruckMapView: UIView {

    var foodTruck: TruckRepresentation? {
        didSet {
            updateSubviews()
        }
    }
    
    var truckAddress: CNPostalAddress?
    
    var delegate: DetailViewDelegate?
    
    private let truckRatingLabel = UILabel()
    private let cuisineTypeLabel = UILabel()
    private let addressLabel = UILabel()
    private let imageView = UIImageView()
    private let truckDetailButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let detailStackView = UIStackView(arrangedSubviews: [cuisineTypeLabel, truckRatingLabel])
        detailStackView.translatesAutoresizingMaskIntoConstraints = false
        detailStackView.spacing = UIStackView.spacingUseSystem
        detailStackView.axis = .vertical
        detailStackView.widthAnchor.constraint(equalToConstant: 120).isActive = true

        let buttonStackView = UIStackView(arrangedSubviews: [detailStackView, truckDetailButton])
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        buttonStackView.spacing = UIStackView.spacingUseSystem
        buttonStackView.axis = .horizontal
         
        let imageViewStackView = UIStackView(arrangedSubviews: [imageView])
        
        imageViewStackView.translatesAutoresizingMaskIntoConstraints = false
        imageViewStackView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        imageViewStackView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        let mainStackView = UIStackView(arrangedSubviews: [imageViewStackView, buttonStackView])
        mainStackView.spacing = UIStackView.spacingUseSystem
        mainStackView.axis = .vertical
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(mainStackView)
        mainStackView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        mainStackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        mainStackView.topAnchor.constraint(equalTo: topAnchor).isActive = true

        truckDetailButton.addTarget(self, action: #selector(truckDetailButtonTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    @objc func truckDetailButtonTapped() {
        guard let truck = foodTruck else { return }
        let truckDict: [String : TruckRepresentation] = [truckDetail: truck]
        NotificationCenter.default.post(name: .detailRequested, object: nil, userInfo: truckDict)
        NotificationCenter.default.post(name: .performSegue, object: nil)
    }
    
    func updateSubviews() {
        guard let foodTruck = foodTruck, let imageURL = foodTruck.image else { return }
        cuisineTypeLabel.text = "Cuisine Type: \(foodTruck.cuisineType)"
        cuisineTypeLabel.adjustsFontSizeToFitWidth = true
        cuisineTypeLabel.font = UIFont.systemFont(ofSize: 12)
        let total = foodTruck.customerRatings.reduce(0, +)
        let count = Double(foodTruck.customerRatings.count)
        let starRating = total / count
        let roundedValue = (starRating * 100).rounded() / 100
        truckRatingLabel.text = "Avg Rating: \(roundedValue) ★'s"
        truckRatingLabel.font = UIFont.systemFont(ofSize: 12)
        truckRatingLabel.adjustsFontSizeToFitWidth = true
        if let data = try? Data(contentsOf: imageURL) {
            imageView.image = UIImage(data: data)
        }
        truckDetailButton.setImage(UIImage(systemName: "info.circle.fill"), for: .normal)
    }
    
    func getPhysicalAddress(latitude: Double, longitude: Double, completion: @escaping (_ placemark: [CLPlacemark]?, _ error: Error?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude)) { (placemarks, error) in
            if let error = error {
                NSLog("Error getting physical address: \(error)")
                completion(nil, error)
                return
            }
            guard let placemark = placemarks?[0] else {
                NSLog("Bad placemark data")
                completion(nil, error)
                return
            }
            let address = placemark.postalAddress
            self.truckAddress = address
            NSLog("\(String(describing: address))")
            completion(placemarks, nil)
        }
    }
}
