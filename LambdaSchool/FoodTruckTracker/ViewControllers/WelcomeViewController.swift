//
//  WelcomeViewController.swift
//  FoodTruckTracker
//
//  Created by Michael on 3/8/20.
//  Copyright © 2020 Michael. All rights reserved.
//

import UIKit
import FirebaseAuth

class WelcomeViewController: UIViewController {

    var handle: AuthStateDidChangeListenerHandle?
    
    var token: String?
    
    @IBOutlet weak var truckOperatorButton: UIButton!
    @IBOutlet weak var foodieButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            NSLog("This is the Authorization: \(auth)")
            
            if let user = user {
                NSLog("This is the User UID: \(user.uid)")
                user.getIDToken { (token, error) in
                    if let error = error {
                        NSLog("Error Authenticating user with Auth Token: \(String(describing: error))")
                    }
                    if let token = token {
                        NSLog("Reauthenticated user with token: \(token)")
                        self.token = token
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateViews()
    }
    
    func updateViews() {
        truckOperatorButton.layer.cornerRadius = 8
        foodieButton.layer.cornerRadius = 8
    }
    
    @IBAction func choiceTapped(_ sender: UIButton) {
        if sender.tag == 0 {
            performSegue(withIdentifier: "SignInSegue", sender: Choice.foodTruckOperator)
        } else {
            performSegue(withIdentifier: "SignInSegue", sender: Choice.foodie)
        }
    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SignInSegue" {
            guard let signInVC = segue.destination as? SignInViewController, let choice = sender as? Choice else { return }
            signInVC.choice = choice
        }
    }
}
