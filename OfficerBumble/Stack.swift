//
//  Stack.swift
//  OfficerBumble
//
//  Created by Ben Pierce on 2014-11-29.
//  Copyright (c) 2014 Benjamin Pierce. All rights reserved.
//

import Foundation

struct Stack<T> {
    var items = [T?]()
    
    mutating func push(_ item: T?) {
        items.append(item)
    }
    mutating func pop() -> T? {
        return items.removeLast()
    }
    mutating func peek() -> T? {
        if(hasItems()) {
            return items.last!
        } else {
            return nil
        }
    }
    
    mutating func clear() {
        items.removeAll()
    }
    
    mutating func hasItems() -> Bool {
        return (items.count > 0)
    }
    mutating func size() -> Int {
        return items.count
    }
}
