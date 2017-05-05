/*
===============================================================================
Feather

Holds the animations for all 5 feather variations and controls the physics for
feathers flying out of a particular point and then floating off the screen.
===============================================================================
*/

import Foundation
import SpriteKit

final class Feather : SKSpriteNode {
   
    // Size Constants
	fileprivate let FEATHER_HEIGHT = CGFloat(0.05);
	fileprivate let FEATHER_WIDTH = CGFloat(0.05);
    
    // Physics Constraints
    fileprivate let MIN_VELOCITY_UP : CGFloat
    fileprivate let MAX_VELOCITY_UP : CGFloat
    fileprivate let MIN_VELOCITY_DOWN : CGFloat
    fileprivate let MAX_VELOCITY_DOWN : CGFloat
    fileprivate let MIN_VELOCITY_HORIZONTAL : CGFloat
    fileprivate let MAX_VELOCITY_HORIZONTAL : CGFloat
    fileprivate let MIN_AMPLITUDE : CGFloat
    fileprivate let MAX_AMPLITUDE : CGFloat
    fileprivate let MAX_TARGETY_OFFSET : CGFloat
    fileprivate let MIN_TARGETY_OFFSET : CGFloat
    fileprivate let MAX_TARGETX_OFFSET : CGFloat
    
    // Texture Variables
    fileprivate var featherTextures = Array<SKTexture>()
    fileprivate let chickenator : Chickenator
    
    // State Variables
    fileprivate var startingX = CGFloat(0)
    fileprivate var velocityUp = CGFloat(0)
    fileprivate var velocityDown = CGFloat(0)
    fileprivate var velocityHorizontal = CGFloat(0)
    fileprivate var amplitude = CGFloat(0)
    fileprivate var targetY = CGFloat(0)
    fileprivate var targetX = CGFloat(0)
    fileprivate var direction = DIRECTION.left
    fileprivate var frameDuration = 0.0
    fileprivate var display : Display?
    
    init(chickenator: Chickenator, display: Display) {
        let texture = textureManager.taCriminal1.textureNamed("feather1_1")
        self.chickenator = chickenator
        
        self.display = display
        let size = self.display!.GetSizeByPercentageOfScene(FEATHER_WIDTH, heightPercent: FEATHER_HEIGHT, considerAspectRatio: true)
        
        // Physics Constraints
        MIN_VELOCITY_UP = display.GetNormalizedScreenHeightByPercentage(0.25)
        MAX_VELOCITY_UP = display.GetNormalizedScreenHeightByPercentage(0.40)
        MIN_VELOCITY_DOWN = display.GetNormalizedScreenHeightByPercentage(0.10)
        MAX_VELOCITY_DOWN = display.GetNormalizedScreenHeightByPercentage(0.20)
        MIN_VELOCITY_HORIZONTAL = display.GetNormalizedScreenWidthByPercentage(0.15)
        MAX_VELOCITY_HORIZONTAL = display.GetNormalizedScreenWidthByPercentage(0.30)
        MIN_AMPLITUDE = display.GetNormalizedScreenWidthByPercentage(0.10)
        MAX_AMPLITUDE = display.GetNormalizedScreenWidthByPercentage(0.5)
        
        MAX_TARGETY_OFFSET = display.GetNormalizedScreenHeightByPercentage(0.20)
        MIN_TARGETY_OFFSET = display.GetNormalizedScreenHeightByPercentage(0.05)
        MAX_TARGETX_OFFSET = display.GetNormalizedScreenWidthByPercentage(0.05)
        
        super.init(texture: texture, color: UIColor.clear, size: size)
        self.zPosition = ZPOSITION.foreground.rawValue
        
        CustomInitialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func CustomInitialize() {
        LoadFeatherAnimation()
        Spawn()
    }
    
    /*
    ===============================================================================
    LoadFeatherAnimation
    
    Chooses a random feather animation (from 1 to 5) and loads all of the textures
    into memory.
    ===============================================================================
    */
    fileprivate func LoadFeatherAnimation() {
        let featherId = Int.random(1...5)
        var frames = 0
        
        switch( featherId ) {
        case 1:
            frames = 7
            frameDuration = 0.0714
        case 2:
            frames = 10
            frameDuration = 0.0625
        case 3:
            frames = 8
            frameDuration = 0.05
        case 4:
            frames = 10
            frameDuration = 0.1
        case 5:
            frames = 10
            frameDuration = 0.05
        default:
            frames = 0
            frameDuration = 0
        }
        
        for i in 1 ... frames {
            featherTextures.append(textureManager.taCriminal1.textureNamed("feather\(featherId)_\(i)"))
        }
    }

    fileprivate func Spawn() {
        let chickenatorLeftBounds = chickenator.position.x - (chickenator.size.width / 2)
        let chickenatorRightBounds = chickenator.position.x + (chickenator.size.width / 2)
        let chickenatorUpperBounds = chickenator.position.y + (chickenator.size.height / 2)
        let chickenatorLowerBounds = chickenator.position.y - (chickenator.size.height / 2)

		let x = CGFloat.random(chickenatorLeftBounds, chickenatorRightBounds)
        let y = CGFloat.random(chickenatorLowerBounds, chickenatorUpperBounds)
        
        self.position = CGPoint(x: x, y: y)
				
		startingX = x;
		velocityUp = CGFloat.random(MIN_VELOCITY_UP, MAX_VELOCITY_UP);
		velocityDown = CGFloat.random(MIN_VELOCITY_DOWN, MAX_VELOCITY_DOWN) * -1;
		velocityHorizontal = CGFloat.random(MIN_VELOCITY_HORIZONTAL, MAX_VELOCITY_HORIZONTAL);
        amplitude = CGFloat.random(MIN_AMPLITUDE, MAX_AMPLITUDE);
        targetY = y + CGFloat.random(MIN_TARGETY_OFFSET, MAX_TARGETY_OFFSET);
		targetX = x + CGFloat.random(MAX_TARGETX_OFFSET * -1, MAX_TARGETX_OFFSET);
		direction = (targetX < x) ? DIRECTION.left : DIRECTION.right;
        
        Arc()
	}
    
    fileprivate func Arc() {
        self.removeAllActions()
        
        // Figure out how long the movement should take based on the velocity up to get to targetY
        let howFarPerSecondY = velocityUp
        let timeY = (targetY - self.position.y) / howFarPerSecondY
        let howFarPerSecondX = velocityHorizontal
        let timeX = (targetX - self.position.x) / howFarPerSecondX
        let time = Double(max(timeY, timeX))
        
        let animationAction = SKAction.animate(with: self.featherTextures, timePerFrame: frameDuration)
        let repeatAction = SKAction.repeatForever(animationAction)
        
        let moveAction = SKAction.move(to: CGPoint(x: targetX, y: targetY), duration: time)
        self.run(repeatAction)
        self.run(moveAction, completion: Fall)
    }
    
    fileprivate func Fall() {
        self.removeAllActions()

        // If feather has gone below the world's bottom, we can destroy it.
        let parent = self.parent! as! SKSpriteNode
        if ( self.position.y < -(parent.size.height / 2) ) {
            self.removeFromParent()
        } else {
            let howFarPerSecondX = velocityHorizontal
            var targetX = CGFloat(0)
            if ( direction == .left ) {
                targetX = self.position.x - amplitude
                direction = .right
            } else {
                targetX = self.position.x + amplitude
                direction = .left
            }
            let timeX = Double(abs(self.position.x - targetX)) / Double(howFarPerSecondX)
        
            let howFarPerSecondY = velocityDown
            let targetY = self.position.y - howFarPerSecondY * CGFloat(timeX) * -1
        
            let animationAction = SKAction.animate(with: self.featherTextures, timePerFrame: frameDuration)
            let repeatAction = SKAction.repeatForever(animationAction)
            self.run(repeatAction)
            let moveAction = SKAction.move(to: CGPoint(x: targetX, y: targetY), duration: timeX)
        
            self.run(moveAction, completion: Fall)
        }
    }
}
