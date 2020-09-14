//
//  SignUpViewController.swift
//  FoodTruckTracker
//
//  Created by Michael on 3/7/20.
//  Copyright © 2020 Michael. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController, UITextFieldDelegate {

    let ftc = FoodTruckController()
    
    var choice = Choice.foodie
    
    var uid: String?
    
    var handle: AuthStateDidChangeListenerHandle?
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        handle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            NSLog("This is the Authorization: \(auth)")
            if let user = user {
                NSLog("This is the User: \(user)))")
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Account Creation Successful!", message: "Logging You In...", preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alertController.addAction(alertAction)
                    self.present(alertController, animated: true)
                    self.uid = user.uid
                    NSLog("\(user.uid)... \(user.isEmailVerified)... \(String(describing: user.displayName))... \(String(describing: user.email))... \(user.metadata)")
                }
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        updateViews()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        Auth.auth().createUser(withEmail: email, password: password) { (auth, error) in
            if let error = error {
                NSLog("Error creating account: \(error)")
            } else {
                if Auth.auth().currentUser?.uid != nil {
                    if self.choice == .foodie {
                        self.performSegueByChoice()
                        self.performSegue(withIdentifier: "FoodieSignUpSegue", sender: self)
                    } else {
                        self.performSegueByChoice()
                        self.performSegue(withIdentifier: "FoodTruckOperatorSignUpSegue", sender: self)
                    }
                }
            }
        }
    }
    
    func performSegueByChoice() {
        if ftc.isUserLoggedIn {
            if choice == .foodTruckOperator {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let nav = storyboard.instantiateViewController(withIdentifier: "Navigation") as! UINavigationController
                let TruckOperatorPath = storyboard.instantiateViewController(identifier: "TruckOperator") as! MyFoodTrucksTableViewController
                nav.show(TruckOperatorPath, sender: self)
            } else {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let nav = storyboard.instantiateViewController(identifier: "Navigation") as! UINavigationController
                let FoodiePath = storyboard.instantiateViewController(identifier: "TruckOperator") as! FoodTrucksAroundMeViewController
                nav.show(FoodiePath, sender: self)
            }
        }
    }
    
    func updateViews() {
        emailTextField.layer.cornerRadius = 8
        emailTextField.layer.borderColor = UIColor.gray.cgColor
        emailTextField.layer.borderWidth = 2.0
        passwordTextField.layer.cornerRadius = 8
        passwordTextField.layer.borderColor = UIColor.gray.cgColor
        passwordTextField.layer.borderWidth = 2.0
        signUpButton.layer.cornerRadius = 8
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if emailTextField.isEditing {
            emailTextField.layer.borderColor = #colorLiteral(red: 0.1401111782, green: 0.1605518758, blue: 0.6343507767, alpha: 1)
            emailTextField.layer.borderWidth = 5.0
            passwordTextField.layer.borderWidth = 1.0
            passwordTextField.layer.borderColor = UIColor.gray.cgColor
        } else {
            passwordTextField.layer.borderColor = #colorLiteral(red: 0.1401111782, green: 0.1605518758, blue: 0.6343507767, alpha: 1)
            passwordTextField.layer.borderWidth = 5.0
            emailTextField.layer.borderWidth = 1.0
            emailTextField.layer.borderColor = UIColor.gray.cgColor
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        emailTextField.layer.borderWidth = 1.0
        emailTextField.layer.borderColor = UIColor.gray.cgColor
        passwordTextField.layer.borderWidth = 1.0
        passwordTextField.layer.borderColor = UIColor.gray.cgColor
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
