//
//  BowlingBall.swift
//  OfficerBumble
//
//  Created by Ben Pierce on 2014-12-14.
//  Copyright (c) 2014 Benjamin Pierce. All rights reserved.
//

import Foundation
import SpriteKit

final class BowlingBall : Weapon {
    fileprivate let WIDTH = CGFloat(0.075)
    fileprivate let HEIGHT = CGFloat(0.075)
    
    //private var bowlingball = Array<SKTexture>();
    
    public init(display : Display, floorLevel: Int, direction: DIRECTION, velocity: CGFloat, bumble: Bumble) {
        let texture = textureManager.taCriminal1.textureNamed("bowlingball1")
        
        let size = display.GetSizeByPercentageOfScene(WIDTH, heightPercent: HEIGHT, considerAspectRatio : true)
        
        super.init(texture: texture, size: size, floorLevel: floorLevel, direction: direction, velocity: velocity, bumble: bumble, display: display)
        self.zPosition = ZPOSITION.normal.rawValue
        
        self.name = "Weapon_BowlingBall" + UUID().uuidString     // So we can identify later on.
        
        // Now we can use self.
        CustomInitialize()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open var BodyType: BODY_TYPE {
        get { return .bowling_BALL }
    }
    
    open override func SetPhysics(_ physicsManager: PhysicsManager) {
        super.SetPhysics(physicsManager)
        
        let body1: SKPhysicsBody = SKPhysicsBody(circleOfRadius: size.width / 2 )
        
        body1.isDynamic = true
        body1.affectedByGravity = false
        body1.allowsRotation = false
        body1.contactTestBitMask = BODY_TYPE.bumble.rawValue
        body1.categoryBitMask = BODY_TYPE.bowling_BALL.rawValue
        body1.collisionBitMask = 0 //if you don't want this body to actually collide with anything
        self.physicsBody = body1
        
        physicsManager.AddContact(self.name!, physicsHandler: self, collideAgainstBodyType: BODY_TYPE.bumble, runBlock: Attack)
        
        self.xScale = (direction == .left) ? 1 : -1
    }
    
    open func Spawn(_ world : SKSpriteNode, display: Display) {
        //let animateAction = SKAction.animateWithTextures(self.bowlingball, timePerFrame: 0.125)
        //self.runAction(SKAction.repeatActionForever(animateAction))
        world.addChild(self)
        
        super.Move(textureManager.bowlingBallAction)
    }
    
    fileprivate func CustomInitialize() {
        /*
        bowlingball.append(textureManager.taCriminal1.textureNamed("bowlingball1"))
        bowlingball.append(textureManager.taCriminal1.textureNamed("bowlingball2"))
        bowlingball.append(textureManager.taCriminal1.textureNamed("bowlingball3"))
        bowlingball.append(textureManager.taCriminal1.textureNamed("bowlingball4"))
        */
    }
    
    
}
