//
//  ToggleButton.swift
//  OfficerBumble
//
//  Created by Ben Pierce on 2015-01-14.
//  Copyright (c) 2015 Benjamin Pierce. All rights reserved.
//

import Foundation
import SpriteKit

final class ToggleButton: GameButton {
    
    open var isOn = true
    
    fileprivate func GetAction() -> SKAction {
        var action: SKAction!
    
        if ( isOn ) {
            if ( super.textureWhenPressed != nil ) {
                action = SKAction.setTexture(super.textureWhenPressed!)
            }
        } else {
            if ( super.textureDefault != nil ) {
                action = SKAction.setTexture(super.textureDefault!)
            }
        }
    
        return action
    }
    
    override func Pressed() {
        if ( super.pressBlock != nil ) {
            NotificationCenter.default.post(name: Notification.Name(rawValue: EVENT_TYPE.BUTTON_PRESSED.rawValue), object: nil)
            
            let block = SKAction.run(pressBlock!)                          // Which block of code to run when the button is pressed.
            
            let toggleBlock = SKAction.run({ self.isOn = !self.isOn })
            
            let sequence = SKAction.sequence([GetAction(), block, toggleBlock])   // Group everything together.
            self.run(sequence)
        }
    }
    
    open func Toggle() {
        let toggleBlock = SKAction.run({ self.isOn = !self.isOn })
        
        let sequence = SKAction.sequence([GetAction(), toggleBlock])   // Group everything together.
        self.run(sequence)
    }
    
    open func ToggleOn() {
        self.isOn = false
        self.run(GetAction())
        self.isOn = true
    }
    
    open func ToggleOff() {
        self.isOn = true
        self.run(GetAction())
        self.isOn = false
    }

}
