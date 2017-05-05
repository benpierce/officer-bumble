//
//  Exit.swift
//  OfficerBumble
//
//  Created by Ben Pierce on 2015-02-04.
//  Copyright (c) 2015 Benjamin Pierce. All rights reserved.
//

import Foundation
import SpriteKit

final class Exit : SKSpriteNode {
    
    public init(texture: SKTexture?) {
        super.init(texture: texture, color: UIColor.clear, size: CGSize(width: 0, height: 0))
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func Initialize() {
        SetPhysics()
    }
    
    fileprivate func SetPhysics() {
        let boundingBox = CGSize(width: size.width * 0.05, height: size.height)
        let center = CGPoint(x: size.width / 7, y: 0)
        
        let body:SKPhysicsBody = SKPhysicsBody(rectangleOf: boundingBox, center: center)
        body.isDynamic = true
        body.affectedByGravity = false
        body.allowsRotation = false
        body.categoryBitMask = BODY_TYPE.exit.rawValue //was toRaw() in Xcode 6
        body.collisionBitMask = 0 //if you don't want this body to actually collide with anything
        
        self.physicsBody = body
    }

}
