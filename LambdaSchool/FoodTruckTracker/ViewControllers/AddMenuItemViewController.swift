//
//  AddMenuItemViewController.swift
//  FoodTruckTracker
//
//  Created by Michael on 3/7/20.
//  Copyright © 2020 Michael. All rights reserved.
//

import UIKit
import FirebaseAuth
import CoreData

class AddMenuItemViewController: ShiftableViewController {

    var truck: Truck? {
        didSet {
            
        }
    }
    
    var menuItem: MenuItem? {
        didSet {
            truck?.mutableSetValue(forKeyPath: "menuItem").add(menuItem as Any)
            
        }
    }
    
    let ftc = FoodTruckController()
    
    var uid: String?
    
    var handle: AuthStateDidChangeListenerHandle?
    
    @IBOutlet weak var dishImageView: UIImageView!
    @IBOutlet weak var dishNameTextField: UITextField!
    @IBOutlet weak var dishPriceTextField: UITextField!
    @IBOutlet weak var dishDescriptionTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dishNameTextField.delegate = self
        dishPriceTextField.delegate = self
        dishDescriptionTextView.delegate = self
        dishImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectPhoto)))
        updateViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        handle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            
            self.uid = user?.uid
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
        dishNameTextField.resignFirstResponder()
        dishPriceTextField.resignFirstResponder()
        dishDescriptionTextView.resignFirstResponder()
        
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let name = dishNameTextField.text, let description = dishDescriptionTextView.text, let price = dishPriceTextField.text, let truck = truck, let uid = uid else { return }
        
        if let data = dishImageView.image?.jpegData(compressionQuality: 0.5) {
            ftc.getImageURL(image: data) { (urlString) in
                if let urlString = urlString {
                    let dish = MenuItem(id: UUID(), name: name, description: description, price: Double(price)!, image: urlString)
                    truck.mutableSetValue(forKeyPath: "menuItem").add(dish as Any)
//                    self.ftc.saveToPersistentStore()
                    var menu = [MenuItemRepresentation]()
                    guard let dishRep = dish?.menuItemRepresentation, let truckRep = truck.truckRepresentation else {
                        print("Unable to convert dish and/or truck to their representations on add menu item view controller")
                        return
                    }
                    let fetchRequest: NSFetchRequest<MenuItem> = MenuItem.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "foodTruck IN %@", truck)
                    let context = CoreDataStack.shared.container.newBackgroundContext()
                    var error: Error?
//                    context.performAndWait {
//                        do {
//                            let existingMenuItems = try context.fetch(fetchRequest)
//                            for item in existingMenuItems {
//                                if let menuItem =  item.menuItemRepresentation {
//                                    menu.append(menuItem)
//                                }
//                            }
//                        } catch let fetchError {
//                            error = fetchError
//                            print("Error fetching trucks menu items to update database: \(error)")
//                        }
//
//                    }
                    menu.append(dishRep)
                    print(truck.menuItem ?? "did not work")
                    self.ftc.addMenuItemToTruck(uid: uid, truck: truckRep, menuItem: menu)
                    self.ftc.saveToPersistentStore()
                }
            }
        }
        navigationController?.popViewController(animated: true)
    }
//            let dish = MenuItem(id: UUID(), name: name, description: description, price: Double(price)!, image: data)
//
//            ftc.saveToPersistentStore()
//            if let dish = dish {
//                truck.mutableSetValue(forKeyPath: "menuItem").add(dish)
//                ftc.saveToPersistentStore()
//                guard var dishRep = dish.menuItemRepresentation, let truckRep = truck.truckRepresentation else { return }
//                print(truck.menuItem ?? "did not work")
//                ftc.getImageURL(image: data) { (urlString) in
//                    let url = URL(string: urlString!)
//                    dishRep.image = url
//                    self.ftc.addMenuItemToTruck(uid: uid, truck: truckRep, menuItem: dishRep)
//                }
//
//            }
            
//            let ids = truck.objectIDs(forRelationshipNamed: "menuItem")
//            NSLog("\(ids)")
//
//            do {
//                try truck.managedObjectContext?.save()
//            } catch {
//                if let saveError = error as NSError? {
//                    NSLog("Error saving menu item to truck; \(saveError)")
//                }
//            }
//            let dishRep = (dish?.menuItemRepresentation)!
//            let truckRep = (truck.truckRepresentation)!
//            self.ftc.addMenuItemToTruck(uid: self.uid!, truck: truckRep, menuItem: dishRep)
        
    
    @objc private func selectPhoto() {
      let imagePickerController = UIImagePickerController()
      imagePickerController.delegate = self
      imagePickerController.allowsEditing = true
       
      present(imagePickerController, animated: true, completion: nil)
    }
    
    func updateViews() {
        dishDescriptionTextView.layer.borderWidth = 2.0
        dishDescriptionTextView.layer.borderColor = UIColor.gray.cgColor
        dishDescriptionTextView.layer.cornerRadius = 8
        dishNameTextField.layer.cornerRadius = 8
        dishNameTextField.layer.borderColor = UIColor.gray.cgColor
        dishNameTextField.layer.borderWidth = 2.0
        dishPriceTextField.layer.cornerRadius = 8
        dishPriceTextField.layer.borderColor = UIColor.gray.cgColor
        dishPriceTextField.layer.borderWidth = 2.0
        
        if let menuItem = menuItem {
            dishNameTextField.text = menuItem.name
            dishPriceTextField.text = "\(menuItem.price)"
            dishDescriptionTextView.text = menuItem.dishDescription
            
            if let urlString = menuItem.image, let url = URL(string: urlString), let data = try? Data(contentsOf: url) {
                dishImageView.image = UIImage(data: data)
            }
            
        }
    }
    
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

extension AddMenuItemViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            dishImageView.image = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            dishImageView.image = originalImage
        }
        dismiss(animated: true, completion: nil)
    }
}

