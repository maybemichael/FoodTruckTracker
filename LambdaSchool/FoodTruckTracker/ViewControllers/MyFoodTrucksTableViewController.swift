//
//  MyFoodTrucksTableViewController.swift
//  FoodTruckTracker
//
//  Created by Michael on 3/7/20.
//  Copyright © 2020 Michael. All rights reserved.
//

import UIKit
import CoreData
import FirebaseAuth

class MyFoodTrucksTableViewController: UITableViewController {

    var handle: AuthStateDidChangeListenerHandle?
    let ftc = FoodTruckController()
    let cache = Cache<UUID, UIImage>()
    let photoFetchQueue = OperationQueue()
    var operations = [UUID : Operation]()
    var uid: String?
    
    lazy var fetchedResultsController: NSFetchedResultsController<Truck> = {
        let fetchRequest: NSFetchRequest<Truck> = Truck.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true), NSSortDescriptor(key: "cuisineType", ascending: true)]
        let context = CoreDataStack.shared.mainContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: "name", cacheName: nil)
        frc.delegate = self
        try! frc.performFetch()
        return frc
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                NSLog("This is the User UID: \(user.uid)")
                self.uid = user.uid
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FoodTruckCell", for: indexPath) as? MyTrucksTableViewCell else { return UITableViewCell() }

        let truck = fetchedResultsController.object(at: indexPath)
        cell.truck = truck
        loadImage(forCell: cell, forItemAt: indexPath)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alertController = UIAlertController(title: "Warning!", message: "Are you sure you want to delete this food truck?", preferredStyle: .alert)
            
            let confirmDeleteAction = UIAlertAction(title: "Confirm", style: .destructive) { _ in
                let truck = self.fetchedResultsController.object(at: indexPath)
                if let uid = self.uid {
                    self.ftc.deleteTruck(uid: uid, truck: truck)
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                
            }
            alertController.addAction(confirmDeleteAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
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
    
    private func loadImage(forCell cell: MyTrucksTableViewCell, forItemAt indexPath: IndexPath) {
        let truck = fetchedResultsController.object(at: indexPath)
        guard let truckRep = truck.truckRepresentation else { return }
        // Check for image in cache
        if let cachedImage = cache.value(for: truckRep.id) {
            cell.truckImageView?.image = cachedImage
            return
        }
        
        // Start an operation to fetch image data
        let fetchOp = TruckPhotoOperation(truck: truckRep)
        let cacheOp = BlockOperation {
            if let image = fetchOp.image {
                self.cache.cache(value: image, for: truckRep.id)
            }
        }
        let completionOp = BlockOperation {
            defer { self.operations.removeValue(forKey: truckRep.id) }
            
            if let currentIndexPath = self.tableView?.indexPath(for: cell),
                currentIndexPath != indexPath {
                return // Cell has been reused
            }
            
            if let image = fetchOp.image {
                cell.truckImageView?.image = image
            }
        }
        
        cacheOp.addDependency(fetchOp)
        completionOp.addDependency(fetchOp)
        
        photoFetchQueue.addOperation(fetchOp)
        photoFetchQueue.addOperation(cacheOp)
        OperationQueue.main.addOperation(completionOp)
        
        operations[truckRep.id] = fetchOp
    }
    
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TruckMenuSegue" {
            guard let truckMenuTVC = segue.destination as? TruckMenuTableViewController, let indexPath = tableView.indexPathForSelectedRow else { return }
            let truck = fetchedResultsController.object(at: indexPath)
            truckMenuTVC.truck = truck
            
        }
    }
}

extension MyFoodTrucksTableViewController: NSFetchedResultsControllerDelegate {
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
