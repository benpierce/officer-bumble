//
//  Toast.swift
//  OfficerBumble
//
//  Created by Ben Pierce on 2015-02-03.
//  Copyright (c) 2015 Benjamin Pierce. All rights reserved.
//

import Foundation
import SpriteKit

final class Toast {
    fileprivate let FONT_WIDTH = CGFloat(100)
    fileprivate let FONT_HEIGHT = CGFloat(100)
    fileprivate let TIMER_FONT_WIDTH = CGFloat(40)
    fileprivate let TIMER_FONT_HEIGHT = CGFloat(40)
    
    fileprivate var startTime: TimeInterval = 0
    fileprivate var hud: SKSpriteNode
    fileprivate var timeToDisplay: TimeInterval = 0
    fileprivate var text: String = ""
    fileprivate var completionBlock: () -> () = {}
    fileprivate var label = SKLabelNode()
    fileprivate var timerLabel = SKLabelNode()
    fileprivate var touchDuck = SKSpriteNode()
    fileprivate var touchJump = SKSpriteNode()
    fileprivate var active: Bool = false
    fileprivate var showTimer: Bool = false
    fileprivate var currentSecond: Double = 0

    public init(hud: SKSpriteNode) {
        self.hud = hud
    }
    
    open func Show(_ text: String, timeToDisplay: TimeInterval, display: Display, completionBlock: @escaping () -> ()) {
        Show(text, timeToDisplay: timeToDisplay, showTimer: false, display: display, completionBlock: completionBlock)
    }
    
    open func Show(_ text: String, timeToDisplay: TimeInterval, showTimer: Bool, display: Display, completionBlock: @escaping () -> ()) {
        self.text = text
        self.timeToDisplay = timeToDisplay
        self.completionBlock = completionBlock
        
        startTime = CACurrentMediaTime()
        active = true
        
        label = SKLabelNode()
        label.text = text
        let size = display.GetSize(FONT_WIDTH, height: FONT_HEIGHT)
        label.fontSize = size.width
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        label.position = CGPoint(x: 0, y: 0)
        label.fontName = "MarkerFelt-Wide"
        label.zPosition = ZPOSITION.hud.rawValue
        self.hud.addChild(label)
        
        if ( showTimer ) {
            touchDuck = SKSpriteNode(texture: textureManager.taTools2.textureNamed("touchduck"))
            touchJump = SKSpriteNode(texture: textureManager.taTools2.textureNamed("touchjump"))

            touchDuck.size = display.GetSizeByPercentageOfScene(0.30, heightPercent: 0.30, considerAspectRatio: true)
            touchJump.size = display.GetSizeByPercentageOfScene(0.30, heightPercent: 0.30, considerAspectRatio: true)

            touchDuck.position = display.GetParentAnchor(touchDuck, parent: hud, anchorTo: Display.ANCHOR.CENTER_LEFT)
            touchJump.position = display.GetParentAnchor(touchJump, parent: hud, anchorTo: Display.ANCHOR.CENTER_RIGHT)
            
            touchDuck.zPosition = ZPOSITION.hud.rawValue
            touchJump.zPosition = ZPOSITION.hud.rawValue
            
            currentSecond = ceil(timeToDisplay) + 1
            
            timerLabel = SKLabelNode()
            timerLabel.text = "\(Int(currentSecond))"
            timerLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
            timerLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
            timerLabel.position = CGPoint(x: 0, y: label.position.y - label.frame.size.height)
            timerLabel.fontName = "MarkerFelt-Wide"
            timerLabel.zPosition = ZPOSITION.hud.rawValue
            self.hud.addChild(timerLabel)
            
            self.hud.addChild(touchDuck)
            self.hud.addChild(touchJump)
            
            TimeStep()
        }
    }
    
    fileprivate func TimeStep() {
        currentSecond = currentSecond - 1
        if ( currentSecond <= 0 ) {
            Hide()
        } else {
            timerLabel.text = "\(Int(currentSecond))"
            let waitAction = SKAction.wait(forDuration: 1)
            self.hud.run(waitAction, completion: TimeStep)
        }
    }
    
    open func Update(_ currentTime: TimeInterval) {
        if ( active ) {
            if ( !showTimer ) {
                let delta = currentTime - startTime     // Seconds
            
                if ( delta >= timeToDisplay ) {
                    Hide()
                }
            }
        }
    }
    
    // Hide the toast from plain view. Note that we're not removing the label from the HUD, we're just fading it out. This is because
    // if we remove it from the parent, the completionBlock won't run.
    fileprivate func Hide() {
        let hideAction = SKAction.fadeOut(withDuration: 0.5)
        let completionBlock = SKAction.run(self.completionBlock)
        let sequence = SKAction.sequence([hideAction, completionBlock])
        label.run(sequence)
        
        let hideActionTimer = SKAction.fadeOut(withDuration: 0.5)
        let hideActionTouchDuck = SKAction.fadeOut(withDuration: 0.5)
        let hideActionTouchJump = SKAction.fadeOut(withDuration: 0.5)
        
        timerLabel.run(hideActionTimer)
        touchDuck.run(hideActionTouchDuck)
        touchJump.run(hideActionTouchJump)
        
        active = false
    }
}
