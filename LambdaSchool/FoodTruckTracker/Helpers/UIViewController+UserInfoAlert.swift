//
//  UIViewController+UserInfoAlert.swift
//  FoodTruckTracker
//
//  Created by Michael on 3/17/20.
//  Copyright © 2020 Michael. All rights reserved.
//

import UIKit

extension UIViewController {
    func presentUserInfoAlert(title: String?, message: String?, dismissActionCompletion: ((UIAlertAction) -> Void)? = nil, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: dismissActionCompletion)
        
        alertController.addAction(dismissAction)
        
        present(alertController, animated: true, completion: completion)
    }
}
