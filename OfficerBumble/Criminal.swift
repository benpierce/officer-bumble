/*
===============================================================================
Criminal

Encapsulates all of the Criminal's animations and control handling.
===============================================================================
*/

import Foundation
import SpriteKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


final class Criminal : SKSpriteNode, PhysicsHandler {

    fileprivate let HEIGHT_PERCENT = CGFloat(0.375)     // Criminal's height as a percent of the screen.
    fileprivate let WIDTH_PERCENT = CGFloat(0.375)      // Criminal's width as a percent of the screen.
    
    fileprivate let ESCALATOR_RIDE_TIME : CFTimeInterval = 1    // How long an escalator ride takes.
    fileprivate let CRIMINAL_BOUNDING_BOX_PERCENT = CGFloat(0.40)  // % of Bumble's sprite that represents the collidable area on him.
    fileprivate let MINIMUM_ATTACK_QUEUE_TIME = 0.25            // How long between attack queues?
    fileprivate let MUST_ATTACK_TIME = Double(2.0)                // The maximum time before the criminal HAS to throw something.
    fileprivate let ATTACK_CHECK_LENGTH = Double(0.5)            // How often does the criminal check to do new attacks?
    fileprivate var MINIMUM_CHICKENATOR_DISTANCE = CGFloat(0)  // The minimum distance criminal can throw a chickenator.
    fileprivate let SPEED_BOOST_ADVANTAGE = CGFloat(0.35)      // Boost in velocity when in second wind.
    fileprivate var physicsManager: PhysicsManager?
    
    fileprivate var floorLevel = 1
    open var direction = DIRECTION.right
    
    fileprivate var criminalRunning = Array<SKTexture>()
    fileprivate var criminalEscalator = Array<SKTexture>()
    fileprivate var criminalYikes = Array<SKTexture>()
    fileprivate var criminalBowl1 = Array<SKTexture>()
    fileprivate var criminalBowl2 = Array<SKTexture>()
    fileprivate var criminalPie1 = Array<SKTexture>()
    fileprivate var criminalPie2 = Array<SKTexture>()
    fileprivate var criminalChickenHigh1 = Array<SKTexture>()
    fileprivate var criminalChickenHigh2 = Array<SKTexture>()
    fileprivate var criminalChickenLow = Array<SKTexture>()
    fileprivate var criminalLaugh1 = Array<SKTexture>()
    fileprivate var criminalLaugh2 = Array<SKTexture>()
    fileprivate var criminalSecondWind = Array<SKTexture>()
    
    // Animation Constants
    //private let RUN_FRAME_TIME = 0.0476
    fileprivate let YIKES_FRAME_TIME = 0.03125
    //private let BOWLING_FRAME_TIME = 0.04
    //private let PIE_FRAME_TIME = 0.030
    fileprivate let CHICKENATOR_HIGH_FRAME_TIME = 0.04
    fileprivate let PIE_FRAME_TIME = 0.035
    fileprivate let BOWLING_FRAME_TIME = 0.035
    //private let BOWLING_FRAME_TIME = 0.035
    fileprivate let CHICKENATOR_LOW_FRAME_TIME = 0.04
    fileprivate let LAUGH_FRAME_TIME1 = 0.0357
    fileprivate let LAUGH_FRAME_TIME2 = 0.05
    fileprivate let SECOND_WIND_FRAME_TIME = 0.0416
    
    // State Variables
    open var currentState : STATE = STATE.running
    fileprivate var bumbleBecameClose = false
    fileprivate var attackPatternGenerator : AttackPatternGenerator?
    fileprivate var attacks = Stack<CRIMINAL_WEAPON>()
    fileprivate var bumbleDistance = CGFloat(0)
    fileprivate var bumbleLevel: Int = 0
    fileprivate var hasAttacked = false
    fileprivate var secondWinds: Int = 0
    fileprivate var secondWindsFloor1: Int = 0
    fileprivate var secondWindsFloor2: Int = 0
    fileprivate var secondWindsFloor3: Int = 0
    fileprivate var secondWindsFloor4: Int = 0
    fileprivate var slowDownPercentage = CGFloat(1.0)        // What % of the regular velocity should criminal drop to on 4th floor?
    
    // Velocity related values.
    fileprivate var velocity = CGFloat(0)
    fileprivate var originalVelocity = CGFloat(0)
    fileprivate var maxiumumWeaponVelocity = CGFloat(2)
    fileprivate var escalatorHeight = CGFloat(0)
    fileprivate var collisionNode : SKSpriteNode?
    fileprivate var lastVelocityAdjustmentTime : CFTimeInterval = 0
    fileprivate var lastAttackTime : CFTimeInterval = 0
    fileprivate var lastAttackCheck : CFTimeInterval = 0
    fileprivate var secondWindStartTime: CFTimeInterval = 0
    
    // References so he can spawn weapons
    fileprivate var world: SKSpriteNode?
    fileprivate var display: Display
    fileprivate var bumble: Bumble?
    fileprivate var difficulty: Difficulty?
    
    // State related information
    public enum STATE {
        case running
        case riding_escalator
        case yikes
        case laughing
        case attacking
        case second_WIND
        case criminal_caught
    }
    
    // Try to do all setup in here.
    public init(display : Display) {
        let texture = SKTexture(imageNamed: "crook_sequence_run0001") // Pick any texture.
        self.display = display
        
        // Set Bumble's size which will never change.
        let size = display.GetSizeByPercentageOfScene(WIDTH_PERCENT, heightPercent: HEIGHT_PERCENT, considerAspectRatio : true)
        
        // Difficulty Config
        MINIMUM_CHICKENATOR_DISTANCE = display.GetNormalizedScreenWidthByPercentage(0.95)
        escalatorHeight = display.GetNormalizedScreenHeightByPercentage(0.5)
        
        super.init(texture: texture, color: UIColor.clear, size: size)    // After this we can use self.
        
        collisionNode = SKSpriteNode()
        collisionNode!.size.height = size.height
        collisionNode!.size.width = size.width * CRIMINAL_BOUNDING_BOX_PERCENT
        collisionNode!.name = "CriminalCollision"
        self.addChild(collisionNode!)
        
        SetupCollisionBodies()
        super.name = "Criminal"
        
        InitializeTextures()
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open var BodyType: BODY_TYPE {
        get { return .criminal }
    }
    
    func GetFloorLevel() -> Int {
        return floorLevel
    }
    
    func GetDirection() -> DIRECTION {
        return direction
    }
    
    func Hide() {
        velocity = 0
        self.isHidden = true
    }
    
    func Run() {
        currentState = .running
        velocity = originalVelocity
        self.removeAction(forKey: "stateAnimation")
        //let animateAction = SKAction.animateWithTextures(self.criminalRunning, timePerFrame: RUN_FRAME_TIME)
        //let repeatAction = SKAction.repeatActionForever(animateAction)
        self.run(textureManager.criminalRunningAction, withKey: "stateAnimation")
    }
    
    fileprivate func Yikes(_ bumble: Bumble) {
        if ( CanYikes(bumble) ) {
            currentState = .yikes
            self.removeAction(forKey: "stateAnimation")
            let animateAction = SKAction.animate(with: self.criminalYikes, timePerFrame: YIKES_FRAME_TIME)
            let completionAction = SKAction.run(SecondWind)
            let sequence = SKAction.sequence([animateAction, completionAction])
            self.run(sequence, withKey: "stateAnimation")
            NotificationCenter.default.post(name: Notification.Name(rawValue: EVENT_TYPE.CRIMINAL_YIKES.rawValue), object: nil)
        }
    }
    
    fileprivate func SecondWind() {
        if( CanSecondWind() ) {
            currentState = .second_WIND
            
            // Decrement the # of second winds allowed.
            secondWinds = secondWinds + 1
            if ( floorLevel == 1 ) {
                secondWindsFloor1 = secondWindsFloor1 + 1
            } else if ( floorLevel == 2 ) {
                secondWindsFloor2 = secondWindsFloor2 + 1
            } else if ( floorLevel == 3 ) {
                secondWindsFloor3 = secondWindsFloor3 + 1
            } else if ( floorLevel == 4 ) {
                secondWindsFloor4 = secondWindsFloor4 + 1
            }
            
            var newVelocity = CGFloat(0)
            
            if ( bumble != nil ) {
                newVelocity = bumble!.GetVelocity() + display.GetNormalizedScreenWidthByPercentage(SPEED_BOOST_ADVANTAGE)
            } else {
                newVelocity = velocity + display.GetNormalizedScreenWidthByPercentage(SPEED_BOOST_ADVANTAGE)
            }
            
            secondWindStartTime = CACurrentMediaTime()
            self.removeAction(forKey: "stateAnimation")
            let animateAction = SKAction.animate(with: self.criminalSecondWind, timePerFrame: SECOND_WIND_FRAME_TIME)
            let repeatAction = SKAction.repeatForever(animateAction)
            self.velocity = newVelocity
            self.run(repeatAction)
            NotificationCenter.default.post(name: Notification.Name(rawValue: EVENT_TYPE.CRIMINAL_SECOND_WIND.rawValue), object: nil)
        } else {
            Run()
        }
    }
    
    // Check to see if we're close enough to do a YIKES!
    fileprivate func CanYikes(_ bumble: Bumble) -> Bool {
        var yikes = false
        
        // Have to be on the same floor level.
        if ( bumble.GetFloorLevel() == self.GetFloorLevel() ) {
            if ( currentState == .running ) {
                if ( bumbleDistance <= difficulty!.CRIMINAL_SECOND_WIND_DISTANCE ) {
                    if ( !bumbleBecameClose ) {
                        bumbleBecameClose = true
                        yikes = true
                    }
                } else {
                    bumbleBecameClose = false
                }
                
            }
        }
        
        return yikes
     }
    
    // Calculates how far Bumble is away from the criminal.
    // Note that we're using the CollisionNode of each object, otherwise the transparent portions of
    // the sprites will mess up the %'s and 0% won't look like 0%.
    fileprivate func CalculateBumbleDistance(_ bumble: Bumble) -> CGFloat {
        var result = CGFloat(0)
        
        let world = self.parent!
        let criminalPositionX = world.convert(self.collisionNode!.position, from: self).x
        let bumblePositionX = world.convert(bumble.collisionNode!.position, from: bumble).x
        
        if ( bumblePositionX >= criminalPositionX ) {
            let criminalX = criminalPositionX + (self.collisionNode!.size.width / 2)
            let bumbleX = bumblePositionX - (bumble.collisionNode!.size.width / 2)
            
            result = bumbleX - criminalX
        } else {
            let criminalX = criminalPositionX - (self.collisionNode!.size.width / 2)
            let bumbleX = bumblePositionX + (bumble.collisionNode!.size.width / 2)
            
            result = criminalX - bumbleX
        }
        
        return result
    }
    
    open func Update(_ currentTime: CFTimeInterval, bumble: Bumble, maximumWeaponVelocity: CGFloat, isPaused: Bool) {
        // We need some info about Bumble.
        bumbleDistance = CalculateBumbleDistance(bumble)
        bumbleLevel = bumble.GetFloorLevel()
        if ( bumble.currentState == .criminal_caught )  {
            currentState = .criminal_caught
        }
        
        self.maxiumumWeaponVelocity = maximumWeaponVelocity
        
        SetVelocity(currentTime, isPaused: isPaused)
        Yikes(bumble)
        AttackIfPossible(currentTime)
        HandleMocking()
        SecondWindCheck(currentTime)
    }
    
    fileprivate func SecondWindCheck(_ currentTime: CFTimeInterval) {
        let delta = currentTime - secondWindStartTime
        if ( currentState == .second_WIND && delta > difficulty!.CRIMINAL_SECOND_WIND_DURATION ) {
            self.velocity = self.originalVelocity
            Run()
        }
    }
    
    fileprivate func SetVelocity(_ currentTime: CFTimeInterval, isPaused: Bool) {
        
        // So that we never skip movement frames!
        if (currentTime - lastVelocityAdjustmentTime) > 0.05 {
            lastVelocityAdjustmentTime = currentTime - 0.05
        }
        
        if ( !isPaused ) {
            if ( currentState != .riding_escalator && currentState != .criminal_caught ) {
                let delta = CGFloat((currentTime - lastVelocityAdjustmentTime)) // Elapsed Seconds
                let moveByX = GetFinalVelocity() * delta
                
                self.position.x = self.position.x + moveByX
            }
        }
        
        lastVelocityAdjustmentTime = currentTime
    }
    
    /*
        On easy or normal modes, we want to ensure that if the criminal is more than one screen away from Bumble (IE: you can't see
        him), he'll reduce his velocity to 75% of his maximum so that you have a fair chance to catch up to him.
    */
    fileprivate func GetFinalVelocity() -> CGFloat {
        let actualVelocity = ((direction == DIRECTION.right) ? velocity : -1 * velocity)
        
        // On easy and normal, if the criminal is off screen we should give the player a chance to catch up.
        if((difficulty!.DifficultyName == "Easy" || difficulty!.DifficultyName == "Normal") && bumbleDistance > display.sceneSize.width)
        {
            return actualVelocity * 0.70
        } else if ( floorLevel == 4 ) {
            return actualVelocity * slowDownPercentage    // Criminal slows down on the last floor.
        } else {
            return actualVelocity
        }
    }
    
    // On easy difficulty, the criminal will stop and mock Bumble if he gets too far ahead. Once Bumble catches up a bit, the criminal
    // will take off again. This ensures that on easy the criminal is always catchable no matter how bad you play.
    fileprivate func HandleMocking() {
        if ( difficulty!.CRIMINAL_ALLOW_MOCKING && currentState != .laughing && currentState != .riding_escalator) {
            if ( bumbleDistance >= difficulty!.CRIMINAL_MOCKING_DISTANCE ) {
                currentState = .laughing
                attacks.clear()
                velocity = 0
                Laugh()
            }
        } else if ( currentState == .laughing) {
            if ( bumbleDistance < difficulty?.CRIMINAL_MOCKING_DISTANCE_END ) {
                Run()
            }
        }
    }
    
    fileprivate func Laugh() {
        self.removeAllActions()
        let startLaughAction = SKAction.animate(with: criminalLaugh1, timePerFrame: LAUGH_FRAME_TIME1)
        let loopingLaughAction = SKAction.animate(with: criminalLaugh2, timePerFrame: LAUGH_FRAME_TIME2)
        let repeatAction = SKAction.repeatForever(loopingLaughAction)
        let sequence = SKAction.sequence([startLaughAction, repeatAction])
        self.run(sequence)
    }
    
    fileprivate func EscalatorBegin(_ firstBody: SKSpriteNode, secondBody: SKSpriteNode) {
        let escalator = ((firstBody.name! == self.collisionNode!.name!) ? secondBody : firstBody) as! Escalator
        
        if ( !escalator.criminalUsed && currentState != .criminal_caught ) {
            currentState = .riding_escalator
            
            attacks.clear();	// We don't anything hanging out in the queue when we get off the escalator.
            self.removeAllActions()
            
            let x = escalator.size.width * 0.70 * ((direction == .right) ? 1 : -1)
            let y = escalatorHeight
            let moveTo = SKAction.moveBy(x : x, y: y, duration: 1)
            
            let escalatorAnimation = SKAction.animate(with: self.criminalEscalator, timePerFrame: 1)
            self.run(escalatorAnimation)
            
            self.run(moveTo, completion: SwitchDirection)
            escalator.criminalUsed = true
        }
    }
    
    fileprivate func SwitchDirection() {
        floorLevel = floorLevel + 1
        direction = (direction == .left) ? .right : .left
        self.xScale = fabs(self.xScale) * ((direction == .left) ? -1 : 1 )
        Run()
    }
    
    // Determine which attack to perform and then add it to the queue based on the attack pattern generator.
    fileprivate func QueueAttack(_ currentTime: TimeInterval) {
        if(currentTime - lastAttackTime > MINIMUM_ATTACK_QUEUE_TIME) {
            let attackQueue = attackPatternGenerator!.GenerateAttackPattern(CanThrowChickenator());
            
            for item in attackQueue {
                attacks.push(item)
            }
        }
    }
    
    // If there's anything in the queue, and we've waited the minimum amount of time since the last attack, then
    // perform the attack.
    fileprivate func AttackIfPossible(_ currentTime: TimeInterval) {
    
            // If the criminal can do a new attack, we can queue more attack patterns.
            if( CanQueueAttack()) {
                
                // Every 1 second, we check to see if we should add more items to the attack queue.
				if(currentTime - lastAttackCheck >= ATTACK_CHECK_LENGTH) {
                    lastAttackCheck = currentTime
                    
                    // If the criminal hasn't thrown anything in the first 2 seconds of the game, we need to force him to 
                    // throw something so that he isn't just caught without putting up a fight.
                    var mustAttack = false
                    if ( !hasAttacked && currentTime - lastAttackTime > MUST_ATTACK_TIME) {
                        mustAttack = true
                        hasAttacked = true
                    }
                    
                    // In normal circumstances, we roll the die to see if the criminal should queue something up.
                    let randomNum = Double.random(0, max: 1)
    
                    if(randomNum <= difficulty!.CRIMINAL_ATTACK_PERCENTAGE || mustAttack) {
                        QueueAttack(currentTime)
                    }
                }
            }
        
            // If there's anything in the attack queue, then attack if it's been the minimum
            // cooldown after the last attack.
            if(attacks.size() > 0 && currentState == .running && bumbleDistance >= difficulty!.CRIMINAL_SECOND_WIND_DISTANCE) {
                if(currentTime - lastAttackTime > difficulty!.CRIMINAL_MIN_TIME_BETWEEN_ATTACKS) {
                    let weapon = attacks.peek()
                    
                    if(weapon == CRIMINAL_WEAPON.chickenator_HIGH){
                        if(CanThrowChickenator()) {
                            ThrowChickenatorHigh()
                        } else {
                            _ = attacks.pop()
                        }
                    }
                    else if (weapon == CRIMINAL_WEAPON.chickenator_LOW) {
                        if(CanThrowChickenator()) {
                            ThrowChickenatorLow()
                        } else {
                            _ = attacks.pop()
                        }
                    }
                    else if(weapon == CRIMINAL_WEAPON.pie){
                        ThrowPie()
                    }
                    else if(weapon == CRIMINAL_WEAPON.bowling_BALL){
                        ThrowBowlingBall()
                    }
                }
            }
    }
    
    /*
    ===============================================================================
    CanQueueAttack()
    
    The criminal is only allowed to add new items to his attack queue if:
       - They're on the same floor level.
       - The attack queue is currently empty.
       - He's currently in the running state.
       - He's far enough from Bumble to make it fair.
    ===============================================================================
    */
    fileprivate func CanQueueAttack() -> Bool {
        return (floorLevel == bumbleLevel && attacks.size() == 0 && currentState == .running && bumbleDistance >= difficulty!.CRIMINAL_SECOND_WIND_DISTANCE)
    }
    
    fileprivate func ThrowChickenatorLow() {
        // This animation is continuous
        self.removeAllActions()
        currentState = .attacking
        
        let animation = SKAction.animate(with: criminalChickenLow, timePerFrame: CHICKENATOR_LOW_FRAME_TIME)
        let weaponVelocity = GetWeaponVelocity(CRIMINAL_WEAPON.chickenator_LOW)
        let runAction = SKAction.run({ self.SpawnChickenatorLow(weaponVelocity); _ = self.attacks.pop(); self.lastAttackTime = CACurrentMediaTime() })
        let completion = SKAction.run(Run)
        let sequence = SKAction.sequence([animation, runAction, completion])
        self.run(sequence)
    }
    
    fileprivate func ThrowChickenatorHigh() {
        // This animation is broken into two.
        self.removeAllActions()
        currentState = .attacking
 
        let animation = SKAction.animate(with: criminalChickenHigh1, timePerFrame: CHICKENATOR_HIGH_FRAME_TIME)
        let weaponVelocity = GetWeaponVelocity(CRIMINAL_WEAPON.chickenator_HIGH)
        let runAction = SKAction.run( { self.SpawnChickenatorHigh(weaponVelocity); _ = self.attacks.pop(); self.lastAttackTime = CACurrentMediaTime() })
        let animation2 = SKAction.animate(with: criminalChickenHigh2, timePerFrame: CHICKENATOR_HIGH_FRAME_TIME)
        let completion = SKAction.run(Run)
        let sequence = SKAction.sequence([animation, runAction, animation2, completion])
        self.run(sequence)
    }
    
    fileprivate func ThrowPie() {
        // This animation is broken into two.
        self.removeAllActions()
        currentState = .attacking
        
        let animation = SKAction.animate(with: criminalPie1, timePerFrame: PIE_FRAME_TIME)
        let weaponVelocity = GetWeaponVelocity(CRIMINAL_WEAPON.pie)
        let runAction = SKAction.run( { self.SpawnPie(weaponVelocity); _ = self.attacks.pop(); self.lastAttackTime = CACurrentMediaTime() })
        let animation2 = SKAction.animate(with: criminalPie2, timePerFrame: PIE_FRAME_TIME)
        let completion = SKAction.run(Run)
        let sequence = SKAction.sequence([animation, runAction, animation2, completion])
        self.run(sequence)
    }
    
    fileprivate func ThrowBowlingBall() {
        // This animation is broken into two.
        self.removeAllActions()
        currentState = .attacking
        
        let animation = SKAction.animate(with: criminalBowl1, timePerFrame: BOWLING_FRAME_TIME)
        let weaponVelocity = GetWeaponVelocity(CRIMINAL_WEAPON.bowling_BALL)
        let runAction = SKAction.run( { self.SpawnBowlingBall(weaponVelocity); _ = self.attacks.pop(); self.lastAttackTime = CACurrentMediaTime() })
        let animation2 = SKAction.animate(with: criminalBowl2, timePerFrame: BOWLING_FRAME_TIME)
        let completion = SKAction.run(Run)
        let sequence = SKAction.sequence([animation, runAction, animation2, completion])
        self.run(sequence)
    }
    
    fileprivate func GetWeaponDirection() -> DIRECTION {
        return (direction == .left) ? .right : .left
    }
    
    fileprivate func SpawnChickenatorHigh(_ velocity: CGFloat) {
        let chickenator = Chickenator(display : display, floorLevel: self.floorLevel, direction: GetWeaponDirection(), velocity: velocity, bumble: bumble!)
        var x: CGFloat
        
        if ( direction == .right ) {
            x = self.position.x - (self.size.width / 2) + (chickenator.size.width / 2)
        } else {
            x = self.position.x + (self.size.width / 2) - (chickenator.size.width / 2)
        }
        
        let oscillateFrom = CGFloat((self.position.y) + (chickenator.size.height / 1.5))
        let oscillateTo = CGFloat((self.position.y) - (self.size.height / 2) + (chickenator.size.height / 2))
        
        chickenator.position = CGPoint(x: x, y: oscillateFrom)
        chickenator.Spawn(world!, initialPosition : .high, from: oscillateFrom, to: oscillateTo)
        chickenator.SetPhysics(physicsManager!)
    }
    
    fileprivate func SpawnChickenatorLow(_ velocity: CGFloat) {
        let chickenator = Chickenator(display: display, floorLevel: floorLevel, direction: GetWeaponDirection(), velocity: velocity, bumble: bumble!)
        var x: CGFloat
        
        if ( direction == .right ) {
           x = self.position.x - (self.size.width / 2) + (chickenator.size.width / 2)
        } else {
           x = self.position.x + (self.size.width / 2) - (chickenator.size.width / 2)
        }
        
        let oscillateFrom = CGFloat((self.position.y) - (self.size.height / 2) + (chickenator.size.height / 2))
        let oscillateTo = CGFloat((self.position.y) + (chickenator.size.height / 1.5))
        
        chickenator.position = CGPoint(x: x, y: oscillateFrom)
        chickenator.Spawn(world!, initialPosition : .low, from: oscillateFrom, to: oscillateTo)
        chickenator.SetPhysics(physicsManager!)
    }
    
    fileprivate func SpawnPie(_ velocity: CGFloat) {
        let pie = Pie(display: display, floorLevel: floorLevel, direction: GetWeaponDirection(), velocity: velocity, bumble: bumble!)
        var x: CGFloat
        var y: CGFloat
        
        y = self.position.y + (self.size.height / 2) - (pie.size.height / 2)
        if ( direction == .right ) {
           x = self.position.x - (self.size.width / 2) + (pie.size.width / 4) //+ (pie.size.width / 1.5)
        } else {
           x = self.position.x + (self.size.width / 2) - (pie.size.width / 4) //- (pie.size.width / 1.5)
        }
        
        pie.position = CGPoint(x: x, y: y)
        
        pie.SetPhysics(physicsManager!)
        pie.Spawn(world!, display: display)
    }
    
    fileprivate func SpawnBowlingBall(_ velocity: CGFloat) {
        let bowlingBall = BowlingBall(display: display, floorLevel: floorLevel, direction: GetWeaponDirection(), velocity: velocity, bumble: bumble!)
        var x: CGFloat
        var y: CGFloat
        
        y = self.position.y - (self.size.height / 2) + (bowlingBall.size.height / 2)
        if ( direction == .right ) {
            x = self.position.x - (self.size.width / 2) + (bowlingBall.size.width * 0.7)
        } else {
            x = self.position.x + (self.size.width / 2) - (bowlingBall.size.width * 0.7)
        }
        
        bowlingBall.position = CGPoint(x: x, y: y)
        
        bowlingBall.SetPhysics(physicsManager!)
        bowlingBall.Spawn(world!, display: display)
    }
    
    fileprivate func CanThrowChickenator() -> Bool {
        return (bumbleDistance <= MINIMUM_CHICKENATOR_DISTANCE) || (difficulty!.CRIMINAL_CHICKENATOR_ATTACK_PERCENTAGE == 0.0) ? false : true;
    }
    
    open func Initialize(_ world: SKSpriteNode, physicsManager: PhysicsManager, bumble: Bumble, difficulty: Difficulty) {
        self.world = world
        self.physicsManager = physicsManager
        self.bumble = bumble
        self.difficulty = difficulty
        
        velocity = self.difficulty!.CRIMINAL_VELOCITY_PER_SECOND
        originalVelocity = velocity
        attackPatternGenerator = AttackPatternGenerator(maxWeaponsAllowedInAttack: self.difficulty!.CRIMINAL_MAX_WEAPONS_IN_QUEUE, chickenatorAttackPercentage: self.difficulty!.CRIMINAL_CHICKENATOR_ATTACK_PERCENTAGE, bowlingBallAttackPercentage: self.difficulty!.CRIMINAL_BOWLING_BALL_ATTACK_PERCENTAGE, pieAttackPercentage: self.difficulty!.CRIMINAL_PIE_ATTACK_PERCENTAGE)
        
        lastVelocityAdjustmentTime = CACurrentMediaTime()
        lastAttackTime = CACurrentMediaTime()
        
        switch ( difficulty.DifficultyName.uppercased() ) {
            case "EASY":
                slowDownPercentage = 1.0
            case "NORMAL":
                slowDownPercentage = 1.0
            case "HARD":
                slowDownPercentage = 1.0
            default:
                slowDownPercentage = 1.0
        }
    }
    
    open func SetPhysics(_ physicsManager: PhysicsManager) {
        self.physicsManager = physicsManager
        
        // name: String, physicsHandler: PhysicsHandler, bodyType: BODY_TYPE, runBlock: () -> ()
        //physicsManager.AddContact(self.collisionNode!.name!, physicsHandler: self, collideAgainstBodyType: BODY_TYPE.BUMBLE, runBlock: Nothing)
        physicsManager.AddContact(self.collisionNode!.name!, physicsHandler: self, collideAgainstBodyType: BODY_TYPE.escalator, runBlock: EscalatorBegin)
        physicsManager.AddContact(self.collisionNode!.name!, physicsHandler: self, collideAgainstBodyType: BODY_TYPE.exit, runBlock: Escaped)
    }
    
    // Escaping basically involves completely stopping the criminal and then him laughing (which also notifies 
    // the Level Scene to handle the rest of it).
    fileprivate func Escaped(_ firstBody: SKSpriteNode, secondBody: SKSpriteNode) {
        self.velocity = 0
        NotificationCenter.default.post(name: Notification.Name(rawValue: EVENT_TYPE.CRIMINAL_ESCAPE.rawValue), object: nil)
    }
    
    fileprivate func SetupCollisionBodies() {
        self.collisionNode!.physicsBody = GetStandingCollisionBody()
    }
    
    fileprivate func GetStandingCollisionBody() -> SKPhysicsBody {
        // The bounding box that surrounds Criminal.
        let boundingBox = CGSize(width: size.width * CRIMINAL_BOUNDING_BOX_PERCENT, height: size.height * 0.80)
        let center = CGPoint(x: 0, y: -(size.height / 10.0))
        
        let body:SKPhysicsBody = SKPhysicsBody(rectangleOf: boundingBox, center: center)
        body.isDynamic = true
        body.affectedByGravity = false
        body.allowsRotation = false
        body.categoryBitMask = BODY_TYPE.criminal.rawValue //was toRaw() in Xcode 6
        body.collisionBitMask = 0 //if you don't want this body to actually collide with anything
        body.contactTestBitMask = BODY_TYPE.bumble.rawValue | BODY_TYPE.escalator.rawValue | BODY_TYPE.exit.rawValue
        
        return body
    }
    
    open func RemovePhysics() {
        self.physicsBody = nil
        
        if ( self.physicsManager != nil ) {
            physicsManager!.RemoveContact(self.name!)
        }
    }
    
    fileprivate func GetWeaponVelocity(_ type: CRIMINAL_WEAPON) -> CGFloat {
        var velocity = CGFloat(0)
        var minVelocity = CGFloat(0)
        var maxVelocity = CGFloat(0)
        
        if(type == .pie) {
            minVelocity = difficulty!.CRIMINAL_PIE_VELOCITY_PER_SECOND_MIN
            maxVelocity = difficulty!.CRIMINAL_PIE_VELOCITY_PER_SECOND_MAX
        } else if (type == .bowling_BALL) {
            minVelocity = difficulty!.CRIMINAL_BOWLING_BALL_VELOCITY_PER_SECOND_MIN
            maxVelocity = difficulty!.CRIMINAL_BOWLING_BALL_VELOCITY_PER_SECOND_MAX
        } else if (type == .chickenator_HIGH || type == .chickenator_LOW) {
            minVelocity = difficulty!.CRIMINAL_CHICKENATOR_VELOCITY_PER_SECOND_MIN
            maxVelocity = difficulty!.CRIMINAL_CHICKENATOR_VELOCITY_PER_SECOND_MAX
        } else {
            minVelocity = maxiumumWeaponVelocity
            maxVelocity = maxiumumWeaponVelocity
        }
    
        if( difficulty!.CRIMINAL_RANDOM_WEAPON_VELOCITY ) {
            velocity = CGFloat.random(minVelocity, maxVelocity)
        } else {
            velocity = maxVelocity
        }
		
        if(velocity > maxiumumWeaponVelocity) {
            velocity = maxiumumWeaponVelocity
        }
        
        return velocity
    }
    
    // Criminal can only speed boost if he's running, hasn't used all his speed boosts, and hasn't used up his speed boost by floor
    // allotment.
    fileprivate func CanSecondWind() -> Bool {
        var canSecondWind = false
        var secondWindsLeftOnFloor = false
        var secondWindChance = 0.0
        
        if ( (currentState == .running || currentState == .yikes) && secondWinds < difficulty!.CRIMINAL_MAX_SECOND_WINDS && difficulty!.CRIMINAL_ALLOW_SECOND_WIND) {
            
            if ( floorLevel == 1 && secondWindsFloor1 < difficulty!.CRIMINAL_MAX_SECOND_WINDS_FLOOR1) {
                secondWindsLeftOnFloor = true
                secondWindChance = difficulty!.CRIMINAL_SECOND_WIND_CHANCE_FLOOR1
            } else if ( floorLevel == 2 && secondWindsFloor2 < difficulty!.CRIMINAL_MAX_SECOND_WINDS_FLOOR2 ) {
                secondWindsLeftOnFloor = true
                secondWindChance = difficulty!.CRIMINAL_SECOND_WIND_CHANCE_FLOOR2
            } else if ( floorLevel == 3 && secondWindsFloor3 < difficulty!.CRIMINAL_MAX_SECOND_WINDS_FLOOR3 ) {
                secondWindsLeftOnFloor = true
                secondWindChance = difficulty!.CRIMINAL_SECOND_WIND_CHANCE_FLOOR3
            } else if ( floorLevel == 3 && secondWindsFloor4 < difficulty!.CRIMINAL_MAX_SECOND_WINDS_FLOOR4 ) {
                secondWindsLeftOnFloor = true
                secondWindChance = difficulty!.CRIMINAL_SECOND_WIND_CHANCE_FLOOR4
            }
        }
    
        if ( secondWindsLeftOnFloor ) {
            let number = Double.random(0, max: 1.0)
            
            if ( number < secondWindChance ) {
                if ( bumble != nil ) {
                    if ( bumble!.currentState == .running || bumble!.currentState == .ducking || bumble!.currentState == .jumping) {
                        canSecondWind = true
                    }
                } else {
                    canSecondWind = true
                }
            }
        }
       
        return canSecondWind
    }
    
    fileprivate func InitializeTextures() {
        // Running Animation.
        //for i in 1 ... 9 {
        //    criminalRunning.append(textureManager.taCriminal1.textureNamed("crook_sequence_run000\(i)"))
        //}
        //criminalRunning.append(textureManager.taCriminal1.textureNamed("crook_sequence_run0010"))
        //criminalRunning.append(textureManager.taCriminal1.textureNamed("crook_sequence_run0011"))
        
        // Escalator
        criminalEscalator.append(textureManager.taCriminal1.textureNamed("crook_escalator"))
        
        // Yikes
        for i in 1 ... 9 {
            criminalYikes.append(textureManager.taCriminal1.textureNamed("crook_YELL_POP_000\(i)"))
        }
        for i in 10 ... 22 {
            criminalYikes.append(textureManager.taCriminal1.textureNamed("crook_YELL_POP_00\(i)"))
        }
        
        // Bowling
        for i in 1 ... 12 {
            criminalBowl1.append(textureManager.taCriminal2.textureNamed("crookbowl\(i)"))
        }
        for i in 13 ... 16 {
            criminalBowl2.append(textureManager.taCriminal2.textureNamed("crookbowl\(i)"))
        }
        
        // Pie
        for i in 1 ... 21 {
            criminalPie1.append(textureManager.taCriminal2.textureNamed("crookpie\(i)"))
        }
        for i in 22 ... 25 {
            criminalPie2.append(textureManager.taCriminal2.textureNamed("crookpie\(i)"))
        }
        
        // Chickenator High
        for i in 1 ... 13 {
            criminalChickenHigh1.append(textureManager.taCriminal2.textureNamed("crookchicken\(i)"))
        }
        criminalChickenHigh2.append(textureManager.taCriminal2.textureNamed("crookchicken14High"))
        
        // Chickenator Low
        for i in 1 ... 13 {
            criminalChickenLow.append(textureManager.taCriminal2.textureNamed("crookchicken\(i)"))
        }
        criminalChickenLow.append(textureManager.taCriminal2.textureNamed("crookchicken14Low"))
        criminalChickenLow.append(textureManager.taCriminal2.textureNamed("crookchicken15Low"))
        
        // Criminal Laugh
        for i in 1 ... 13 {
            criminalLaugh1.append(textureManager.taCriminal2.textureNamed("crooklaugh\(i)"))
        }
        
        for i in 14 ... 23 {
            criminalLaugh2.append(textureManager.taCriminal2.textureNamed("crooklaugh\(i)"))
        }
        
        for i in(14...23).reversed() {
            criminalLaugh2.append(textureManager.taCriminal2.textureNamed("crooklaugh\(i)"))
        }
        
        // Criminal Second Wind
        for i in 1 ... 22 {
            criminalSecondWind.append(textureManager.taCriminal1.textureNamed("crookfast\(i)"))
        }
    }
}
