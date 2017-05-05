//
//  Robothrower2000.swift
//  OfficerBumble
//
//  Created by Ben Pierce on 2014-12-12.
//  Copyright (c) 2014 Benjamin Pierce. All rights reserved.
//

import Foundation
import SpriteKit

final class Robothrower2000 : SKSpriteNode {
    
    // Animation Constaints
    fileprivate let THROW_TIME_PER_FRAME = 0.0666
    fileprivate let BOWL_TIME_PER_FRAME = 0.0285
    
    // Texture Refs
    fileprivate let textureAtlas1 = SKTextureAtlas(named:"training")
    fileprivate var display : Display
    fileprivate var robothrower = Array<SKTexture>()
    fileprivate var robothrowerBowlStart = Array<SKTexture>()
    fileprivate var robothrowerBowlEnd = Array<SKTexture>()
    fileprivate var robothrowerThrowStart = Array<SKTexture>()
    fileprivate var robothrowerThrowEnd = Array<SKTexture>()
    fileprivate var bumble: Bumble?
    
    // Try to do all setup in here.
    init(display : Display) {
        let texture = SKTexture(imageNamed: "robothrower_bowl1")
        self.display = display
        
        super.init(texture: texture, color: UIColor.clear, size: texture.size())

        // Now we can use self.
        CustomInitialize()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // This is required because weapons need to have knowledge of Bumble 
    func SetBumble(_ bumble: Bumble) {
        self.bumble = bumble
    }
    
    fileprivate func CustomInitialize() {
        // Basic state
        robothrower.append(textureAtlas1.textureNamed("robothrower_bowl1"))
        
        // Bowling
        robothrowerBowlStart.append(textureAtlas1.textureNamed("robothrower_bowl1"))
        robothrowerBowlStart.append(textureAtlas1.textureNamed("robothrower_bowl2"))
        robothrowerBowlStart.append(textureAtlas1.textureNamed("robothrower_bowl3"))
        robothrowerBowlStart.append(textureAtlas1.textureNamed("robothrower_bowl4"))
        robothrowerBowlStart.append(textureAtlas1.textureNamed("robothrower_bowl5"))
        robothrowerBowlStart.append(textureAtlas1.textureNamed("robothrower_bowl6"))
        robothrowerBowlStart.append(textureAtlas1.textureNamed("robothrower_bowl7"))
        robothrowerBowlStart.append(textureAtlas1.textureNamed("robothrower_bowl8"))
        robothrowerBowlStart.append(textureAtlas1.textureNamed("robothrower_bowl9"))
        robothrowerBowlStart.append(textureAtlas1.textureNamed("robothrower_bowl10"))

        robothrowerBowlEnd.append(textureAtlas1.textureNamed("robothrower_bowl11"))
        robothrowerBowlEnd.append(textureAtlas1.textureNamed("robothrower_bowl12"))
        robothrowerBowlEnd.append(textureAtlas1.textureNamed("robothrower_bowl13"))
        robothrowerBowlEnd.append(textureAtlas1.textureNamed("robothrower_bowl14"))
        robothrowerBowlEnd.append(textureAtlas1.textureNamed("robothrower_bowl15"))
        robothrowerBowlEnd.append(textureAtlas1.textureNamed("robothrower_bowl16"))
        robothrowerBowlEnd.append(textureAtlas1.textureNamed("robothrower_bowl17"))
        robothrowerBowlEnd.append(textureAtlas1.textureNamed("robothrower_bowl18"))
        robothrowerBowlEnd.append(textureAtlas1.textureNamed("robothrower_bowl19"))
        robothrowerBowlEnd.append(textureAtlas1.textureNamed("robothrower_bowl20"))
        
        // Throwing
        robothrowerThrowStart.append(textureAtlas1.textureNamed("robothrower_cata1"))
        robothrowerThrowStart.append(textureAtlas1.textureNamed("robothrower_cata2"))
        robothrowerThrowEnd.append(textureAtlas1.textureNamed("robothrower_cata3"))
        
        robothrowerThrowEnd.append(textureAtlas1.textureNamed("robothrower_cata4"))
        robothrowerThrowEnd.append(textureAtlas1.textureNamed("robothrower_cata5"))
        robothrowerThrowEnd.append(textureAtlas1.textureNamed("robothrower_cata6"))
        robothrowerThrowEnd.append(textureAtlas1.textureNamed("robothrower_cata7"))
        robothrowerThrowEnd.append(textureAtlas1.textureNamed("robothrower_cata8"))
        robothrowerThrowEnd.append(textureAtlas1.textureNamed("robothrower_cata9"))
        robothrowerThrowEnd.append(textureAtlas1.textureNamed("robothrower_cata10"))
    }
    
    func ThrowPie(_ world: SKSpriteNode, physicsManager: PhysicsManager, velocity: CGFloat) {
        Throw({ self.SpawnPie(world, physicsManager: physicsManager, velocity: velocity) })
    }

    func Bowl(_ world: SKSpriteNode, physicsManager: PhysicsManager, velocity: CGFloat) {
        Shoot({ self.SpawnBowlingBall(world, physicsManager: physicsManager, velocity: velocity) })
    }
    
    func ThrowChickenatorHigh(_ world: SKSpriteNode, physicsManager: PhysicsManager, velocity: CGFloat) {
        Throw({ self.SpawnChickenatorHigh(world, physicsManager: physicsManager, velocity: velocity) })
    }
   
    func ThrowChickenatorLow(_ world: SKSpriteNode, physicsManager: PhysicsManager, velocity: CGFloat) {
        Shoot({ self.SpawnChickenatorLow(world, physicsManager: physicsManager, velocity: velocity) })
    }

    fileprivate func Throw(_ spawnBlock : @escaping () -> ()) {
        self.removeAllActions()
        let animateActionStart = SKAction.animate(with: self.robothrowerThrowStart, timePerFrame: THROW_TIME_PER_FRAME)
        let animateActionEnd = SKAction.animate(with: self.robothrowerThrowEnd, timePerFrame: THROW_TIME_PER_FRAME)
        
        let pieBlock = SKAction.run(spawnBlock)
        let stopBlock = SKAction.run({ self.Stop() })
        
        let actions = [animateActionStart, pieBlock, animateActionEnd, stopBlock]
        self.run(SKAction.sequence(actions))
    }
    
    fileprivate func Shoot(_ spawnBlock : @escaping () -> ()) {
        self.removeAllActions()
        let animateActionStart = SKAction.animate(with: self.robothrowerBowlStart, timePerFrame: BOWL_TIME_PER_FRAME)
        let animateActionEnd = SKAction.animate(with: self.robothrowerBowlEnd, timePerFrame: BOWL_TIME_PER_FRAME)
        
        let bowlingBlock = SKAction.run(spawnBlock)
        let stopBlock = SKAction.run({ self.Stop() })
        
        let actions = [animateActionStart,
                       bowlingBlock,
                       animateActionEnd,
                       stopBlock]
        self.run(SKAction.sequence(actions))
    }
    
    fileprivate func SpawnChickenatorHigh(_ world : SKSpriteNode, physicsManager: PhysicsManager, velocity: CGFloat) {
        let chickenator = Chickenator(display : display, floorLevel: 1, direction: .left, velocity: velocity, bumble: bumble!)
        let x = self.position.x - (self.size.width / 2) + (chickenator.size.width / 2)

        let oscillateFrom = CGFloat((self.position.y) + (chickenator.size.height / 1.5))
        let oscillateTo = CGFloat((self.position.y) - (self.size.height / 2) + (chickenator.size.height / 1.5))

        chickenator.position = CGPoint(x: x, y: oscillateFrom)
        chickenator.Spawn(world, initialPosition : .high, from: oscillateFrom, to: oscillateTo)
        chickenator.SetPhysics(physicsManager)
        NotificationCenter.default.post(name: Notification.Name(rawValue: EVENT_TYPE.ROBOTHROWER_THROW.rawValue), object: nil)
    }
    
    fileprivate func SpawnChickenatorLow(_ world : SKSpriteNode, physicsManager: PhysicsManager, velocity: CGFloat) {
        let chickenator = Chickenator(display: display, floorLevel: 1, direction: .left, velocity: velocity, bumble: bumble!)
        let x = self.position.x - (self.size.width / 2) + (chickenator.size.width / 2)
        
        let oscillateFrom = CGFloat((self.position.y) - (self.size.height / 2) + (chickenator.size.height / 1.5))
        let oscillateTo = CGFloat((self.position.y) + (chickenator.size.height / 1.5))
        
        chickenator.position = CGPoint(x: x, y: oscillateFrom)
        chickenator.Spawn(world, initialPosition : .low, from: oscillateFrom, to: oscillateTo)
        chickenator.SetPhysics(physicsManager)
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: EVENT_TYPE.ROBOTHROWER_SHOOT.rawValue), object: nil)
    }
    
    fileprivate func SpawnPie(_ world : SKSpriteNode, physicsManager: PhysicsManager, velocity: CGFloat) {
        let pie = Pie(display: display, floorLevel: 1, direction: .left, velocity: velocity, bumble: bumble!)
        let x = self.position.x - (self.size.width / 2) + (pie.size.width / 2)
        let y = self.position.y + (self.size.height / 2) - (pie.size.height / 2)
        pie.position = CGPoint(x: x, y: y)
        
        pie.SetPhysics(physicsManager)
        pie.Spawn(world, display: display)
        NotificationCenter.default.post(name: Notification.Name(rawValue: EVENT_TYPE.ROBOTHROWER_THROW.rawValue), object: nil)
    }
    
    fileprivate func SpawnBowlingBall(_ world : SKSpriteNode, physicsManager: PhysicsManager, velocity: CGFloat) {
        let bowlingBall = BowlingBall(display: display, floorLevel: 1, direction: .left, velocity: velocity, bumble: bumble!)
        let x = self.position.x - (self.size.width / 2) + (bowlingBall.size.width / 2)
        let y = self.position.y - (self.size.height / 2) + bowlingBall.size.height
        bowlingBall.position = CGPoint(x: x, y: y)
        
        bowlingBall.SetPhysics(physicsManager)
        bowlingBall.Spawn(world, display: display)
        NotificationCenter.default.post(name: Notification.Name(rawValue: EVENT_TYPE.ROBOTHROWER_SHOOT.rawValue), object: nil)
    }
    
    func Stop() {
        self.removeAllActions()
    }
}
