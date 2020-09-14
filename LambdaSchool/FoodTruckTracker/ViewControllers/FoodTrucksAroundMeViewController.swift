//
//  FoodTrucksAroundMeViewController.swift
//  FoodTruckTracker
//
//  Created by Michael on 3/9/20.
//  Copyright © 2020 Michael. All rights reserved.
//

import UIKit
import MapKit
import FirebaseAuth
import CoreLocation
import CoreData
import Contacts


class FoodTrucksAroundMeViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    let ftc = FoodTruckController()
    
    var trucks: [TruckRepresentation] = []
    
    let coords = CLLocationCoordinate2D(latitude: 37.522970, longitude: -122.272620)
    
    var truckMapKitDetailView: FoodTruckMapView = FoodTruckMapView()
    
    let regionRadius: CLLocationDistance = 4000
    
    let initialLocation = CLLocation(latitude: 37.563209533691406, longitude: -122.32380676269531)
    
    var truck: TruckRepresentation? {
        didSet {
    
        }
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<Truck> = {
        let fetchRequest: NSFetchRequest<Truck> = Truck.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true), NSSortDescriptor(key: "cuisineType", ascending: true)]
        let context = CoreDataStack.shared.mainContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: "name", cacheName: nil)
        try! frc.performFetch()
        return frc
    }()
    
    func getTrucks() {
        for truck in fetchedResultsController.fetchedObjects! {
            if let truckRep = truck.truckRepresentation {
                trucks.append(truckRep)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        ftc.fetchFoodTrucks {
            
        }
        centerMapOnLocation(location: initialLocation)
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "FoodTrucks")
        
        getTrucks()
        mapView.addAnnotations(trucks)
        
        NotificationCenter.default.addObserver(forName: .detailRequested, object: nil, queue: nil) { (catchNotification) in
            guard let truckRep = catchNotification.userInfo?[truckDetail] as? TruckRepresentation else { return }
            self.truck = truckRep
        }
//        NotificationCenter.default.addObserver(forName: .detailRequested, object: nil, queue: nil) { (catchNotification) in
//            guard let truckRep = catchNotification.userInfo?[truckDetail] as? TruckRepresentation else { return }
//            self.truck = truckRep
//            print(self.truck?.cuisineType)
//            print(truckRep.cuisineType)
//        }
//        NotificationCenter.default.addObserver(self, selector: #selector(setFoodTruck(truck:)), name: .detailRequested, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(performSegueToDetail(_:)), name: .performSegue, object: nil)
        
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    func getCoordinate( addressString : String,
                        completionHandler: @escaping(CLLocationCoordinate2D, NSError?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?[0] {
                    let location = placemark.location!
        
                    completionHandler(location.coordinate, nil)
    
                    return
                }
            }
                
            completionHandler(kCLLocationCoordinate2DInvalid, error as NSError?)
        }
    }
    
    @objc func setFoodTruck(truck: Notification) {
        let key = MyNotifications.detailRequested.rawValue
        let foodTruck = truck.userInfo?[key] as? TruckRepresentation
        self.truck = foodTruck
    }
    
    @objc func performSegueToDetail(_: Notification) {
        self.performSegue(withIdentifier: "FoodTruckDetailSegue", sender: self)
    }
    
    @IBAction func logOutTapped(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: \(signOutError)")
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let nav = storyboard.instantiateViewController(withIdentifier: "Navigation")
            as? UINavigationController else { return }
        nav.modalPresentationStyle = .fullScreen
        self.navigationController?.present(nav, animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FoodTruckDetailSegue" {
            guard let foodTruckDetailVC = segue.destination as? FoodTruckDetailViewController else { return }
            foodTruckDetailVC.truckRep = truck
        }
    }
}

extension FoodTrucksAroundMeViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let foodTruck = annotation as? TruckRepresentation else { return nil }
        
        let identifier = "FoodTrucks"
        
        guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation) as? MKMarkerAnnotationView else {
            fatalError("Missing a registered map annotation view")
        }
        if let url = truck?.image, let data = try? Data(contentsOf: url) {
            annotationView.image = UIImage(data: data)
        }
//        let truckDict: [String : TruckRepresentation] = [truckDetail: foodTruck]
//        NotificationCenter.default.post(name: .detailRequested, object: nil, userInfo: truckDict)
        annotationView.canShowCallout = true
        annotationView.glyphText = truck?.name
//        self.truck = foodTruck
        annotationView.animatesWhenAdded = true
        let detailView = FoodTruckMapView()
        detailView.foodTruck = foodTruck
        annotationView.detailCalloutAccessoryView = detailView
        annotationView.calloutOffset = CGPoint(x: -5, y: 5)
        return annotationView
    
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        
        guard let foodTruck = view.annotation as? TruckRepresentation else { return }
        if let url = foodTruck.image {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let truckReps = trucks.filter {$0.name == view.annotation?.title}
//        self.performSegue(withIdentifier: "FoodTruckDetailSegue", sender: truckReps)
    }
}

extension FoodTrucksAroundMeViewController: DetailViewDelegate {
    func selectedTruckDetail(truck: TruckRepresentation) {
        let truckRep = truck
        self.truck = truckRep
//        self.performSegue(withIdentifier: "FoodTruckDetailSegue", sender: self)
//        print("This is the truck: \(truck)")
    }
}
