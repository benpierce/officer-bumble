//
//  PhysicsManager.swift
//  OfficerBumble
//
//  Created by Ben Pierce on 2015-01-03.
//  Copyright (c) 2015 Benjamin Pierce. All rights reserved.
//

import Foundation
import SpriteKit

open class PhysicsManager {
    
    fileprivate struct CollisonDelegate {
        var name: String
        var physicsHandler: PhysicsHandler
        var collideAgainstBodyType: BODY_TYPE
        var runBlock: (_ firstBody: SKSpriteNode, _ secondBody: SKSpriteNode) -> ()
    }
    
    fileprivate var contacts: [String:CollisonDelegate] = [:]
    fileprivate var lastContact: [String:CFTimeInterval] = [:]
    
    public init() {}
    
    open func AddContact(_ name: String, physicsHandler: PhysicsHandler, collideAgainstBodyType: BODY_TYPE, runBlock: @escaping (_ firstBody: SKSpriteNode, _ secondBody: SKSpriteNode) -> ()) {
        let delegate = CollisonDelegate(name: name, physicsHandler: physicsHandler, collideAgainstBodyType: collideAgainstBodyType, runBlock: runBlock)
        let trueName = name + "_" + collideAgainstBodyType.name
        
        contacts[trueName] = delegate
    }
    
    // Takes a key like "Bumble" but will remove anything prefixed with "Bumble_"
    open func RemoveContact(_ name: String) {
        var contactsToRemove = [String]()
        
        // First we need to figure out which keys start with a particular entity name.
        for keyName in contacts.keys {
            if ( keyName.hasPrefix(name + "_") ) {
                contactsToRemove.append(keyName)
            }
        }
        
        // Now we know the list, we can remove them.
        for keyName in contactsToRemove {
            contacts.removeValue(forKey: keyName)
        }
    }
    
    open func RemoveAllContacts() {
        contacts = [:]
    }
    
    // Returns how many contacts are registered to a particular entity.
    open func GetContactCount(_ name: String) -> Int {
        var count = 0
        
        for keyName in contacts.keys {
            if ( keyName.hasPrefix(name + "_") ) {
                count += 1
            }
        }
        
        return count
    }
    
    open func CheckCollisions(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        let firstBody = contact.bodyA.node as! SKSpriteNode
        let secondBody = contact.bodyB.node as! SKSpriteNode
        
        for delegate in contacts.values {
            if ( contactMask == delegate.physicsHandler.BodyType.rawValue | delegate.collideAgainstBodyType.rawValue ) {
                
                // We need to make sure that the name of this delegate matches at least one of the body names, otherwise all
                // nodes of the same type could receive collision notifications.
                if ( delegate.name == firstBody.name! || delegate.name == secondBody.name! ) {
                    lastContact[delegate.name] = CACurrentMediaTime()
                    delegate.runBlock(firstBody, secondBody)
                }
            }
        }
    }
    
    open func GetLastCollisionTime(_ name: String) -> CFTimeInterval? {
        return lastContact[name]
    }

}
