//
//  MenuItemPhotoOperation.swift
//  FoodTruckTracker
//
//  Created by Michael on 3/25/20.
//  Copyright © 2020 Michael. All rights reserved.
//

import UIKit

class MenuItemPhotoOperation: ConcurrentOperation {
    
    var dataTask: URLSessionDataTask?
    
    var image: UIImage?
    
    let session: URLSession
    
    let menuItem: MenuItemRepresentation
    
    init(menuItem: MenuItemRepresentation, session: URLSession = URLSession.shared) {
        self.menuItem = menuItem
        self.session = session
        super.init()
    }
    
    override func start() {
        state = .isExecuting
        let url = menuItem.image!
        
        let task = session.dataTask(with: url) { (data, response, error) in
            defer { self.state = .isFinished }
            if self.isCancelled { return }
            if let error = error {
                NSLog("Error fetching data for \(self.menuItem): \(error)")
                return
            }
            
            if let data = data {
                self.image = UIImage(data: data)
            }
        }
        task.resume()
        dataTask = task
    }
    
    override func cancel() {
        dataTask?.cancel()
        super.cancel()
    }
}
