//
//  AddFoodTruckViewController.swift
//  FoodTruckTracker
//
//  Created by Michael on 3/7/20.
//  Copyright © 2020 Michael. All rights reserved.
//

import UIKit
import FirebaseAuth
import MapKit

class AddFoodTruckViewController: ShiftableViewController {

    let ftc = FoodTruckController()
    
    var coordinate: CLLocationCoordinate2D?
    
    var uid: String?
    
    var handle: AuthStateDidChangeListenerHandle?
    
    @IBOutlet weak var truckNameTextField: UITextField!
    @IBOutlet weak var truckLocationTextField: UITextField!
    @IBOutlet weak var cuisineTypeTextField: UITextField!
    @IBOutlet weak var truckImageView: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        handle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if let user = user {
                NSLog("This is the User UID: \(user.uid)")
                self.uid = user.uid
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        truckNameTextField.delegate = self
        truckLocationTextField.delegate = self
        cuisineTypeTextField.delegate = self
        truckImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectPhoto)))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
        truckNameTextField.resignFirstResponder()
        truckLocationTextField.resignFirstResponder()
        cuisineTypeTextField.resignFirstResponder()
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        guard let name = truckNameTextField.text, let address = truckLocationTextField.text, let cuisineType = cuisineTypeTextField.text, let uid = uid else { return }
           
        if let data = truckImageView.image?.jpegData(compressionQuality: 0.5) {
            ftc.getImageURL(image: data) { (urlString) in
                if let urlString = urlString {
                    self.ftc.getCoordinate(addressString: address) { (coord, error) in
                        if let error = error {
                            NSLog("Error validating Food Truck Address: \(error)")
//                            self.presentUserInfoAlert(title: "Error", message: "Unable to validate address...")
                        }
                        self.coordinate = coord
                        guard let coordinate = self.coordinate, coordinate.latitude != 0, coordinate.longitude != 0 else {
                            self.presentUserInfoAlert(title: "Error", message: "Unable to validate address, please check address formatting and try again.")
                            return
                        }
                        let truck = Truck(name: name, menu: [], image: urlString, id: UUID(), customerRatings: [5], cuisineType: cuisineType, latitude: coordinate.latitude, longitude: coordinate.longitude)
                        //                    (name: name, menu: [], image: urlString, id: UUID(), customerRatings: [5, 4, 2, 5, 5, 5, 3, 5, 5], cuisineType: cuisineType, address: location)
                        self.ftc.saveToPersistentStore()
                        if let truckRep = truck?.truckRepresentation {
                            self.ftc.addFoodTruck(uid: uid, truck: truckRep)
                        }
                    }
                }
            }
        }
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func selectPhoto() {
      let imagePickerController = UIImagePickerController()
      imagePickerController.delegate = self
      imagePickerController.allowsEditing = true
       
      present(imagePickerController, animated: true, completion: nil)
    }
    
    func updateViews() {
        truckNameTextField.layer.cornerRadius = 8
        truckNameTextField.layer.borderColor = UIColor.gray.cgColor
        truckNameTextField.layer.borderWidth = 2.0
        cuisineTypeTextField.layer.cornerRadius = 8
        cuisineTypeTextField.layer.borderColor = UIColor.gray.cgColor
        cuisineTypeTextField.layer.borderWidth = 2.0
        truckLocationTextField.layer.cornerRadius = 8
        truckLocationTextField.layer.borderColor = UIColor.gray.cgColor
        truckLocationTextField.layer.borderWidth = 2.0
        truckImageView.image = UIImage(named: "FoodTruck_Placeholder-Image")
    }
    
//    override func textFieldDidBeginEditing(_ textField: UITextField) {
//            if truckNameTextField.isEditing {
//                truckNameTextField.layer.borderWidth = 5.0
//                truckNameTextField.layer.borderColor = #colorLiteral(red: 0.1401111782, green: 0.1605518758, blue: 0.6343507767, alpha: 1)
//                cuisineTypeTextField.layer.borderWidth = 1.0
//                cuisineTypeTextField.layer.borderColor = UIColor.gray.cgColor
//                truckLocationTextField.layer.borderWidth = 1.0
//                truckLocationTextField.layer.borderColor = UIColor.gray.cgColor
//            } else if cuisineTypeTextField.isEditing {
//                truckNameTextField.layer.borderWidth = 1.0
//                truckNameTextField.layer.borderColor = UIColor.gray.cgColor
//                cuisineTypeTextField.layer.borderWidth = 5.0
//                cuisineTypeTextField.layer.borderColor = #colorLiteral(red: 0.1401111782, green: 0.1605518758, blue: 0.6343507767, alpha: 1)
//                truckLocationTextField.layer.borderWidth = 1.0
//                truckLocationTextField.layer.borderColor = UIColor.gray.cgColor
//            } else if truckLocationTextField.isEditing {
//                truckNameTextField.layer.borderWidth = 1.0
//                truckNameTextField.layer.borderColor = UIColor.gray.cgColor
//                cuisineTypeTextField.layer.borderWidth = 1.0
//                cuisineTypeTextField.layer.borderColor = UIColor.gray.cgColor
//                truckLocationTextField.layer.borderWidth = 5.0
//                truckLocationTextField.layer.borderColor = #colorLiteral(red: 0.1401111782, green: 0.1605518758, blue: 0.6343507767, alpha: 1)
//            }
//        }

//    func textFieldDidEndEditing(_ textField: UITextField) {
//        truckNameTextField.layer.borderWidth = 1.0
//        truckNameTextField.layer.borderColor = UIColor.gray.cgColor
//        cuisineTypeTextField.layer.borderWidth = 1.0
//        cuisineTypeTextField.layer.borderColor = UIColor.gray.cgColor
//        truckLocationTextField.layer.borderWidth = 1.0
//        truckLocationTextField.layer.borderColor = UIColor.gray.cgColor
//    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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

extension AddFoodTruckViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            truckImageView.image = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            truckImageView.image = originalImage
        }
        dismiss(animated: true, completion: nil)
    }
}
