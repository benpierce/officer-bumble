/*
===============================================================================
HUD

Holds a label for score, one for lives, the mini-map and buttons for pause 
and mute.
===============================================================================
*/

import Foundation
import SpriteKit

final class HUDManager {
    fileprivate let HUD_FONT_SIZE = CGFloat(0.0625)
    fileprivate let LIFE_HEIGHT = CGFloat(0.0625)
    fileprivate let LIFE_WIDTH = CGFloat(0.0625)
    fileprivate let miniMap: SKSpriteNode
    fileprivate let bumbleMarker: SKSpriteNode
    fileprivate let criminalMarker: SKSpriteNode
    fileprivate let muteButton: ToggleButton
    fileprivate let pauseButton: ToggleButton
    fileprivate let scoreLabel: SKLabelNode
    fileprivate let livesLabel: SKLabelNode
    fileprivate var hudWidth: CGFloat = CGFloat(0)
    
    // Some cached data for the mini map
    var paddingWidth = CGFloat(0)
    var paddingHeight = CGFloat(0)
    var offsetX = CGFloat(0)
    var offsetY = CGFloat(0)
    
    // Try to do all setup in here.
    public init(muteButton: ToggleButton, pauseButton: ToggleButton) {
        self.miniMap = SKSpriteNode(texture: textureManager.taTools.textureNamed("minimap"))
        self.bumbleMarker = SKSpriteNode(texture: textureManager.taTools.textureNamed("bumbleMarker"))
        self.criminalMarker = SKSpriteNode(texture: textureManager.taTools.textureNamed("criminalMarker"))
        self.muteButton = muteButton
        self.pauseButton = pauseButton
        self.scoreLabel = SKLabelNode()
        self.livesLabel = SKLabelNode()
    }
    
    open func TogglePauseOn() {
        pauseButton.ToggleOn()
    }
    
    open func TogglePauseOff() {
        pauseButton.ToggleOff()
    }
    
    open func Update(_ bumble: Bumble, criminal: Criminal, world: SKSpriteNode) {
        // Actual Bumble Position.
        let worldWidth = world.size.width
        let worldHeight = world.size.height
        
        let bumbleX = bumble.position.x + (world.scene!.size.width / 2)
        let bumbleY = bumble.position.y - (bumble.size.height / 2) + (world.scene!.size.height / 2)
        let criminalX = criminal.position.x + (world.scene!.size.width / 2)
        let criminalY = criminal.position.y - (criminal.size.height / 2) + (world.scene!.size.height / 2)
        
        bumbleMarker.position.x = -(miniMap.size.width / 2) + offsetX + ((bumbleX / worldWidth) * (miniMap.size.width * 0.90))
        criminalMarker.position.x = -(miniMap.size.width / 2) + offsetX + ((criminalX / worldWidth) * (miniMap.size.width * 0.90))
        
        bumbleMarker.position.y = -(miniMap.size.height / 2) + offsetY + ((bumbleY / worldHeight) * (miniMap.size.height * 1.3))
        criminalMarker.position.y = -(miniMap.size.height / 2) + offsetY + ((criminalY / worldHeight) * (miniMap.size.height * 1.3))
        
        bumbleMarker.xScale = (bumble.direction == .left) ? -1 : 1
        criminalMarker.xScale = (criminal.direction == .left) ? -1 : 1
    }
    
    open func Show(_ display: Display, hud: SKSpriteNode, lives: Int) {
        // Show the mini-map
        let miniMapHeight = display.GetNormalizedScreenHeightByPercentage(0.25)
        let miniMapWidth = display.GetNormalizedScreenWidthByPercentage(0.85)
        hudWidth = hud.size.width
        
        miniMap.size = CGSize(width: miniMapWidth, height: miniMapHeight)
        miniMap.position = display.GetSceneAnchor(miniMap, anchorTo: Display.ANCHOR.TOP_RIGHT)
        miniMap.zPosition = ZPOSITION.hud.rawValue
        hud.addChild(miniMap)
        
        // Add the markers.
        let markerWidth = miniMapHeight / 4.5
        let markerHeight = miniMapHeight / 4.5
        
        bumbleMarker.size = CGSize(width: markerWidth, height: markerHeight)
        criminalMarker.size = CGSize(width: markerWidth, height: markerHeight)
        bumbleMarker.zPosition = ZPOSITION.hud.rawValue
        criminalMarker.zPosition = ZPOSITION.hud.rawValue
        bumbleMarker.position = CGPoint(x: -5000, y: -5000)  // Something off screen.
        criminalMarker.position = CGPoint(x: -5000, y: -5000) // Off screen.
        miniMap.addChild(bumbleMarker)
        miniMap.addChild(criminalMarker)
        
        // Cache some mini-map numbers.
        paddingWidth = miniMap.size.width * 0.025 * 2
        paddingHeight = miniMap.size.height * 0.08
        offsetX = (markerWidth / 2)
        offsetY = (markerHeight / 2) + paddingHeight
        
        // Add pause button
        let pauseButtonX = miniMap.position.x - (miniMap.size.width / 2) - (pauseButton.size.width / 2)
        let pauseButtonY = miniMap.position.y + (miniMap.size.height / 2) - (pauseButton.size.height / 2)
        pauseButton.position = CGPoint(x: pauseButtonX, y: pauseButtonY)
        hud.addChild(pauseButton)
        
        // Add mute button
        let muteButtonX = pauseButtonX - (pauseButton.size.width / 2) - (muteButton.size.width / 2)
        let muteButtonY = miniMap.position.y + (miniMap.size.height / 2) - (muteButton.size.height / 2)
        muteButton.position = CGPoint(x: muteButtonX, y: muteButtonY)
        hud.addChild(muteButton)
        
        // Add score label.
        scoreLabel.fontSize = display.GetNormalizedScreenHeightByPercentage(HUD_FONT_SIZE)
        scoreLabel.text = "Score: "
        //scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        scoreLabel.fontName = "Arial"
        let scoreY = CGFloat((hud.size.height / 2.0) - scoreLabel.frame.size.height)
        let scoreX = CGFloat((-hud.size.width / 2.0) + (scoreLabel.frame.size.width / 2.0))
        scoreLabel.position = CGPoint(x: scoreX, y: scoreY)
        scoreLabel.zPosition = ZPOSITION.hud.rawValue
        hud.addChild(scoreLabel)
        
        // Add lives label.
        livesLabel.fontSize = display.GetNormalizedScreenHeightByPercentage(HUD_FONT_SIZE)
        livesLabel.text = "Lives: "
        livesLabel.fontName = "Arial"
        //livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        let livesX = scoreX
        let livesY = scoreY - scoreLabel.frame.height * CGFloat(1.5)
        livesLabel.position = CGPoint(x: livesX, y: livesY)
        livesLabel.zPosition = ZPOSITION.hud.rawValue
        hud.addChild(livesLabel)
        
        // Add the # of lives.
        UpdateLives(lives, hud: hud, display: display)
    }
    
    func UpdateLives(_ lives: Int, hud: SKSpriteNode, display: Display) {
        // Remove any lives that might already be in the HUD.
        hud.enumerateChildNodes(withName: "//life*", using: {
            (node: SKNode!, stop: UnsafeMutablePointer <ObjCBool>) -> Void in
            
            node.removeFromParent()
        })
        
        if ( lives > 1 ) {
            // Add the # of lives.
            for i in 1 ... lives - 1 {
                if ( i > 0) {
                    let life = SKSpriteNode(texture: textureManager.taTools.textureNamed("bumbleMarker"))
                    life.name = "life\(i)"
                    life.size = display.GetSizeByPercentageOfScene(LIFE_WIDTH, heightPercent: LIFE_HEIGHT, considerAspectRatio: true)
                    life.zPosition = ZPOSITION.hud.rawValue
                    life.position.y = livesLabel.position.y + (life.size.height / 2.5)
                    life.position.x = livesLabel.position.x + livesLabel.frame.size.width + (CGFloat(i - 1) * display.GetNormalizedScreenWidthByPercentage(LIFE_WIDTH)) - (life.size.width / 2)
                    hud.addChild(life)
                }
            }
        }
    }
    
    func UpdateScore(_ newScore: Int) {
        scoreLabel.text = "Score: \(newScore)"
        let scoreLabelWidthHalf = (scoreLabel.frame.size.width / 2.0)

        let scoreX = CGFloat(-(hudWidth / 2.0) + scoreLabelWidthHalf)
        scoreLabel.position.x = scoreX
    }
    
    // In case this is on Hardcore where lives don't exist.
    func HideLives() {
        livesLabel.isHidden = true
    }
}
