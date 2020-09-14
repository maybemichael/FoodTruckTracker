//
//  FoodTruckDetailViewController.swift
//  FoodTruckTracker
//
//  Created by Michael on 3/9/20.
//  Copyright © 2020 Michael. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import FirebaseAuth

var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)

class FoodTruckDetailViewController: UIViewController {

    let geocoder = CLGeocoder()
    
    let ftc = FoodTruckController()
    
    var rating: Double?
    
    var handle: AuthStateDidChangeListenerHandle?
    
    var truckRep: TruckRepresentation? {
        didSet {
        
        }
    }
    
    @IBOutlet weak var truckNameLabel: UILabel!
    @IBOutlet weak var truckRatingLabel: UILabel!
    @IBOutlet weak var cuisineTypeLabel: UILabel!
    @IBOutlet weak var truckAddressLabel: UILabel!
    @IBOutlet weak var truckImageView: UIImageView!
    @IBOutlet var viewMenuButton: UIButton!
    @IBOutlet var starRatingControl: StarRatingControl!
    @IBOutlet var rateButton: UIButton!
    @IBOutlet var ratingLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: .detailRequested, object: nil, queue: nil) { (catchNotification) in
            guard let truckRep = catchNotification.userInfo?[truckDetail] as? TruckRepresentation else { return }
            self.truckRep = truckRep
        }
        starRatingControl.isHidden = false
        updateViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        handle = Auth.auth().addStateDidChangeListener({ _, _ in
            
        })
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    // MARK: - IBActions
    
    @IBAction func viewMenuTapped(_ sender: Any) {
        self.presentUserInfoAlert(title: "WARNING!", message: "Lords Mobile contains toxic people and chemicals knows to the state of California to cause Cancer!")
    }
    @IBAction func starRatingValueChanged(_ sender: StarRatingControl) {
        self.rating = Double(sender.value)
    }
   
    @IBAction func rateButtonTapped(_ sender: StarRatingControl) {
//        let rating = Double(sender.value)
        guard let uid = Auth.auth().currentUser?.uid, let truck = self.truckRep, let rating = self.rating else {
            print("No current user logged in or no truck representation or no rating set")
            return
        }
        truck.customerRatings.append(Double(rating))
        ftc.addRatingToTruck(uid: uid, truck: truck, rating: rating)
        updateViews()
        starRatingControl.isHidden = true
        rateButton.isHidden = true
        if starRatingControl.isHidden == false {
            ratingLabel.text = "Have you eaten here before?"
        } else {
            ratingLabel.text = "Thank you!"
        }
       
    }
    
    func updateViews() {
        viewMenuButton.layer.cornerRadius = 8

        guard let truck = truckRep, isViewLoaded else { return }
        
        truckNameLabel.text = truck.name
        cuisineTypeLabel.text = "Cuisine type:  \(truck.cuisineType)"
        let total = (truck.customerRatings.reduce(0,+))
        let count = Double(truck.customerRatings.count)
        let starRating = total / count
        let roundedValue = (starRating * 100).rounded() / 100
        truckRatingLabel.text = "Rated \(roundedValue) ★'s"
            
        guard let url = truck.image, let data = try? Data(contentsOf: url) else { return }
        DispatchQueue.main.async {
            self.truckImageView.image = UIImage(data: data)
            self.requestPhysicalAddress(location: CLLocation(latitude: truck.latitude, longitude: truck.longitude)) { [weak self] (placemark) in
                guard let placemark = placemark else { return }
                
                self?.truckAddressLabel.text = "Current Address: \(placemark.thoroughfare ?? "No street address"), \(placemark.locality ?? "No city"), \(placemark.administrativeArea ?? "No state") \(placemark.postalCode ?? "No zip code")"
                print("\(placemark.thoroughfare ?? "No street address"), \(placemark.locality ?? "No city"), \(placemark.administrativeArea ?? "No state") \(placemark.postalCode ?? "No zip code")")
            }
        }
    }
    
    func requestPhysicalAddress(location: CLLocation, completion: @escaping (CLPlacemark?) -> Void) {
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Error reverse geocoding location: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            guard let placemarks = placemarks else {
                print("Bad or no placemarks returned.")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            if placemarks.count >= 1 {
                let firstLocation = placemarks.first
                DispatchQueue.main.async {
                    completion(firstLocation)
                }
                return
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

