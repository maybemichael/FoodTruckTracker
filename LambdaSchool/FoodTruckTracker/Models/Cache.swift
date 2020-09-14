//
//  Cache.swift
//  FoodTruckTracker
//
//  Created by Michael on 3/25/20.
//  Copyright © 2020 Michael. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    var cache = [Key : Value]()
    let queue = DispatchQueue(label: "Cache Queue")
    
    func cache(value: Value, for key: Key) {
        queue.async {
            self.cache[key] = value
        }
    }
    
    func value(for key: Key) -> Value? {
        return queue.sync { cache[key] }
    }
    
    func clear() {
        queue.async {
            self.cache.removeAll()
        }
    }
}
