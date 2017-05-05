//
//  Pie.swift
//  OfficerBumble
//
//  Created by Ben Pierce on 2014-12-14.
//  Copyright (c) 2014 Benjamin Pierce. All rights reserved.
//

import Foundation
import SpriteKit

final class Pie : Weapon {
    fileprivate let WIDTH = CGFloat(0.125)
    fileprivate let HEIGHT = CGFloat(0.125)
    
    //private var pie = Array<SKTexture>();
    
    public init(display : Display, floorLevel: Int, direction: DIRECTION, velocity: CGFloat, bumble: Bumble) {
        let texture = textureManager.taCriminal1.textureNamed("pie1")
        let size = display.GetSizeByPercentageOfScene(WIDTH, heightPercent: HEIGHT, considerAspectRatio : true)
        
        super.init(texture: texture, size: size, floorLevel: floorLevel, direction: direction, velocity: velocity, bumble: bumble, display: display)
        self.zPosition = 90
        
        self.name = "Weapon_Pie" + UUID().uuidString     // So we can identify later on.
        
        // Now we can use self.
        CustomInitialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func SetPhysics(_ physicsManager: PhysicsManager) {
        super.SetPhysics(physicsManager)
        
        let boundingBox = CGSize(width: size.width / 2.0, height: size.height)
        
        let body1 :SKPhysicsBody = SKPhysicsBody(rectangleOf: boundingBox)

        body1.isDynamic = true
        body1.affectedByGravity = false
        body1.allowsRotation = false
        body1.contactTestBitMask = BODY_TYPE.bumble.rawValue
        body1.categoryBitMask = BODY_TYPE.pie.rawValue
        body1.collisionBitMask = 0 //if you don't want this body to actually collide with anything
        self.physicsBody = body1
        
        physicsManager.AddContact(self.name!, physicsHandler: self, collideAgainstBodyType: BODY_TYPE.bumble, runBlock: Attack)
        
        self.xScale = (direction == .left) ? 1 : -1
    }
    
    open override var BodyType: BODY_TYPE {
        get { return .pie }
    }
    
    open func Spawn(_ world : SKSpriteNode, display: Display) {
        //let animateAction = SKAction.animateWithTextures(self.pie, timePerFrame: 0.125)
        //self.runAction(textureManager.pieAction)
        
        world.addChild(self)
        
        super.Move(textureManager.pieAction)
    }
    
    fileprivate func CustomInitialize() {
        /*
        pie.append(textureManager.taCriminal1.textureNamed("pie1"))
        pie.append(textureManager.taCriminal1.textureNamed("pie2"))
        pie.append(textureManager.taCriminal1.textureNamed("pie3"))
        pie.append(textureManager.taCriminal1.textureNamed("pie4"))
        pie.append(textureManager.taCriminal1.textureNamed("pie5"))
        pie.append(textureManager.taCriminal1.textureNamed("pie6"))
        */
    }
    
    
}
