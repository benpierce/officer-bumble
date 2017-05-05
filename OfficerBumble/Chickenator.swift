/*
===============================================================================
Chickenator

Encapsulates all of a single Chickenator's AI and behavior. Chickenator's are
pretty dim-witted in that they can only follow one pattern:

1. Fly at a fixed velocity (either towards Bumble's head or Bumble's feet).
2. Once it reaches a pre-determined distance from Bumble, it puts its angry face on.
3. Once it gets angry it either drops low or drops high in a pre-determined amount of time.
4. Once dropped, it goes into charge mode and maintains it's angry look. It might speed up slightly at this point
5. If it hits Bumble, it attacks violently and then does a final oscillation to fly off the screen.
6. If it doesn't hit Bumble, it charges until it gets behind Bumble and then does a final oscillation to fly off the screen.
7. Final state is back to its original flying position and velocity until it's removed from the scene.

* Things a Chickenator can Do *
Fly()
Oscillate()
Charge()
Attack()

Note on oscillation:

We need to tell the Chickenator where he should fly to (on the y axis) when we initialize it. We can't simply use
its height as a baseline. Example, when the Robothrower 2000 throws a Chickenator high, it'll start at the throwers
y position. It will end up at the thrower's bottom + chickenator height position. The reverse logic is true for
chickenators that start low.
===============================================================================
*/

import Foundation
import SpriteKit

final class Chickenator : Weapon {
    fileprivate enum STATE {
		case normal
		case initial_OSCILLATION
		case charging
		case final_OSCILLATION
		case attacking
		case finished
	}
    
    // Oscillation Methods.
    public enum CHICKENATOR_POSITION {
        case high
        case low
    }

    fileprivate let MAX_FEATHERS = 8
    
    // Chickenator size and texture data
    fileprivate let WIDTH = CGFloat(0.16)
    fileprivate let HEIGHT = CGFloat(0.16)

    // Chickenator state data
    fileprivate let WARNING_TIME = 0.250                                         // How long is the chickenator warning time in milliseconds?
    fileprivate let ACTIVATION_PROXIMITY_PERCENT_FIXED_OSCILLATING = CGFloat(0.65)                 // How close before warning fires?  In screen %.
    fileprivate let ACTIVATION_PROXIMITY_PERCENT_RANDOM_OSCILLATING = CGFloat(1.0)
    fileprivate let OSCILLATION_COMPLETE_TIME = 0.25
    fileprivate let ACTIVATION_PROXIMITY : CGFloat                               // How close before warning fires?  In pixels.
    fileprivate let FEATHER_CHECK_INTERVAL = 0.1                                 // How often (s) to check for feather throws.
    
    fileprivate var warningStartTime : CFTimeInterval = CACurrentMediaTime()     // When did the warning start?
    fileprivate var oscillationStartTime : CFTimeInterval = CACurrentMediaTime() // Time the oscillation started.
    fileprivate var currentPosition = CHICKENATOR_POSITION.low                   // Is the chickenator high or low?
    fileprivate var collisionPosition = CHICKENATOR_POSITION.low
    fileprivate var oscillationTarget = CGFloat(0.0)                             // Where do we want to oscillate to?
	fileprivate var oscillationStart = CGFloat(0.0)                              // Where did we oscillate from?
    fileprivate var totalOscillation = CGFloat(0.0)                              // Total amount we've oscillated
	fileprivate var currentState = STATE.normal                                  // Chickenator's current state.
    fileprivate var oscillateFrom = CGFloat(0.0)                                 // Where we oscillate from originally.
	fileprivate var oscillateTo = CGFloat(0.0)                                   // Where we oscillate to originally.
    fileprivate var lastFeatherCheck : CFTimeInterval = CACurrentMediaTime()     // Last time we checked if we should throw a feather.
    fileprivate var display : Display
    fileprivate var world : SKSpriteNode?
    fileprivate var featherCount = 0
    fileprivate var isOscillating = false
    fileprivate var supportsRandomOscillating = false       // This was for a spike to see if it was fun to randomize it.
    
    public init(display : Display, floorLevel: Int, direction: DIRECTION, velocity: CGFloat, bumble: Bumble) {
        let texture = textureManager.taCriminal1.textureNamed("chickenator1")
        let size = display.GetSizeByPercentageOfScene(WIDTH, heightPercent: HEIGHT, considerAspectRatio : true)
        self.display = display
        
        if ( supportsRandomOscillating ) {
            let rand = Int.random(1...2)
            if ( rand == 1 ) {
                isOscillating = true
            } else {
                isOscillating = false
            }
        } else {
            isOscillating = true
        }
        
        if ( supportsRandomOscillating ) {
            ACTIVATION_PROXIMITY = display.GetNormalizedScreenWidthByPercentage(ACTIVATION_PROXIMITY_PERCENT_RANDOM_OSCILLATING)
        } else {
            ACTIVATION_PROXIMITY = display.GetNormalizedScreenWidthByPercentage(ACTIVATION_PROXIMITY_PERCENT_FIXED_OSCILLATING)
        }
        
        currentState = .normal
        
        super.init(texture: texture, size: size, floorLevel: floorLevel, direction: direction, velocity: velocity, bumble: bumble, display: display)
        self.zPosition = ZPOSITION.foreground.rawValue
        
        self.name = "Weapon_Chickenator" + UUID().uuidString     // So we can identify later on.
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override var BodyType: BODY_TYPE {
        get {
            if ( collisionPosition == .high ) {
                return BODY_TYPE.chickenator_HIGH
            } else {
                return BODY_TYPE.chickenator_LOW
            }
        }
    }
    
    open override func SetPhysics(_ physicsManager: PhysicsManager) {
        super.SetPhysics(physicsManager)
    
        var headPoint: CGPoint!
        
        if ( super.direction == .left ) {
            headPoint = CGPoint(x: (size.width * -0.3), y: 0)
        } else {
            headPoint = CGPoint(x: (size.width * 0.3), y: 0)
        }
        
        let body1:SKPhysicsBody = SKPhysicsBody(circleOfRadius: size.width / 5.0, center: headPoint )
        body1.isDynamic = true
        body1.affectedByGravity = false
        body1.allowsRotation = false
        body1.contactTestBitMask = BODY_TYPE.bumble.rawValue
        body1.collisionBitMask = 0 //if you don't want this body to actually collide with anything
        
        if ( collisionPosition == .high ) {
            body1.categoryBitMask = BODY_TYPE.chickenator_HIGH.rawValue
        } else {
            body1.categoryBitMask = BODY_TYPE.chickenator_LOW.rawValue
        }
        self.physicsBody = body1
        
        physicsManager.AddContact(self.name!, physicsHandler: self, collideAgainstBodyType: BODY_TYPE.bumble, runBlock: Attack)
        
        self.xScale = (direction == .left) ? 1 : -1
    }
    
    open func Spawn(_ world : SKSpriteNode, initialPosition: CHICKENATOR_POSITION, from : CGFloat, to : CGFloat) {
        // Set some initial variables so we know where we started.
        currentPosition = initialPosition
        
        if ( isOscillating ) {
            collisionPosition = (initialPosition == .high) ? .low : .high
        } else {
            collisionPosition = (initialPosition == .high) ? .high : .low
        }
        
        self.world = world
        
        self.oscillateFrom = from
        self.oscillateTo = to
        
        Fly()
        
        world.addChild(self)
    }
    
    open override func Update(_ currentTime: CFTimeInterval, display: Display) {
        super.Update(currentTime, display: display)
        
        Think(currentTime)
    }
    
    // This method is called every frame and will encapsulate all of the chickenators behavior and state changes.
    fileprivate func Think(_ currentTime: CFTimeInterval) {
        
        // If close to Bumble, go into initial oscillation.
        if( currentState == .normal && floorLevel == bumble.GetFloorLevel() ) {
            if ( isOscillating ) {
                if( super.bumble.GetDirection() == .right && abs(self.position.x - (self.size.width / 2) - super.bumble.position.x + (super.bumble.size.width / 2)) <= ACTIVATION_PROXIMITY ) {
                    currentState = .initial_OSCILLATION
                
                    Oscillate()
                } else if( super.bumble.GetDirection() == .left && abs(super.bumble.position.x - (super.bumble.size.width / 2) - self.position.x +  (self.size.width / 2)) <= ACTIVATION_PROXIMITY) {
                    currentState = .initial_OSCILLATION
                
                    Oscillate()
                }
            }
        } else if ( currentState == .charging ) {
            
            // If it's past Bumble's centerpoint, it can safely do it's final oscillation.
            if ( isOscillating ) {
                if ( ( direction == .left && self.position.x < super.bumble.position.x ) ||
                 ( direction == .right && self.position.x > super.bumble.position.x )
                ) {
                
                    currentState = .final_OSCILLATION
            
                    Oscillate()
                }
            }
        } else if ( currentState == .attacking ) {
            if (currentTime - lastFeatherCheck >= FEATHER_CHECK_INTERVAL) {
                lastFeatherCheck = currentTime
                FeatherCheck()
            }
        }
    }
    
    // Handle all of the Chickenator states
    fileprivate func Fly() {
        self.removeAllActions()
        
        //let animateAction = SKAction.animateWithTextures(self.chickenatorFly, timePerFrame: CHICKENATOR_FLY_FRAME_TIME)
        let moveAction = SKAction.moveBy(x: super.GetVelocityPerSecond(), y: 0, duration: 1)
        
        //self.runAction(SKAction.repeatActionForever(animateAction))
        self.run(textureManager.chickenatorFlyAction)
        self.run(SKAction.repeatForever(moveAction))
    }

    override func Attack(_ firstBody: SKSpriteNode, secondBody: SKSpriteNode) {
        
        
        
        if ( !super.bumble.IsInvincible() && !self.isTakenOutOfPlay ) {
            self.removeAllActions()
            currentState = .attacking
            self.isTakenOutOfPlay = true   // So that it doesn't count towards your score later.
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: EVENT_TYPE.BUMBLE_FALL_CHICKENATOR.rawValue), object: nil)
        
            if ( currentPosition == .high ) {
                self.run(textureManager.chickenatorAttackHighAction, completion: Oscillate)
            } else {
                self.run(textureManager.chickenatorAttackLowAction, completion: Oscillate)
            }
        }
    }
    
    func FeatherCheck() {
        // 75% chance of throwing a feather
        let num = Int.random(1...4)
        if ( num <= 3 && featherCount < MAX_FEATHERS) {
            let feather = Feather(chickenator: self, display: display)
            world!.addChild(feather)
            featherCount += 1
        }
    }
    
    fileprivate func Oscillate() {
        self.removeAllActions()
        
        let targetY = self.oscillateTo
        if ( currentPosition == .high ) {
            currentPosition = .low
        } else {
            currentPosition = .high
        }
        
        // Swap oscillation levels.
        self.oscillateTo = self.oscillateFrom
        self.oscillateFrom = targetY
        
        let moveByX = super.GetVelocityPerSecond() * CGFloat(OSCILLATION_COMPLETE_TIME)
        let moveByY = targetY - self.position.y
        
        //let oscillateAction = SKAction.moveTo(CGPoint(x: targetX, y : targetY), duration: Double(OSCILLATION_COMPLETE_TIME))
        let oscillateAction = SKAction.moveBy(x: moveByX, y: moveByY, duration: Double(OSCILLATION_COMPLETE_TIME))
        self.run(textureManager.chickenatorAngryAction)
        //self.texture = self.chickenatorAngry[0]

        if ( currentState == .initial_OSCILLATION ) {
            self.run(oscillateAction, completion: Charge)
        } else {
            self.run(oscillateAction, completion: Fly)
        }
    }
 
    fileprivate func Charge() {
        self.removeAllActions()
        currentState = .charging
        
        // Move Chickenator indefinitely.
        //let animateAction = SKAction.animateWithTextures(self.chickenatorAngry, timePerFrame: CHICKENATOR_ANGRY_FRAME_TIME)
        let moveAction = SKAction.moveBy(x: super.GetVelocityPerSecond(), y: 0, duration: 1)
        
        // Repeat Forever
        self.run(textureManager.chickenatorAngryAction)
        //self.runAction(SKAction.repeatActionForever(animateAction))
        self.run(SKAction.repeatForever(moveAction))
    }

    func GetCollisionPosition() -> CHICKENATOR_POSITION {
        return collisionPosition
    }
}
