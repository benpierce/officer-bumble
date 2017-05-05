//
//  Escalator.swift
//  OfficerBumble
//
//  Created by Ben Pierce on 2015-01-24.
//  Copyright (c) 2015 Benjamin Pierce. All rights reserved.
//

import Foundation
import SpriteKit

final class Escalator : SKSpriteNode {
    open var bumbleUsed = false
    open var criminalUsed = false
    
    // Try to do all setup in here.
    public init() {
        let texture = textureManager.taLevelCommon.textureNamed("escalator")
        
        bumbleUsed = false
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func Initialize() {
        SetPhysics()
    }
    
    fileprivate func SetPhysics() {
        let boundingBox = CGSize(width: size.width * 0.65, height: size.height)
        let center = CGPoint(x: 0, y: 0)
        
        let body:SKPhysicsBody = SKPhysicsBody(rectangleOf: boundingBox, center: center)
        body.isDynamic = true
        body.affectedByGravity = false
        body.allowsRotation = false
        body.categoryBitMask = BODY_TYPE.escalator.rawValue //was toRaw() in Xcode 6
        body.collisionBitMask = 0 //if you don't want this body to actually collide with anything
        
        self.physicsBody = body
    }

}
