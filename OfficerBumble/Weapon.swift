/*
===============================================================================
Weapon

Encapsulates common weapon functionality.
===============================================================================
*/

import Foundation
import SpriteKit

open class Weapon : SKSpriteNode, PhysicsHandler {
    
    open var floorLevel: Int                    // Floor level of the weapon.
    open var direction: DIRECTION               // Direction the weapon is travelling.
    open var physicsManager: PhysicsManager?    // So that we can detect physics updates.
    open var isBehindBumble = false             // Whether or not the weapon is behind Bumble (on the same floor).
    var bumble: Bumble                            // Reference to Bumble
    var isTakenOutOfPlay = false                  // This will be set to true if a collision with Bumble occurs.
    
    // Movement Variables
    fileprivate var velocityPerSecond = CGFloat(0)
    fileprivate var lastVelocityAdjustmentTime : CFTimeInterval = 0
    
    init(texture: SKTexture, size: CGSize, floorLevel: Int, direction: DIRECTION, velocity: CGFloat, bumble: Bumble, display: Display) {
        self.floorLevel = floorLevel
        self.direction = direction
        self.bumble = bumble
        self.velocityPerSecond = ((direction == .left) ? -1: 1) * velocity
        
        super.init(texture: texture, color: UIColor.clear, size: size)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func Update(_ currentTime: CFTimeInterval, display: Display) {
        if ( bumble.GetFloorLevel() == self.floorLevel ) {
            if ( bumble.GetDirection() == .right && self.direction == .left) {

                // Fire notification that the weapon initially went behind Bumble (probably for scoring).
                if ( !isBehindBumble && self.position.x + (self.size.width / 2.0) < bumble.position.x - (bumble.size.width / 2.0)) {
                    isBehindBumble = true
                    
                    if ( !isTakenOutOfPlay ) {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: EVENT_TYPE.SCORE_WEAPON.rawValue), object: nil)
                    }
                }
                
                // Destroy if it's off screen.
                if ( self.position.x + (self.size.width / 2.0) <= bumble.position.x - (bumble.size.width / 2.0) - (display.sceneSize.width / 4.0)) {
                    self.Destroy()
                }
            }
            
            if ( bumble.GetDirection() == .left && self.direction == .right) {
                
                // Fire notification that the weapon initially went behind Bumble (probably for scoring).
                if ( !isBehindBumble && self.position.x - (self.size.width / 2.0) > bumble.position.x + (bumble.size.width / 2.0)) {
                    isBehindBumble = true
                    
                    if ( !isTakenOutOfPlay ) {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: EVENT_TYPE.SCORE_WEAPON.rawValue), object: nil)
                    }
                }
                
                // Destroy if it's off screen.
                if ( self.position.x - (self.size.width / 2.0) >= bumble.position.x + (bumble.size.width / 2.0) + (display.sceneSize.width / 4.0)) {
                    self.Destroy()
                }
            }
        } else {
            self.Destroy()  // It's on a different floor, so we don't need it anymore since it can't possibly hit Bumble.
        }
    }

    open func Move(_ animationAction: SKAction) {
        self.removeAllActions()
        
        let moveAction = SKAction.moveBy(x: self.velocityPerSecond, y: 0, duration: 1)
        self.run(SKAction.repeatForever(animationAction))
        self.run(SKAction.repeatForever(moveAction))
    }
    
    func Attack(_ firstBody: SKSpriteNode, secondBody: SKSpriteNode) {
        if ( !self.bumble.IsInvincible() ) {
            self.isHidden = true  // Hide the node rather than destroy it (it'll be destroyed later on when it goes off screen).
            self.isTakenOutOfPlay = true
        }
    }
    
    open func Destroy() {
        self.RemovePhysics()
        self.removeFromParent()
    }
    
    open func SetPhysics(_ physicsManager: PhysicsManager) {
        self.physicsManager = physicsManager
    }
    
    open func RemovePhysics() {
        if ( physicsManager != nil ) {
            physicsManager!.RemoveContact(self.name!)
        }
    }
    
    open var BodyType: BODY_TYPE {
        get { return .none }
    }
    
    open func GetVelocityPerSecond() -> CGFloat {
        return self.velocityPerSecond
    }
}
