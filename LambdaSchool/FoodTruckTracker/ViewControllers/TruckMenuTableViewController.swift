//
//  TruckMenuTableViewController.swift
//  FoodTruckTracker
//
//  Created by Michael on 3/7/20.
//  Copyright © 2020 Michael. All rights reserved.
//

import UIKit
import CoreData
import FirebaseAuth

class TruckMenuTableViewController: UITableViewController {

    let ftc = FoodTruckController()
    var trucks: [Truck] = []
    var menuItems: [MenuItemRepresentation] = []
    var handle: AuthStateDidChangeListenerHandle?
    var uid: String?
    let cache = Cache<UUID, UIImage>()
    let photoFetchQueue = OperationQueue()
    var operations = [UUID : Operation]()
    var truck: Truck? {
        didSet {
            
        }
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<MenuItem> = {
        var myTruck = Truck()
        if let truck = truck {
            myTruck = truck
        }
        trucks.append(myTruck)
        let fetchRequest: NSFetchRequest<MenuItem> = MenuItem.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true), NSSortDescriptor(key: "price", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "foodTruck IN %@", trucks)
        let context = CoreDataStack.shared.mainContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: "name", cacheName: nil)
        frc.delegate = self
        try! frc.performFetch()
        for record in frc.fetchedObjects! {
            print(record.value(forKey: "foodTruck") as Any)
        }
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        handle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if let user = user {
                self.uid = user.uid
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1

    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TruckMenuCell", for: indexPath) as? TruckMenuTableViewCell else { return UITableViewCell() }
        
        let menuItem = fetchedResultsController.object(at: indexPath)
        cell.menuItem = menuItem
        
        loadImage(forCell: cell, forItemAt: indexPath)
        
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alertController = UIAlertController(title: "Warning!", message: "Are you sure you want to delete this menu item?", preferredStyle: .alert)
            
            let confirmDeleteAction = UIAlertAction(title: "Confirm", style: .destructive) { _ in
                let menuItem = self.fetchedResultsController.object(at: indexPath)
                if let uid = self.uid, let truck = self.truck {
                    self.ftc.deleteTruckMenuItem(uid: uid, truck: truck, menuItem: menuItem)
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                
            }
            alertController.addAction(confirmDeleteAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
            
        }
    }
    
    private func loadImage(forCell cell: TruckMenuTableViewCell, forItemAt indexPath: IndexPath) {
        let menuItem = fetchedResultsController.object(at: indexPath)
        guard let menuItemRep = menuItem.menuItemRepresentation else { return }
        // Check for image in cache
        if let cachedImage = cache.value(for: menuItemRep.id) {
            cell.dishImageView?.image = cachedImage
            return
        }
        
        // Start an operation to fetch image data
        let fetchOp = MenuItemPhotoOperation(menuItem: menuItemRep)
        let cacheOp = BlockOperation {
            if let image = fetchOp.image {
                self.cache.cache(value: image, for: menuItemRep.id)
            }
        }
        let completionOp = BlockOperation {
            defer { self.operations.removeValue(forKey: menuItemRep.id) }
            
            if let currentIndexPath = self.tableView?.indexPath(for: cell),
                currentIndexPath != indexPath {
                return // Cell has been reused
            }
            
            if let image = fetchOp.image {
                cell.dishImageView?.image = image
            }
        }
        
        cacheOp.addDependency(fetchOp)
        completionOp.addDependency(fetchOp)
        
        photoFetchQueue.addOperation(fetchOp)
        photoFetchQueue.addOperation(cacheOp)
        OperationQueue.main.addOperation(completionOp)
        
        operations[menuItemRep.id] = fetchOp
    }
 
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddDishSegue" {
            guard let addMenuItemVC = segue.destination as? AddMenuItemViewController else { return }
            addMenuItemVC.truck = truck
        } else if segue.identifier == "EditMenuItemSegue" {
            guard let editMenuItemVC = segue.destination as? AddMenuItemViewController, let indexPath = tableView.indexPathForSelectedRow else { return }
            let menuItem = fetchedResultsController.object(at: indexPath)
            editMenuItemVC.menuItem = menuItem
            editMenuItemVC.truck = truck
        }
    }
    

}

extension TruckMenuTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
        }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .move:
            guard let oldIndexPath = indexPath,
                let newIndexPath = newIndexPath else { return }
            tableView.deleteRows(at: [oldIndexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        @unknown default:
            break
        }
    }
}
