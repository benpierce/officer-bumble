/*
===============================================================================
Training

Handles all training related scene logic.
===============================================================================
*/

import SpriteKit

class Training: GameScene {

    // Some constants to control training behavior.
    let RANDOM_ATTACK_CHECK_INTERVAL = 0.25
    let MAX_ATTACK_CHECKS = 6                             // Maximum number of times to randomly check for an attack before it must happen.
    let RANDOM_ATTACK_CHANCE = CGFloat(0.25)              // Chance of an attack as a percentage.
    var WEAPON_VELOCITY_PER_SECOND : CGFloat = CGFloat(0)             // Regular weapon velocity.
    let POPUP_WIDTH = CGFloat(1.00)                       // Width of Popups.
    let OBJECTIVES_FONT_SIZE = CGFloat(0.0625)            // Objectives Font Size
    
    // Where we are currently in training.
    fileprivate enum TRAINING_STATE : Int {
        case initial_explaination = 0
        case duck_explaination = 1
        case duck_test = 2
        case jump_explaination = 3
        case jump_test = 4
        case general_explaination = 5
        case pie_explaination = 6
        case pie_test = 7
        case bowling_ball_explaination = 8
        case bowling_ball_test = 9
        case chickenator_high_explaination = 10
        case chickenator_high_test = 11
        case chickenator_low_explaination = 12
        case chickenator_low_test = 13
        case random_explaination = 14
        case random_test = 15
        case final_congrats = 16
        case random_nonstop = 17
    }

    // We need handles to these objects to make training mode work.
    var treadmill : Treadmill?
    var bumble : Bumble?
    var robothrower : Robothrower2000?
    var touchDuck = SKSpriteNode()
    var touchJump = SKSpriteNode()

    let popup = Popup()             // A generic popup box that we'll re-use throughout training
    var objective : SKLabelNode?    // A label to show the current training objective
    
    // State Flags
    fileprivate var currentState : TRAINING_STATE = TRAINING_STATE.initial_explaination
    var started : Bool = false
    var duckExplainationShown : Bool = false
    var consecutiveDucks : Int = 0
    var consecutiveJumps : Int = 0
    var pieExplainationShown : Bool = false
    var weaponsInPlay : Int = 0
    var consecutiveBowlingBalls : Int = 0
    var consecutivePies : Int = 0
    var consecutiveChickenators : Int = 0
    var consecutiveDodges : Int = 0
    var previousDucks : Int = -1;
    var previousJumps : Int = -1;
    var previousPies : Int = -1;
    var previousBowlingBalls : Int = -1;
    var previousChickenators : Int = -1;
    var previousDodges : Int = -1;
    var randomVelocity : Bool = false
    var lastAttackTime : CFTimeInterval = CACurrentMediaTime()
    var consecutiveChecks : Int = 0
    var checkStateRequired : Bool = false
    var checkObjectivesRequired : Bool = false
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // Wire up the treadmill to UI events.
        treadmill = (super.GetSpriteNodeOrDie("treadmill") as! Treadmill)
        
        // Wire up Bumble to UI events.
        bumble = (super.GetSpriteNodeOrDie("bumble") as! Bumble)
        let difficulty = Easy(display: super.display)
        bumble!.Initialize(inputManager, difficulty: difficulty)
        
        WEAPON_VELOCITY_PER_SECOND = display.GetNormalizedScreenWidthByPercentage(0.95)
        
        // Wire up Physics.
        bumble!.SetPhysics(physicsManager)
        bumble!.MakeStationary()
        bumble!.Run()
        
        robothrower = self.childNode(withName: "//robothrower") as! Robothrower2000?
        robothrower!.SetBumble(bumble!)
        
        physicsWorld.contactDelegate = self
        checkStateRequired = true
    
        AddMuteButton()
        
        WireButtons()
        ConfigureNotifications()
    }
    
    fileprivate func AddTouchDuck() {
        let margin = Margin(marginTop: 0.0, marginBottom: 0.15, marginLeft: 0.0, marginRight: 0.0)
        
        touchDuck = SKSpriteNode(texture: textureManager.taTools2.textureNamed("touchduck"))
        touchDuck.size = display.GetSizeByPercentageOfScene(0.30, heightPercent: 0.30, considerAspectRatio: true)
        touchDuck.position = display.GetParentAnchor(touchDuck, parent: hud!, margin: margin, anchorTo: Display.ANCHOR.CENTER_LEFT)
        touchDuck.zPosition = ZPOSITION.hud.rawValue
        
        hud!.addChild(touchDuck)
    }
    
    fileprivate func AddTouchJump() {
        let margin = Margin(marginTop: 0.0, marginBottom: 0.15, marginLeft: 0.0, marginRight: 0.0)

        touchJump = SKSpriteNode(texture: textureManager.taTools2.textureNamed("touchjump"))
        touchJump.size = display.GetSizeByPercentageOfScene(0.30, heightPercent: 0.30, considerAspectRatio: true)
        touchJump.position = display.GetParentAnchor(touchDuck, parent: hud!, margin: margin, anchorTo: Display.ANCHOR.CENTER_RIGHT)
        touchJump.zPosition = ZPOSITION.hud.rawValue
        
        hud!.addChild(touchJump)
    }
    
    fileprivate func AddMuteButton() {
        let muteButton = super.CreateMuteButton()
        let btnback = super.GetSpriteNodeOrNil("btnback")
        
        if ( muteButton != nil && btnback != nil) {
            muteButton!.position = super.display.GetSiblingAnchor(muteButton!, sibling: btnback!, anchorTo: Display.ANCHOR.CENTER_LEFT)
            world!.addChild(muteButton!)
        }
    }
    
    fileprivate func WireButtons() {
        super.WireButton("btnback", pressBlock: TransitionToTitleScreen)
    }
    
    fileprivate func ConfigureNotifications() {
        // Bumble Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(Training.OnJumpComplete), name: NSNotification.Name(rawValue: EVENT_TYPE.BUMBLE_JUMP_COMPLETE.rawValue), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(Training.OnDuckComplete), name: NSNotification.Name(rawValue: EVENT_TYPE.BUMBLE_DUCK_COMPLETE.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(Training.OnWeaponComplete), name: NSNotification.Name(rawValue: EVENT_TYPE.SCORE_WEAPON.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(Training.OnBumbleHit), name: NSNotification.Name(rawValue: EVENT_TYPE.BUMBLE_FALL_BOWLING_BALL.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(Training.OnBumbleHit), name: NSNotification.Name(rawValue: EVENT_TYPE.BUMBLE_FALL_CHICKENATOR.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(Training.OnBumbleHit), name: NSNotification.Name(rawValue: EVENT_TYPE.BUMBLE_FALL_PIE.rawValue), object: nil)
    }
    
    fileprivate func PopupDismissed() {
        if(popup.IsOpen()) {
            popup.Close(world!, scene: self)
        }
        
        if(currentState == TRAINING_STATE.initial_explaination) {
            currentState = TRAINING_STATE.duck_explaination;
            checkStateRequired = true
        } else if(currentState == TRAINING_STATE.duck_explaination) {
            currentState = TRAINING_STATE.duck_test;
            ClearObjectiveCounts();
            checkStateRequired = true
            touchDuck.removeFromParent()
        } else if(currentState == TRAINING_STATE.jump_explaination) {
            currentState = TRAINING_STATE.jump_test;
            ClearObjectiveCounts();
            checkStateRequired = true
            touchJump.removeFromParent()
        } else if(currentState == TRAINING_STATE.general_explaination) {
            currentState = TRAINING_STATE.pie_explaination;
            checkStateRequired = true
        } else if(currentState == TRAINING_STATE.pie_explaination) {
            ClearObjectiveCounts();
            currentState = TRAINING_STATE.pie_test;
            checkStateRequired = true
        } else if (currentState == TRAINING_STATE.bowling_ball_explaination) {
            ClearObjectiveCounts();
            currentState = TRAINING_STATE.bowling_ball_test;
            checkStateRequired = true
        } else if (currentState == TRAINING_STATE.chickenator_high_explaination) {
            ClearObjectiveCounts();
            currentState = TRAINING_STATE.chickenator_high_test;
            checkStateRequired = true
        } else if (currentState == TRAINING_STATE.chickenator_low_explaination) {
            ClearObjectiveCounts();
            currentState = TRAINING_STATE.chickenator_low_test;
            checkStateRequired = true
        } else if (currentState == TRAINING_STATE.random_explaination) {
            ClearObjectiveCounts();
            currentState = TRAINING_STATE.random_test;
            checkStateRequired = true
        } else if (currentState == TRAINING_STATE.final_congrats) {
            ClearObjectiveCounts();
            currentState = TRAINING_STATE.random_nonstop;
            randomVelocity = true;
            checkStateRequired = true
        }
        
        bumble!.Run()
        checkObjectivesRequired = true
    }
    
    @objc fileprivate func OnJumpComplete() {
        if ( currentState == .jump_test ) {
            previousJumps = consecutiveJumps
            consecutiveJumps += 1
            consecutiveDucks = 0
            checkObjectivesRequired = true
            checkStateRequired = true
        }
    }
    
    @objc fileprivate func OnDuckComplete() {
        if (currentState == .duck_test ) {
            previousDucks = consecutiveDucks
            consecutiveDucks += 1
            consecutiveJumps = 0
            checkObjectivesRequired = true
            checkStateRequired = true
        }
    }
    
    @objc fileprivate func OnBumbleHit() {
        consecutiveDodges = 0
        checkObjectivesRequired = true
        checkStateRequired = true
    }
    
    @objc fileprivate func OnWeaponComplete() {
        switch( currentState ) {
        case TRAINING_STATE.pie_test:
            consecutivePies = consecutivePies + 1
        case TRAINING_STATE.bowling_ball_test:
            consecutiveBowlingBalls = consecutiveBowlingBalls + 1
        case TRAINING_STATE.chickenator_high_test:
            consecutiveChickenators = consecutiveChickenators + 1
        case TRAINING_STATE.chickenator_low_test:
            consecutiveChickenators = consecutiveChickenators + 1
        case TRAINING_STATE.random_test, TRAINING_STATE.random_nonstop:
            consecutiveDodges = consecutiveDodges + 1
        default: ()
        }
        
        checkObjectivesRequired = true
        checkStateRequired = true
    }
    
    fileprivate func TransitionToTitleScreen() {
        super.PresentScene(TitleScreen(size: self.size, resourceName: "titlescreen", isMuted: sm!.IsMuted()))
    }
    
    fileprivate func UpdateObjectiveText(_ text : String) {
        // Depending on the objective we have, we will update the objective label node.
        if(objective != nil) {
            objective!.removeFromParent()
        }
        
        objective = SKLabelNode()
        objective!.text = text
        objective!.zPosition = ZPOSITION.hud.rawValue
        objective!.name = "Objective"
        objective!.fontSize = display.GetNormalizedScreenHeightByPercentage(OBJECTIVES_FONT_SIZE)
        objective!.fontName = "Arial"
        
        // Align Top Left
        let positionY = CGFloat((self.size.height / 2.0) - objective!.frame.size.height)
        let positionX = CGFloat((-self.size.width / 2.0) + (objective!.frame.size.width / 2.0))
        
        objective!.position = CGPoint(x: positionX, y: positionY)
        world!.addChild(objective!)
    }
    
    // This is called after every significant action to see if we should transition to the next section of training.
    fileprivate func CheckState() {
        var textValue : String
        
        if(currentState == TRAINING_STATE.initial_explaination && !started) {
            textValue = "Welcome to training Officer Bumble. This training simulation will ensure you have the skills to take down even the most hardened criminals.";
            //m_popup = super.CreatePopup(POPUP_TYPE.OK, 2.0f, 1.2f, true, textValue, this);
            //m_bumble.Run(_currentTimeMilliseconds);
            popup.ShowOK(textValue, display : display, width: POPUP_WIDTH, scene : self, world: world!, inputManager: inputManager, okBlock: self.PopupDismissed)
            started = true;
        } else if (currentState == TRAINING_STATE.duck_explaination && !duckExplainationShown) {
            textValue = "You can duck by tapping anywhere on the left side of your screen. Duck 3 times in a row to continue.";
            popup.ShowOK(textValue, display : display, width: POPUP_WIDTH, scene : self, world: world!, inputManager: inputManager, okBlock: PopupDismissed)
            duckExplainationShown = true;
            AddTouchDuck()
        } else if (currentState == TRAINING_STATE.duck_test && consecutiveDucks >= 3) {
            textValue = "Good job, you've mastered ducking. To jump, tap anywhere on the right side of your screen. Jump 3 times in a row to continue.";
            currentState = TRAINING_STATE.jump_explaination;
            popup.ShowOK(textValue, display : display, width: POPUP_WIDTH, scene : self, world: world!, inputManager: inputManager, okBlock: PopupDismissed)
            AddTouchJump()
        } else if (currentState == TRAINING_STATE.jump_test && consecutiveJumps >= 3) {
            textValue = "I see you've got the controls mastered. In real life things won't be so easy. You'll need to time your jumping and ducking to avoid objects thrown by criminals.";
            currentState = TRAINING_STATE.general_explaination;
            popup.ShowOK(textValue, display : display, width: POPUP_WIDTH, scene : self, world: world!, inputManager: inputManager, okBlock: PopupDismissed)
        } else if (currentState == TRAINING_STATE.pie_explaination && !pieExplainationShown) {
            textValue = "Pies will fly towards your head. You need to avoid pies by ducking. The RoboThrower 2000 © will now hurl pies at you. Duck 3 pies to continue.";
            popup.ShowOK(textValue, display : display, width: POPUP_WIDTH, scene : self, world: world!, inputManager: inputManager, okBlock: PopupDismissed)
            //m_bumble.Run(_currentTimeMilliseconds);
            //m_popup.Open();
            //super.Pause();
            pieExplainationShown = true;
        } else if (currentState == TRAINING_STATE.pie_test && consecutivePies < 3 && weaponsInPlay == 0) {
            // Attacks are handled by the update.
        } else if (currentState == TRAINING_STATE.pie_test && consecutivePies >= 3) {
            textValue = "Excellent Bumble! Jump bowling balls to avoid being knocked down. Jump 3 bowling balls to continue.";
            currentState = TRAINING_STATE.bowling_ball_explaination;
            popup.ShowOK(textValue, display : display, width: POPUP_WIDTH, scene : self, world: world!, inputManager: inputManager, okBlock: PopupDismissed)
            //m_bumble.Run(_currentTimeMilliseconds);
            //m_popup.Open();
            //super.Pause();
        } else if (currentState == TRAINING_STATE.bowling_ball_test && consecutiveBowlingBalls < 3 && weaponsInPlay == 0) {
            // Attacks handled by the update.
        } else if (currentState == TRAINING_STATE.bowling_ball_test && consecutiveBowlingBalls >= 3) {
            textValue = "Perfect! Some of the more cunning McBurgler Brothers will be armed with Chickenators: nasty birds that can go either high or low. Try jumping some low Chickenators.";
            currentState = TRAINING_STATE.chickenator_high_explaination;
            popup.ShowOK(textValue, display : display, width: POPUP_WIDTH, scene : self, world: world!, inputManager: inputManager, okBlock: PopupDismissed)
            //m_bumble.Run(_currentTimeMilliseconds);
            //m_popup.Open();
            //super.Pause();
        } else if (currentState == TRAINING_STATE.chickenator_high_test && consecutiveChickenators < 3 && weaponsInPlay == 0) {
            // Attacks handled by the update.
        } else if (currentState == TRAINING_STATE.chickenator_high_test && consecutiveChickenators >= 3) {
            textValue = "Ok you've got those low chickenators mastered, now try ducking some high Chickenators.";
            currentState = TRAINING_STATE.chickenator_low_explaination;
            popup.ShowOK(textValue, display : display, width: POPUP_WIDTH, scene : self, world: world!, inputManager: inputManager, okBlock: PopupDismissed)
            //m_bumble.Run(_currentTimeMilliseconds);
            //m_popup.Open();
            //super.Pause();
        } else if (currentState == TRAINING_STATE.chickenator_low_test && consecutiveChickenators >= 3) {
            textValue = "Well done Bumble, there's hope for you yet! Now let's really test your resolve. Dodge 10 random objects in a row without being hit to continue.";
            currentState = TRAINING_STATE.random_explaination;
            popup.ShowOK(textValue, display : display, width: POPUP_WIDTH, scene : self, world: world!, inputManager: inputManager, okBlock: PopupDismissed)
            //m_bumble.Run(_currentTimeMilliseconds);
            //m_popup.Open();
            //super.Pause();
        } else if (currentState == TRAINING_STATE.chickenator_low_test && consecutiveChickenators < 3 && weaponsInPlay == 0) {
            // Attacks handled by the update.
        } else if (currentState == TRAINING_STATE.random_test && consecutiveDodges < 10 && weaponsInPlay == 0) {
            // Attacks handled by the update.
        } else if (currentState == TRAINING_STATE.random_test && consecutiveDodges >= 10) {
            textValue = "You've done it! You're now ready to see action. You can report for duty at any time by closing out to the main menu. Until then, you can continue practicing for as long as you wish.";
            currentState = TRAINING_STATE.final_congrats;
            popup.ShowOK(textValue, display : display, width: POPUP_WIDTH, scene : self, world: world!, inputManager: inputManager, okBlock: PopupDismissed)
            //m_bumble.Run(_currentTimeMilliseconds);
            //m_popup.Open();
            //super.Pause();
        }
        else if (currentState == TRAINING_STATE.random_nonstop && weaponsInPlay == 0) {
            // Attacks handled by the update.			
        }
    }
    
    fileprivate func UpdateObjectives() {
        if(currentState == TRAINING_STATE.duck_test) {
			if(consecutiveDucks != previousDucks) {
				previousDucks = consecutiveDucks;
                UpdateObjectiveText("Objective: " + String(consecutiveDucks) + "/3 ducks")
			}
		}
		else if(currentState == TRAINING_STATE.jump_test) {
			if(consecutiveJumps != previousJumps) {
				previousJumps = consecutiveJumps;
				UpdateObjectiveText("Objective: " + String(consecutiveJumps) + "/3 jumps");
			}
		}
		else if(currentState == TRAINING_STATE.pie_test) {
			if(consecutivePies != previousPies) {
				previousPies = consecutivePies;
				UpdateObjectiveText("Objective: " + String(consecutivePies) + "/3 pies avoided");
			}
		}
		else if(currentState == TRAINING_STATE.bowling_ball_test) {
			if(consecutiveBowlingBalls != previousBowlingBalls) {
				previousBowlingBalls = consecutiveBowlingBalls;
				UpdateObjectiveText("Objective: " + String(consecutiveBowlingBalls) + "/3 bowling balls avoided");
			}
		}
		else if(currentState == TRAINING_STATE.chickenator_high_test || currentState == TRAINING_STATE.chickenator_low_test) {
			if(consecutiveChickenators != previousChickenators) {
				previousChickenators = consecutiveChickenators;
				UpdateObjectiveText("Objective: " + String(consecutiveChickenators) + "/3 Chickenators avoided");
			}
		}
		else if(currentState == TRAINING_STATE.random_test) {
			if(consecutiveDodges != previousDodges) {
				previousDodges = consecutiveDodges;
				
				UpdateObjectiveText("Objective: " + String(consecutiveDodges) + "/10 successful consecutive dodges");
			}
		}
		else if(currentState == TRAINING_STATE.random_nonstop) {
			if(consecutiveDodges != previousDodges) {
				previousDodges = consecutiveDodges;
				UpdateObjectiveText(String(consecutiveDodges) + " successful consecutive dodges");
			}
		}
    }
    
    fileprivate func ClearObjectiveCounts() {
        consecutiveDucks = 0;
        consecutiveJumps = 0;
        consecutivePies = 0;
        consecutiveBowlingBalls = 0;
        consecutiveChickenators = 0;
        consecutiveDodges = 0;
        previousDucks = -1;
        previousJumps = -1;
        previousPies = -1;
        previousBowlingBalls = -1;
        previousChickenators = -1;
        previousDodges = -1;
    }
    
    override func didFinishUpdate() {
        super.BumbleCamera(bumble!)
    }

    override func update(_ currentTime: TimeInterval) {
        
        if ( checkObjectivesRequired ) {
            UpdateObjectives()
            checkObjectivesRequired = false
        }
        
        // Complete hack, but necessary. We can't unpause and then pause in the same frame, otherwise sprite updates between
        // the unpause and pause won't be rendered. This ensures that rendering happens, then CheckState() is called from here
        // in the subsequent frame. Same shit I dealt with in Android.
        if ( checkStateRequired ) {
            CheckState()
            checkStateRequired = false
        }
        
        bumble!.Update(currentTime, isPaused: world!.isPaused)
        treadmill!.Update(bumble!)
        
        // See if we should attack
        Attack(currentTime);
        
        super.update(currentTime)
    }
    
    fileprivate func Attack(_ currentTime: CFTimeInterval) {
        
        if( CanAttack(currentTime) ) {
        
            switch(currentState) {
            case .pie_test:
                ThrowPie()
            case .bowling_ball_test:
                ThrowBowlingBall()
            case .chickenator_high_test:
                ThrowChickenatorHigh()
            case .chickenator_low_test:
                ThrowChickenatorLow()
            case .random_test, .random_nonstop:
                ThrowRandom()
            default:
                ThrowRandom()
            }
            
        }
    }
    
    fileprivate func ThrowPie() {
        robothrower!.ThrowPie(world!, physicsManager: physicsManager, velocity: GetVelocityPerSecond(false))
    }
    fileprivate func ThrowBowlingBall() {
        robothrower!.Bowl(world!, physicsManager: physicsManager, velocity: GetVelocityPerSecond(false))
    }
    fileprivate func ThrowChickenatorHigh() {
        robothrower!.ThrowChickenatorHigh(world!, physicsManager: physicsManager, velocity: GetVelocityPerSecond(true))
    }
    fileprivate func ThrowChickenatorLow() {
        robothrower!.ThrowChickenatorLow(world!, physicsManager: physicsManager, velocity: GetVelocityPerSecond(true))
    }
    fileprivate func ThrowRandom() {
        let weapon = Int.random(1...4)
        
        switch(weapon) {
        case 1:
            ThrowPie()
        case 2:
            ThrowBowlingBall()
        case 3:
            ThrowChickenatorHigh()
        case 4:
            ThrowChickenatorLow()
        default:
            break
        }
    }
    
    fileprivate func GetWeaponsInPlay() -> Int {
        var result : Int = Int(0)
        
        // Loop through all Chickenators
        self.enumerateChildNodes(withName: "//Weapon_*", using: {
            (node: SKNode!, stop: UnsafeMutablePointer <ObjCBool>) -> Void in
            
            result = result + 1
        })
        
        return result
    }
    
    fileprivate func CanAttack(_ currentTime: CFTimeInterval) -> Bool {
        let delta = currentTime - lastAttackTime
        var result : Bool = false
        
        // Can only attack if the interval time is large enough and there are no other weapons in play.
        if(delta >= RANDOM_ATTACK_CHECK_INTERVAL && bumble!.currentState != .bowling_ball_fall && bumble!.currentState != .chickenator_fall && bumble!.currentState != .pie_fall && robothrower!.hasActions() == false) {
    
            // Can only attack if we're in the right state for it.
            if(currentState == .pie_test || currentState == .bowling_ball_test || currentState == .chickenator_high_test || currentState == .chickenator_low_test || currentState == .random_test || currentState == .random_nonstop) {
				
                let weaponsInPlay = GetWeaponsInPlay()
                
                if ( weaponsInPlay  == 0 ) {
                    
                    consecutiveChecks += 1;
                    if(consecutiveChecks >= MAX_ATTACK_CHECKS) {
                        // Have to attack since we've waited too long.
                        result = true;
                        consecutiveChecks = 0;
                    } else {
                        // Attack is based on chance.random(#min: CGFloat, max: CGFloat)
                        let pickedNumber = CGFloat.random(CGFloat(0), CGFloat(1))
                        if( pickedNumber <= RANDOM_ATTACK_CHANCE ) {
                            result = true
                            consecutiveChecks = 0
                        }
                    }
                }
            }
    
            lastAttackTime = currentTime
        }
        
        return result
    }
    
    fileprivate func GetVelocityPerSecond(_ isChickenator: Bool) -> CGFloat {
        var result = WEAPON_VELOCITY_PER_SECOND;
    
        if(randomVelocity) {
            result = CGFloat.random(0.75, 1.5)
            
            if(isChickenator && result > CGFloat(1.0)) {
				result = CGFloat(1.0)	// have to cap chickenator to be fair.
            }
            
            result = display.GetNormalizedScreenWidthByPercentage(result)
        }
    
        return result
    }
    
}
