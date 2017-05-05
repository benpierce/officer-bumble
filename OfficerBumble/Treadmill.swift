//
//  Treadmill.swift
//  OfficerBumble
//
//  Created by Ben Pierce on 2014-12-09.
//  Copyright (c) 2014 Benjamin Pierce. All rights reserved.
//

import Foundation
import SpriteKit

final class Treadmill : SKSpriteNode {

    // Our treadmill
    public enum STATE {
        case on
        case off
    }
    
    open var state : STATE = .off
    
    fileprivate let textureAtlas = SKTextureAtlas(named:"training")
    fileprivate var treadmillRunning = Array<SKTexture>();
    
    // Try to do all setup in here.
    public init() {
        let texture = SKTexture(imageNamed: "treadmill1")
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        
        super.name = "Treadmill"
        Initialize()
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func Initialize() {
        treadmillRunning.append(textureAtlas.textureNamed("treadmill1"))
        treadmillRunning.append(textureAtlas.textureNamed("treadmill2"))
        treadmillRunning.append(textureAtlas.textureNamed("treadmill3"))
        treadmillRunning.append(textureAtlas.textureNamed("treadmill4"))
        
        Start()
    }
    
    open func Update(_ bumble: Bumble) {
        if ( bumble.currentState == Bumble.STATE.running && state == .off) {
            Start()
        }
        
        if ( bumble.currentState != Bumble.STATE.running && state == .on) {
            Stop()
        }
    }
    
    fileprivate func Stop() {
        if ( state == .on ) {
            self.removeAllActions()
            state = .off
        }
    }
    
    fileprivate func Start() {
        if ( state == .off ) {
            self.removeAllActions()
            let animateAction = SKAction.animate(with: self.treadmillRunning, timePerFrame: 0.05)
            let repeatAction = SKAction.repeatForever(animateAction)
            self.run(repeatAction)
            state = .on
        }
    }
}
