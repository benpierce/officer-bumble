/*
===============================================================================
Bumble

Encapsulates all of Officer Bumble's animations and control handling.
===============================================================================
*/

import Foundation
import SpriteKit

final class Bumble : SKSpriteNode, PhysicsHandler {
    
    // Constants
    fileprivate let MINIMUM_DUCK_TIME = 0.35            // How long (s) that Bumble should stay ducked when the duck button is pressed.
    fileprivate let HEIGHT_PERCENT = CGFloat(0.375)     // Bumble's height as a percent of the screen.
    fileprivate let WIDTH_PERCENT = CGFloat(0.375)      // Bumble's width as a percent of the screen.
    
    // Velocity Constants
    fileprivate let ESCALATOR_RIDE_TIME : CFTimeInterval = 1    // How long an escalator ride takes.
    
    // Animation Constants
    //private let RUN_FRAME_TIME = 0.045                  // How long each frame of the run animation is.
    //private let RUN_FRAME_TIME = 0.055
    fileprivate let JUMP_FRAME_TIME = 0.0714                // How long each frame of the jump animation is.
    fileprivate let DUCK_FRAME_TIME = 0.055                 // How long each frame of the duck animation is.
    fileprivate let BOWLING_BALL_FALL_FRAME_TIME = 0.041    // How long each bowling ball collision takes.
    fileprivate let PIE_FALL_FRAME_TIME = 0.033             // How long each pie collision takes.
    fileprivate let CHICKENATOR_HIGH_FRAME_TIME = 0.0555    // How long the Chickenator high collision takes.
    fileprivate let CHICKENATOR_LOW_FRAME_TIME = 0.0628     // How long the Chickenator low collision takes.
    fileprivate let TORNADO_FRAME_TIME = 0.05               // How long the tornado animation takes per frame.
    
    fileprivate let BUMBLE_BOUNDING_BOX_PERCENT = CGFloat(0.30)  // % of Bumble's sprite that represents the collidable area on him.
    
    //private var bumbleRunning = Array<SKTexture>()
    fileprivate var bumbleJumping = Array<SKTexture>()
    fileprivate var bumbleDucking = Array<SKTexture>()
    fileprivate var bumbleDuckingComplete = Array<SKTexture>()
    fileprivate var bumbleBowl = Array<SKTexture>()
    fileprivate var bumblePieStart = Array<SKTexture>()
    fileprivate var bumblePieEnd = Array<SKTexture>()
    fileprivate var bumbleChickenatorHigh = Array<SKTexture>()
    fileprivate var bumbleChickenatorLow = Array<SKTexture>()
    fileprivate var bumbleEscalator = Array<SKTexture>()
    fileprivate var tornado1 = Array<SKTexture>()
    fileprivate var tornado2 = Array<SKTexture>()
    
    fileprivate var physicsManager: PhysicsManager?
    
    // Collision Physics Bodies
    fileprivate var standingPhysicsBody: SKPhysicsBody?
    fileprivate var duckingPhysicsBody: SKPhysicsBody?
    fileprivate var jumpingPhysicsBody: SKPhysicsBody?
    
    // Callbacks
    fileprivate var jumpCallback: (() -> ())?
    fileprivate var duckCallback: (() -> ())?
    
    // State related information
    public enum STATE {
        case running
        case jumping
        case ducking
        case ducked_ready_to_run
        case bowling_ball_fall
        case pie_fall
        case chickenator_fall
        case riding_escalator
        case criminal_caught
    }
    
    // Bumble State
    open var currentState : STATE = STATE.running
    fileprivate var floorLevel = 1
    open var direction = DIRECTION.right
    fileprivate var duckTime: CFTimeInterval = 1 //= CACurrentMediaTime()
    fileprivate var invincibilityStartTime : CFTimeInterval = 1 //= CACurrentMediaTime()
    fileprivate var lastVelocityAdjustmentTime : CFTimeInterval = 0
    fileprivate var difficulty: Difficulty?
    
    // Velocity and movement related
    fileprivate var velocity = CGFloat(0)
    open var isStationary = false
    open var cameraEnabled = true
    open var cameraPositionCaptureRequired = false
    fileprivate var escalatorHeight = CGFloat(0)
    open var collisionNode : SKSpriteNode?
    
    // Try to do all setup in here.
    public init(display : Display) {
        let texture = SKTexture(imageNamed: "run1") // Pick any texture.
        
        // Set Bumble's size which will never change.
        let size = display.GetSizeByPercentageOfScene(WIDTH_PERCENT, heightPercent: HEIGHT_PERCENT, considerAspectRatio : true)
        escalatorHeight = display.GetNormalizedScreenHeightByPercentage(0.5)
        cameraPositionCaptureRequired = true
        
        super.init(texture: texture, color: UIColor.clear, size: size)    // After this we can use self.
        InitializeGlobalVars()
        
        collisionNode = SKSpriteNode()
        collisionNode!.size.height = size.height
        collisionNode!.size.width = size.width * BUMBLE_BOUNDING_BOX_PERCENT
        collisionNode!.name = "BumbleCollision"
        self.addChild(collisionNode!)
        
        SetupCollisionBodies()
        super.name = "Bumble"
        
        InitializeTextures()
    }
    
    // Swift 3 doesn't seem to initialize global variables each time, so
    fileprivate func InitializeGlobalVars() {
        currentState = STATE.running
        floorLevel = 1
        direction = DIRECTION.right
        duckTime = 1
        invincibilityStartTime = 1
        lastVelocityAdjustmentTime = 0
        isStationary = false
        cameraEnabled = true
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open var BodyType: BODY_TYPE {
        get { return .bumble }
    }
    
    open func MakeStationary() {
        isStationary = true
    }
    
    open func Update(_ currentTime: CFTimeInterval, isPaused: Bool) {
        // If Bumble is ducking and has already released the duck, and it's not currently playing the ducking animation, 
        // we can go ahead and start running again.
        if ( currentState == .ducked_ready_to_run && !self.hasActions() ) {
            let delta = currentTime - duckTime
            
            if ( delta > MINIMUM_DUCK_TIME ) {
                NotificationCenter.default.post(name: Notification.Name(rawValue: EVENT_TYPE.BUMBLE_DUCK_COMPLETE.rawValue), object: nil)
                Run()
            }
        }
        
        SetVelocity(currentTime, isPaused: isPaused)
    }
    
    fileprivate func SetVelocity(_ currentTime: CFTimeInterval, isPaused: Bool) {
        
        // So that we never skip movement frames!
        if (currentTime - lastVelocityAdjustmentTime) > 0.05 {
            lastVelocityAdjustmentTime = currentTime - 0.05
        } else if (currentTime - lastVelocityAdjustmentTime < 0) {      // To prevent a negative velocity from ever occuring
            lastVelocityAdjustmentTime = currentTime - 0.05
        }
        
        if ( !isPaused ) {
            if ( isStationary ) {
                velocity = 0
            } else {
                if ( currentState == .running || currentState == .jumping ) {
                    if ( velocity < difficulty!.BUMBLE_MAX_VELOCITY_PER_SECOND ) {
                        let delta = currentTime - lastVelocityAdjustmentTime
                        let velocityIncrease = CGFloat(delta / difficulty!.BUMBLE_MAX_VELOCITY_TIME) * difficulty!.BUMBLE_MAX_VELOCITY_PER_SECOND
                        
                        if ( velocity + velocityIncrease > difficulty!.BUMBLE_MAX_VELOCITY_PER_SECOND ) {
                            velocity = difficulty!.BUMBLE_MAX_VELOCITY_PER_SECOND
                        } else {
                            velocity = velocity + velocityIncrease
                        }
                    }
                }
        
                if ( currentState == .ducking || currentState == .ducked_ready_to_run ) {
                    if ( velocity > 0 ) {
                
                        let delta = currentTime - lastVelocityAdjustmentTime
                        let velocityDecrease = CGFloat(delta / difficulty!.BUMBLE_MIN_VELOCITY_TIME) * difficulty!.BUMBLE_MAX_VELOCITY_PER_SECOND
                        if ( velocity - velocityDecrease < 0 ) {
                            velocity = 0
                        } else {
                            velocity = velocity - velocityDecrease
                        }
                    }
                }
            }
        
            if ( currentState != .riding_escalator ) {
                let delta = CGFloat((currentTime - lastVelocityAdjustmentTime)) // Elapsed Seconds
                let trueVelocity = ((direction == .right) ? velocity : -1 * velocity) * delta
                
                self.position.x = self.position.x + trueVelocity
            }
        }
        
        lastVelocityAdjustmentTime = currentTime
    }
    
    open func GetVelocity() -> CGFloat {
        return velocity
    }
    
    // Wire everything up to the input handler and set the difficulty.
    open func Initialize(_ inputManager: InputManager, difficulty: Difficulty) {
        self.difficulty = difficulty
        velocity = difficulty.BUMBLE_MAX_VELOCITY_PER_SECOND
        
        inputManager.RegisterListener(self, aPressedRunBlock: Duck, aReleasedRunBlock: DuckReleased, bPressedRunBlock: Jump, bReleasedRunBlock: DuckReleased)
    }
    
    open func Stop() {
        velocity = 0
    }
    
    fileprivate func BeginAccelerate() {
        lastVelocityAdjustmentTime = CACurrentMediaTime()
    }
    
    fileprivate func BeginDecelerate() {
        lastVelocityAdjustmentTime = CACurrentMediaTime()
    }
    
    func Run() {
        BeginAccelerate()
        currentState = .running
        self.removeAction(forKey: "stateAnimation")
        //let animateAction = SKAction.animateWithTextures(self.bumbleRunning, timePerFrame: RUN_FRAME_TIME)
        //let repeatAction = SKAction.repeatActionForever(animateAction)
        self.run(textureManager.bumbleRunningAction, withKey: "stateAnimation")
        self.collisionNode!.physicsBody = standingPhysicsBody!
    }
    
    func Jump() {
        print("Jump Pushed!")
        
        if(CanJump()) {
            BeginAccelerate()
            currentState = .jumping
            self.removeAction(forKey: "stateAnimation")
            let animateAction = SKAction.animate(with: self.bumbleJumping, timePerFrame: JUMP_FRAME_TIME)
            
            var sequence: SKAction
            let completionBlock = SKAction.run(OnJumpComplete)
            
            if ( self.jumpCallback != nil ) {
                let runBlock = SKAction.run(jumpCallback!)
                sequence = SKAction.sequence([animateAction, runBlock, completionBlock])
            } else {
                sequence = SKAction.sequence([animateAction, completionBlock])
            }
            
            self.run(sequence, withKey: "stateAnimation")
            self.collisionNode!.physicsBody = jumpingPhysicsBody!
            NotificationCenter.default.post(name: Notification.Name(rawValue: EVENT_TYPE.BUMBLE_JUMP.rawValue), object: nil)
        }
    }
    
    func DuckReleased() {
        if ( currentState == .ducking ) {
            currentState = .ducked_ready_to_run
        }
    }
    
    func Duck() {
        if(CanDuck()) {
            BeginDecelerate()
            let duckForTime = MINIMUM_DUCK_TIME - (3 * DUCK_FRAME_TIME) // 3 is the number of duck frames.
            currentState = .ducking
            self.removeAction(forKey: "stateAnimation")
            let animateAction = SKAction.animate(with: self.bumbleDucking, timePerFrame: DUCK_FRAME_TIME)
            let fullyDuckedAnimation = SKAction.animate(with: self.bumbleDuckingComplete, timePerFrame: duckForTime)
            
            var sequence: SKAction
            
            if ( self.duckCallback != nil ) {
                let runBlock = SKAction.run(self.duckCallback!)
                sequence = SKAction.sequence([animateAction, fullyDuckedAnimation, runBlock])
            } else {
                let runBlock = SKAction.run({ })
                sequence = SKAction.sequence([animateAction, fullyDuckedAnimation, runBlock])
            }
            
            self.run(sequence, withKey: "stateAnimation")
            self.collisionNode!.physicsBody = duckingPhysicsBody!
            duckTime = CACurrentMediaTime();
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: EVENT_TYPE.BUMBLE_DUCK.rawValue), object: nil)
        }
    }
    
    func BowlFall(_ firstBody: SKSpriteNode, secondBody: SKSpriteNode) {
        if ( self.CanBeHitInFeet() ) {
            currentState = .bowling_ball_fall
            self.removeAction(forKey: "stateAnimation")
            let animateAction = SKAction.animate(with: self.bumbleBowl, timePerFrame: BOWLING_BALL_FALL_FRAME_TIME)
            let completionBlock = SKAction.run(FinishFall)
            let sequence = SKAction.sequence([animateAction, completionBlock])
            self.run(sequence, withKey: "stateAnimation")
            Stop()
            NotificationCenter.default.post(name: Notification.Name(rawValue: EVENT_TYPE.BUMBLE_FALL_BOWLING_BALL.rawValue), object: nil)
        }
    }
    
    func PieFall(_ firstBody: SKSpriteNode, secondBody: SKSpriteNode) {
        if ( self.CanBeHitInHead() ) {
            currentState = .pie_fall
            self.removeAction(forKey: "stateAnimation")
            let animateActionStart = SKAction.animate(with: self.bumblePieStart, timePerFrame: PIE_FALL_FRAME_TIME)
            let animateActionEnd = SKAction.animate(with: self.bumblePieEnd, timePerFrame: PIE_FALL_FRAME_TIME)
            let runAction = SKAction.run({ NotificationCenter.default.post(name: Notification.Name(rawValue: EVENT_TYPE.BUMBLE_HEADSHAKE.rawValue), object: nil) })
            let completionBlock = SKAction.run(FinishFall)
            
            let sequence = SKAction.sequence([animateActionStart, runAction, animateActionEnd, completionBlock])
        
            self.run(sequence, withKey: "stateAnimation")
            Stop()
            NotificationCenter.default.post(name: Notification.Name(rawValue: EVENT_TYPE.BUMBLE_FALL_PIE.rawValue), object: nil)
        }
    }
    
    func ChickenatorFallHigh(_ firstBody: SKSpriteNode, secondBody: SKSpriteNode) {
        if ( self.CanBeHitInHead() ) {
            currentState = .chickenator_fall
            self.removeAction(forKey: "stateAnimation")
        
            let animation = SKAction.animate(with: self.bumbleChickenatorHigh, timePerFrame: CHICKENATOR_HIGH_FRAME_TIME)
            let completionBlock = SKAction.run(FinishFall)
            let sequence = SKAction.sequence([animation, completionBlock])
            
            self.run(sequence, withKey: "stateAnimation")
            Stop()
        }
    }
    
    func ChickenatorFallLow(_ firstBody: SKSpriteNode, secondBody: SKSpriteNode) {
        if ( self.CanBeHitInFeet() ) {
            currentState = .chickenator_fall
            self.removeAction(forKey: "stateAnimation")
        
            let animation = SKAction.animate(with: self.bumbleChickenatorLow, timePerFrame: CHICKENATOR_LOW_FRAME_TIME)
            let completionBlock = SKAction.run(FinishFall)
            let sequence = SKAction.sequence([animation, completionBlock])
            
            self.run(sequence, withKey: "stateAnimation")
            Stop()
        }
    }
    
    func CanBeHitInHead() -> Bool {
        if ( CanBeHit() && currentState != .ducking && currentState != .ducked_ready_to_run ) {
            return true
        } else {
            return false
        }
    }

    func CanBeHitInFeet() -> Bool {
        if ( CanBeHit() && currentState != .jumping ) {
            return true
        } else {
            return false
        }
    }

    func GetFloorLevel() -> Int {
        return floorLevel
    }

    func GetDirection() -> DIRECTION {
        return direction
    }
    
    open func SetPhysics(_ physicsManager: PhysicsManager) {
        self.physicsManager = physicsManager
        
        // name: String, physicsHandler: PhysicsHandler, bodyType: BODY_TYPE, runBlock: () -> ()
        physicsManager.AddContact(self.collisionNode!.name!, physicsHandler: self, collideAgainstBodyType: BODY_TYPE.bowling_BALL, runBlock: BowlFall)
        physicsManager.AddContact(self.collisionNode!.name!, physicsHandler: self, collideAgainstBodyType: BODY_TYPE.pie, runBlock: PieFall)
        physicsManager.AddContact(self.collisionNode!.name!, physicsHandler: self, collideAgainstBodyType: BODY_TYPE.chickenator_HIGH, runBlock: ChickenatorFallHigh)
        physicsManager.AddContact(self.collisionNode!.name!, physicsHandler: self, collideAgainstBodyType: BODY_TYPE.chickenator_LOW, runBlock: ChickenatorFallLow)
        physicsManager.AddContact(self.collisionNode!.name!, physicsHandler: self, collideAgainstBodyType: BODY_TYPE.escalator, runBlock: EscalatorBegin)
        physicsManager.AddContact(self.collisionNode!.name!, physicsHandler: self, collideAgainstBodyType: BODY_TYPE.criminal, runBlock: CriminalCaughtBegin)
    }
    
    fileprivate func CriminalCaughtBegin(_ firstNode: SKSpriteNode, secondNode: SKSpriteNode) {
        let criminal = ((firstNode.name! == self.collisionNode!.name!) ? secondNode : firstNode)
        
        if ( currentState != .riding_escalator ) {
            criminal.parent!.isHidden = true
        
            self.removeAllActions()
            currentState = .criminal_caught
            velocity = 0
        
            NotificationCenter.default.post(name: Notification.Name(rawValue: EVENT_TYPE.CRIMINAL_CAUGHT.rawValue), object: nil)
            let animate = SKAction.animate(with: tornado1, timePerFrame: TORNADO_FRAME_TIME)
            self.run(animate, completion: CriminalCaughtEnd)
        }
    }
    
    fileprivate func CriminalCaughtEnd() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: EVENT_TYPE.BUMBLE_WINK.rawValue), object: nil)
        let animate = SKAction.animate(with: tornado2, timePerFrame: TORNADO_FRAME_TIME)
        self.run(animate, completion: GameWon)
    }
    
    fileprivate func GameWon() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: EVENT_TYPE.LEVEL_WON.rawValue), object: nil)
    }
    
    fileprivate func SetupCollisionBodies() {
        self.standingPhysicsBody = GetStandingCollisionBody()
        self.duckingPhysicsBody = GetDuckingCollisionBody()
        self.jumpingPhysicsBody = GetJumpingCollisionBody()
    }
    
    fileprivate func EscalatorBegin(_ firstBody: SKSpriteNode, secondBody: SKSpriteNode) {
        let escalator = ((firstBody.name! == self.collisionNode!.name!) ? secondBody : firstBody) as! Escalator
        
        if ( !escalator.bumbleUsed ) {
            NotificationCenter.default.post(name: Notification.Name(rawValue: EVENT_TYPE.BUMBLE_ESCALATOR.rawValue), object: nil)
            cameraEnabled = false
            Stop()
            currentState = .riding_escalator
        
            self.removeAllActions()
            
            let x = escalator.size.width * 0.70 * ((direction == .right) ? 1 : -1)
            let y = escalatorHeight
            let moveTo = SKAction.moveBy(x : x, y: y, duration: 1)
            
            let escalatorAnimation = SKAction.animate(with: self.bumbleEscalator, timePerFrame: 1)
            self.run(escalatorAnimation)
            
            self.run(moveTo, completion: SwitchDirection)
            escalator.bumbleUsed = true
        }
    }
    
    fileprivate func SwitchDirection() {
        floorLevel = floorLevel + 1
        direction = (direction == .left) ? .right : .left
        cameraPositionCaptureRequired = true
        cameraEnabled = true
        self.xScale = fabs(self.xScale) * ((direction == .left) ? -1 : 1 )
        Run()
    }
    
    fileprivate func GetStandingCollisionBody() -> SKPhysicsBody {
        // The bounding box that surrounds Bumble.
        let boundingBox = CGSize(width: size.width * BUMBLE_BOUNDING_BOX_PERCENT, height: size.height * 0.80)
        let center = CGPoint(x: 0, y: -(size.height / 10.0))
        
        let body:SKPhysicsBody = SKPhysicsBody(rectangleOf: boundingBox, center: center)
        body.isDynamic = true
        body.affectedByGravity = false
        body.allowsRotation = false
        body.categoryBitMask = BODY_TYPE.bumble.rawValue //was toRaw() in Xcode 6
        body.collisionBitMask = 0 //if you don't want this body to actually collide with anything
        body.contactTestBitMask = BODY_TYPE.bowling_BALL.rawValue | BODY_TYPE.pie.rawValue | BODY_TYPE.chickenator_HIGH.rawValue | BODY_TYPE.chickenator_LOW.rawValue | BODY_TYPE.escalator.rawValue // was toRaw() in Xcode 6
        
        //body.velocity=CGVectorMake(MAX_VELOCITY, 0)
        //body.linearDamping = 0;
        //body.friction = 0
        
        return body
    }
    
    fileprivate func GetDuckingCollisionBody() -> SKPhysicsBody {
        // The bounding box that surrounds Bumble.
        let boundingBox = CGSize(width: size.width * BUMBLE_BOUNDING_BOX_PERCENT, height: size.height * 0.50)
        let center = CGPoint(x: 0, y: -(size.height / 4.0))
        
        let body:SKPhysicsBody = SKPhysicsBody(rectangleOf: boundingBox, center: center)
        body.isDynamic = true
        body.affectedByGravity = false
        body.allowsRotation = false
        body.categoryBitMask = BODY_TYPE.bumble.rawValue //was toRaw() in Xcode 6
        body.collisionBitMask = 0 //if you don't want this body to actually collide with anything
        body.contactTestBitMask = BODY_TYPE.bowling_BALL.rawValue | BODY_TYPE.pie.rawValue | BODY_TYPE.chickenator_HIGH.rawValue | BODY_TYPE.chickenator_LOW.rawValue | BODY_TYPE.escalator.rawValue // was toRaw() in Xcode 6
        //body.velocity = CGVectorMake(MAX_VELOCITY, 0)
        //body.linearDamping = 0
        //body.friction = 0
        
        return body
    }
    
    fileprivate func GetJumpingCollisionBody() -> SKPhysicsBody {
        // The bounding box that surrounds Bumble.
        let boundingBox = CGSize(width: size.width * BUMBLE_BOUNDING_BOX_PERCENT, height: size.height * 0.50)
        let center = CGPoint(x: 0, y: (size.height / 4.0))
        
        let body:SKPhysicsBody = SKPhysicsBody(rectangleOf: boundingBox, center: center)
        body.isDynamic = true
        body.affectedByGravity = false
        body.allowsRotation = false
        body.categoryBitMask = BODY_TYPE.bumble.rawValue //was toRaw() in Xcode 6
        body.collisionBitMask = 0 //if you don't want this body to actually collide with anything
        body.contactTestBitMask = BODY_TYPE.bowling_BALL.rawValue | BODY_TYPE.pie.rawValue | BODY_TYPE.chickenator_HIGH.rawValue | BODY_TYPE.chickenator_LOW.rawValue | BODY_TYPE.escalator.rawValue | BODY_TYPE.criminal.rawValue // was toRaw() in Xcode 6
        //body.velocity=CGVectorMake(MAX_VELOCITY, 0);
        //body.linearDamping = 0;
        //body.friction = 0
        
        return body
    }
    
    open func RemovePhysics() {
        self.physicsBody = nil
        
        if ( self.physicsManager != nil ) {
            physicsManager!.RemoveContact(self.name!)
        }
    }
    
    fileprivate func FinishFall() {
        invincibilityStartTime = CACurrentMediaTime()
        NotificationCenter.default.post(name: Notification.Name(rawValue: EVENT_TYPE.BUMBLE_RECOVER_FROM_FALL.rawValue), object: nil)
        Run()
    }

    open func IsInvincible() -> Bool {
        let delta: CFTimeInterval = CACurrentMediaTime() - invincibilityStartTime
        
        if ( delta <= difficulty!.BUMBLE_INVINCIBILITY_TIME ) {
            return true
        } else {
            return false
        }
    }
    
    fileprivate func CanBeHit() -> Bool {
        if ( currentState == .running || currentState == .jumping || currentState == .ducking || currentState == .ducked_ready_to_run) {
            
            if ( !IsInvincible() ) {
                return true
            }
        }
        
        return false
    }
    
    fileprivate func CanDuck() -> Bool {
        if(currentState == .jumping || currentState == .running) {
            return true
        } else {
            return false
        }
    }
    
    fileprivate func CanJump() -> Bool {
        if(currentState == .ducking || currentState == .running || currentState == .ducked_ready_to_run) {
            return true
        } else {
            return false
        }
    }
    
    fileprivate func OnJumpComplete() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: EVENT_TYPE.BUMBLE_JUMP_COMPLETE.rawValue), object: nil)
        Run()
    }
    
    fileprivate func InitializeTextures() {
       
        /*
        let i = 0
         
        for i in 1 ... 11 {
            bumbleRunning.append(textureManager.taBumble1.textureNamed("run\(i)"))
        }
        */
        
        //bumbleJumping.append(textureAtlas1.textureNamed("jump1"))
        bumbleJumping.append(textureManager.taBumble1.textureNamed("jump2"))
        bumbleJumping.append(textureManager.taBumble1.textureNamed("jump3"))
        bumbleJumping.append(textureManager.taBumble1.textureNamed("jump3"))
        bumbleJumping.append(textureManager.taBumble1.textureNamed("jump3"))
        bumbleJumping.append(textureManager.taBumble1.textureNamed("jump3"))
        bumbleJumping.append(textureManager.taBumble1.textureNamed("jump3"))
        bumbleJumping.append(textureManager.taBumble1.textureNamed("jump4"))
        
        bumbleDucking.append(textureManager.taBumble1.textureNamed("duck1"))
        bumbleDucking.append(textureManager.taBumble1.textureNamed("duck2"))
        bumbleDucking.append(textureManager.taBumble1.textureNamed("duck3"))
        
        bumbleDuckingComplete.append(textureManager.taBumble1.textureNamed("duck3"))
        
        for i in 1 ... 23 {
            bumbleBowl.append(textureManager.taBumble1.textureNamed("bumblebowl\(i)"))
        }
        
        // Only odd numbers.
        for i in 1 ... 9 {
            bumblePieStart.append(textureManager.taBumble2.textureNamed("cop_FacePie_000\(i)"))
        }
        
        for i in 10 ... 18 {
            bumblePieStart.append(textureManager.taBumble2.textureNamed("cop_FacePie_00\(i)"))
        }
        
        for i in 19 ... 55 {
            bumblePieEnd.append(textureManager.taBumble2.textureNamed("cop_FacePie_00\(i)"))
        }
        
        for i in 6 ... 9 {
            bumbleChickenatorLow.append(textureManager.taBumble1.textureNamed("cop_attacked_by_bird000\(i)"))
        }
        
        for i in 10 ... 23 {
            bumbleChickenatorLow.append(textureManager.taBumble1.textureNamed("cop_attacked_by_bird00\(i)"))
        }
        
        for i in 1 ... 16 {
            bumbleChickenatorHigh.append(textureManager.taBumble1.textureNamed("cop_chicken_swatting_00\(i)"))
        }
        
        bumbleEscalator.append(textureManager.taBumble2.textureNamed("cop_Escalator"))
        
        // Tornado
        // 61 is event frame for blink.
        for i in 1 ... 9 {
            tornado1.append(textureManager.taTornado.textureNamed("80_Tornado_000\(i)"))
        }
        for i in 10 ... 60 {
            tornado1.append(textureManager.taTornado.textureNamed("80_Tornado_00\(i)"))
        }
        for i in 61 ... 80 {
            tornado2.append(textureManager.taTornado.textureNamed("80_Tornado_00\(i)"))
        }        
    }
}
