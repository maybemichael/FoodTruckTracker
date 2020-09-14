//
//  SignInViewController.swift
//  FoodTruckTracker
//
//  Created by Michael on 3/7/20.
//  Copyright © 2020 Michael. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignInViewController: ShiftableViewController {

    let ftc = FoodTruckController()
    
    var choice = Choice.foodTruckOperator
    
    var uid: String? {
        didSet {
            
        }
    }
    
    var handle: AuthStateDidChangeListenerHandle?
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            NSLog("This is the Authorization: \(auth)")
            
            if let user = user {
                self.uid = user.uid
                NSLog("This is the User UID: \(user.uid)")
                user.getIDToken { (token, error) in
                    if let error = error {
                        NSLog("Error Authenticating user with Auth Token: \(String(describing: error))")
                    }
                    if let token = token {
                        NSLog("Reauthenticated user with token: \(token)")
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser != nil {
            if self.choice == .foodie {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let nav = storyboard.instantiateViewController(withIdentifier: "NavigationMapView")
                    as! UINavigationController
                nav.modalPresentationStyle = .fullScreen
                self.navigationController?.present(nav, animated: true, completion: nil)
            } else {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let nav = storyboard.instantiateViewController(withIdentifier: "NavigationTruckOperator")
                    as! UINavigationController
                nav.modalPresentationStyle = .fullScreen
                self.navigationController?.present(nav, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        updateViews()
        performSegueByChoice()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        Auth.auth().signIn(withEmail: email, password: password) { (auth, error) in
            if let error = error {
                NSLog("Error signing into account: \(error) Data: \(String(describing: auth))")
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Incorrect Login Info", message: "Your username or password was incorrect.", preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
                    alertController.addAction(alertAction)
                    self.present(alertController, animated: true)
                }
            } else {
                if self.choice == .foodie {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let nav = storyboard.instantiateViewController(withIdentifier: "NavigationMapView")
                        as! UINavigationController
                    nav.modalPresentationStyle = .fullScreen
                    self.navigationController?.present(nav, animated: true, completion: nil)
                } else {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let nav = storyboard.instantiateViewController(withIdentifier: "NavigationTruckOperator")
                        as! UINavigationController
                    nav.modalPresentationStyle = .fullScreen
                    self.navigationController?.present(nav, animated: true, completion: nil)
                }
            }
        }
    }
    
    func performSegueByChoice() {
        if Auth.auth().currentUser?.uid != nil {
            if choice == .foodTruckOperator {
//                self.performSegue(withIdentifier: "FoodTruckOperatorSignInSegue", sender: self)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let nav = storyboard.instantiateViewController(withIdentifier: "Navigation") as! UINavigationController
                let TruckOperatorPath = storyboard.instantiateViewController(identifier: "TruckOperator") as! MyFoodTrucksTableViewController
                nav.show(TruckOperatorPath, sender: self)
            } else {
//                self.performSegue(withIdentifier: "FoodieSignInSegue", sender: self)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let nav = storyboard.instantiateViewController(identifier: "Navigation") as! UINavigationController
                let FoodiePath = storyboard.instantiateViewController(identifier: "Foodie") as! FoodTrucksAroundMeViewController
                nav.show(FoodiePath, sender: self)
//                nav.performSegue(withIdentifier: "FoodieSignInSegue", sender: self)
            }
        }
    }
    
    func updateViews() {
        emailTextField.layer.cornerRadius = 8
        emailTextField.layer.borderWidth = 2.0
        emailTextField.layer.borderColor = UIColor.gray.cgColor
        passwordTextField.layer.borderWidth = 2.0
        passwordTextField.layer.borderColor = UIColor.gray.cgColor
        passwordTextField.layer.cornerRadius = 8
        signInButton.backgroundColor = #colorLiteral(red: 0.1401111782, green: 0.1605518758, blue: 0.6343507767, alpha: 1)
        signInButton.layer.cornerRadius = 8
    }
    
//    override func textFieldDidBeginEditing(_ textField: UITextField) {
//        if emailTextField.isEditing {
//            emailTextField.layer.borderColor = #colorLiteral(red: 0.1401111782, green: 0.1605518758, blue: 0.6343507767, alpha: 1)
//            emailTextField.layer.borderWidth = 5.0
//            passwordTextField.layer.borderWidth = 1.0
//            passwordTextField.layer.borderColor = UIColor.gray.cgColor
//        } else {
//            passwordTextField.layer.borderColor = #colorLiteral(red: 0.1401111782, green: 0.1605518758, blue: 0.6343507767, alpha: 1)
//            passwordTextField.layer.borderWidth = 5.0
//            emailTextField.layer.borderWidth = 1.0
//            emailTextField.layer.borderColor = UIColor.gray.cgColor
//        }
//    }

//    func textFieldDidEndEditing(_ textField: UITextField) {
//        emailTextField.layer.borderWidth = 1.0
//        emailTextField.layer.borderColor = UIColor.gray.cgColor
//        passwordTextField.layer.borderWidth = 1.0
//        passwordTextField.layer.borderColor = UIColor.gray.cgColor
//    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SignUpSegue" {
            guard let signUpVC = segue.destination as? SignUpViewController, let choice = sender as? Choice else { return }
            signUpVC.choice = choice
        }
    }
    

}
