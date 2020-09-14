//
//  FoodTruckController.swift
//  FoodTruckTracker
//
//  Created by Michael on 3/6/20.
//  Copyright © 2020 Michael. All rights reserved.
//

import Foundation
import Firebase
import CodableFirebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import MapKit
import Contacts

class FoodTruckController {
    
    private let baseURL = URL(string: "https://foodtrucktrackr.herokuapp.com/api/")!
    
    var token: String?
    
    var isUserLoggedIn: Bool {
        if token == nil {
            return false
        } else {
            return true
        }
    }
    
    var handle: AuthStateDidChangeListenerHandle?
    
    let menuPath = "/menu"
    
    let foodTruckRef: DatabaseReference = Database.database().reference()
    
    let imageRef = Storage.storage().reference().child("images")
    
    var trucksByUser: [TruckRepresentation] = []
    
    var menuItemsByTruck: [MenuItemRepresentation] = []
    
    var imageStringURL: String?
    
    typealias completion = Result<User?, Error>

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
    
    func getImageURL(image: Data, completion: @escaping (_ url: String?) -> Void) {
        let imageName = UUID().uuidString
        
        let foodTruckRef = imageRef.child(imageName)
        foodTruckRef.putData(image, metadata: nil) { (metadata, error) in
            if let error = error {
                NSLog("Error uploading image to server: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
            foodTruckRef.downloadURL { (url, error) in
                if let error = error {
                    NSLog("Error downloading image URL: \(error)")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
                guard let url = url else {
                    NSLog("No URL Returned")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
                NSLog(url.absoluteString)
                DispatchQueue.main.async {
                    completion(url.absoluteString)
                }
                self.imageStringURL = url.absoluteString
                print(url.absoluteString)
            }
        }
    }
    
    func deleteTruckFromServer(uid: String, truck: Truck) {
        guard let id = truck.identifier else { return }
        foodTruckRef.child(uid).child(id.uuidString).removeValue { (error, _) in
            if let error = error {
                NSLog("Error deleting truck: \(error)")
                return
            } else {
                NSLog("Successfully deleted Food Truck!")
            }
        }
    }
    
    func deleteMenuItemFromServer(uid: String, truck: Truck, menuItem: MenuItem) {
        guard let truckID = truck.identifier, let menuItemID = menuItem.identifier else { return }
        foodTruckRef.child(uid).child("\(truckID)\(menuPath)").child(menuItemID.uuidString).removeValue { (error, _)  in
            if let error = error {
                NSLog("Error deleting menu item from server: \(error)")
                return
            } else {
                NSLog("Successfully deleted Menu Item!")
            }
        }
    }
    
    func fetchMenuItemsByTruck(truck: Truck, completion: @escaping (Error?) -> ()) {
        guard let userID = Auth.auth().currentUser?.uid, let truckID = truck.identifier else { return }
        
        foodTruckRef.child(userID).child("\(truckID)/menu").observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value else { return }
            do {
                let menuItems = try FirebaseDecoder().decode([MenuItemRepresentation].self, from: value)
                self.menuItemsByTruck = menuItems
                print(self.menuItemsByTruck.count)
                print(self.menuItemsByTruck[0].name)
            } catch {
                NSLog("Error Decoding Menu Items for \(truck): \(error)")
                DispatchQueue.main.async {
                    completion(error)
                }
                return
            }
        }
    }
    
    func fetchFoodTrucks(completion: @escaping () -> ()) {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        foodTruckRef.child(userID).observeSingleEvent(of: .value, with: { snapshot in
            
            guard let value = snapshot.value else { return }
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: value, options: [])
                let data = try JSONSerialization.jsonObject(with: jsonData, options: [])
                print(data)
                let trucks = Array(try FirebaseDecoder().decode([String : TruckRepresentation].self, from: value).values)
                self.trucksByUser = trucks
                print(self.trucksByUser[0].menu?.first as Any)
            } catch {
                NSLog("Error decoding Menu Item Objects: \(error)")
                DispatchQueue.main.async {
                    completion()
                }
            }
        }) { error in
            NSLog("Error fetching Menu Items: \(error.localizedDescription)")
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func createAnAccount(email: String, password: String, completion: @escaping(completion) -> ()) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                NSLog("Error creating User: \(error)")
                return
            }
            completion(.success(result?.user))
        }
    }
    
    func signInUser(email: String, password: String, completion: @escaping(completion) -> () ) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                NSLog("Error signing in User: \(error)")
                return
            }
            completion(.success(result?.user))
        }
    }
    
    func deleteUser(completion: @escaping(Error?) ->()) {
        if let user = Auth.auth().currentUser {
            user.delete { error in
                if let error = error {
                    completion(error)
                    return
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            if let error = error as NSError? {
                print ("Error Signing Out: %@", error)
            } else {
                print("Log out successful!")
            }
        }
    }
    
    func addFoodTruck(uid: String, truck: TruckRepresentation) {
        let data = try! FirebaseEncoder().encode(truck)
        foodTruckRef.child("\(uid)").child("\(truck.id)").setValue(data) { (error: Error?, ref: DatabaseReference) in
            if let error = error {
                NSLog("Truck could not be saved: \(error) for \(ref)")
            } else {
                NSLog("Truck saved successfully in \(ref)")
            }
        }
    }
    
    func addMenuItemToTruck(uid: String, truck: TruckRepresentation, menuItem: [MenuItemRepresentation]) {
        let data = try! FirebaseEncoder().encode(menuItem)
        
        foodTruckRef.child(uid).child("\(truck.id)\(menuPath)").setValue(data) { (error: Error?, ref: DatabaseReference) in
            if let error = error {
                NSLog("Menu Item could not be saved: \(error) for \(ref)")
            } else {
                NSLog("Menu Item saved successfully in \(ref)")
            }
        }
    }
    
    func updateTruckWithRating(uid: String, truck: TruckRepresentation) {
        
        guard let data = try? FirebaseEncoder().encode(truck) else {
            NSLog("Unable to encode rating data.")
            return
        }
        
        foodTruckRef.child(uid).child(truck.id.uuidString).setValue(data) {
            (error: Error?) in
            if let error = error {
                NSLog("Rating item could not be saved to server: \(error)")
            } else {
                NSLog("Rating successfully saved to server for truck: \(truck.name)")
            }
        }
    }
    
    func addRatingToTruck(uid: String, truck: TruckRepresentation, rating: Double) {
        
        let customerRatings = "customerRatings"
        
        foodTruckRef.child(uid).child(truck.id.uuidString).updateChildValues([customerRatings : rating]) { (error, _) in
            if let error = error {
                NSLog("Rating item could not be saved to server: \(error)")
            } else {
                NSLog("Rating successfully saved to server for truck: \(truck.name)")
                
            }
        }
    }

    
    func saveToPersistentStore() {
        do {
            try CoreDataStack.shared.save()
        } catch {
            NSLog("Error Saving Managed Object Context: \(error)")
            CoreDataStack.shared.mainContext.reset()
        }
    }
    
    func deleteTruck(uid: String, truck: Truck) {
        deleteTruckFromServer(uid: uid, truck: truck)
        CoreDataStack.shared.mainContext.delete(truck)
        saveToPersistentStore()
    }
    
    func deleteTruckMenuItem(uid: String, truck: Truck, menuItem: MenuItem) {
        deleteMenuItemFromServer(uid: uid, truck: truck, menuItem: menuItem)
        CoreDataStack.shared.mainContext.delete(menuItem)
        saveToPersistentStore()
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
            NSLog("\(String(describing: address))")
            completion(placemarks, nil)
        }
    }
}
