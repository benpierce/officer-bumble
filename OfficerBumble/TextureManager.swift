//
//  TextureManager.swift
//  OfficerBumble
//
//  Created by Ben Pierce on 2015-03-07.
//  Copyright (c) 2015 Benjamin Pierce. All rights reserved.
//

import Foundation
import SpriteKit

let textureManager = TextureManager();

open class TextureManager {

    open let taCriminal1: SKTextureAtlas
    open let taCriminal2: SKTextureAtlas
    open let taBumble1: SKTextureAtlas
    open let taBumble2: SKTextureAtlas
    open let taTools: SKTextureAtlas
    open let taTools2: SKTextureAtlas
    open let taTornado: SKTextureAtlas
    open let taLevelCommon: SKTextureAtlas
    open let taShoppingMall: SKTextureAtlas
    open let taBank: SKTextureAtlas
    open let taCasino: SKTextureAtlas
    open let taMuseum: SKTextureAtlas
    fileprivate var isPreloaded = false
    
    // Pre-loaded actions.
    fileprivate let CHICKENATOR_FLY_FRAME_TIME = 0.0625    // How long each frame of the flying animation takes.
    fileprivate let CHICKENATOR_ANGRY_FRAME_TIME = 0.00001 // How long each frame of the chickenator angry animation takes.
    fileprivate let CHICKENATOR_ATTACK_FRAME_TIME = 0.08333 // How long each frame of the chickenator attack animation takes.
    fileprivate let CRIMINAL_RUN_FRAME_TIME = 0.0476
    fileprivate let BUMBLE_RUN_FRAME_TIME = 0.055

    fileprivate var chickenatorFly = Array<SKTexture>()
    fileprivate var chickenatorAttackLow = Array<SKTexture>()
    fileprivate var chickenatorAttackHigh = Array<SKTexture>()
    fileprivate var chickenatorAngry = Array<SKTexture>()
    fileprivate var pie = Array<SKTexture>()
    fileprivate var bowlingBall = Array<SKTexture>()
    fileprivate var bumbleRunning = Array<SKTexture>()
    fileprivate var criminalRunning = Array<SKTexture>()
    
    open var chickenatorFlyAction: SKAction
    open var chickenatorAngryAction: SKAction
    open var chickenatorAttackHighAction: SKAction
    open var chickenatorAttackLowAction: SKAction
    open var pieAction: SKAction
    open var bowlingBallAction: SKAction
    open var bumbleRunningAction: SKAction
    open var criminalRunningAction: SKAction
    
    public init() {
        taCriminal1 = SKTextureAtlas(named:"criminal1")
        taCriminal2 = SKTextureAtlas(named:"criminal2")
        taBumble1 = SKTextureAtlas(named:"bumble1")
        taBumble2 = SKTextureAtlas(named:"bumble2")
        taTools = SKTextureAtlas(named:"tools")
        taTools2 = SKTextureAtlas(named:"tools2")
        taTornado = SKTextureAtlas(named:"tornado")
        taLevelCommon = SKTextureAtlas(named:"levelcommon")
        taShoppingMall = SKTextureAtlas(named:"shoppingmall")
        taBank = SKTextureAtlas(named:"bank")
        taCasino = SKTextureAtlas(named:"casino")
        taMuseum = SKTextureAtlas(named:"museum")
        
        chickenatorFly.append(taCriminal1.textureNamed("chickenator1"))
        chickenatorFly.append(taCriminal1.textureNamed("chickenator2"))
        chickenatorFly.append(taCriminal1.textureNamed("chickenator3"))
        chickenatorFly.append(taCriminal1.textureNamed("chickenator4"))
        chickenatorFly.append(taCriminal1.textureNamed("chickenator5"))
        chickenatorFly.append(taCriminal1.textureNamed("chickenator6"))
        chickenatorFly.append(taCriminal1.textureNamed("chickenator7"))
        chickenatorFly.append(taCriminal1.textureNamed("chickenator8"))
        chickenatorFly.append(taCriminal1.textureNamed("chickenator9"))
        chickenatorFly.append(taCriminal1.textureNamed("chickenator10"))
        chickenatorFly.append(taCriminal1.textureNamed("chickenator11"))
        
        chickenatorAttackLow.append(taCriminal1.textureNamed("chickenator_attack_lower1"))
        chickenatorAttackLow.append(taCriminal1.textureNamed("chickenator_attack_lower2"))
        chickenatorAttackLow.append(taCriminal1.textureNamed("chickenator_attack_lower3"))
        
        chickenatorAttackHigh.append(taCriminal1.textureNamed("chickenator_attack_upper1"))
        chickenatorAttackHigh.append(taCriminal1.textureNamed("chickenator_attack_upper2"))
        chickenatorAttackHigh.append(taCriminal1.textureNamed("chickenator_attack_upper3"))
        
        chickenatorAngry.append(taCriminal1.textureNamed("chickenator_angry"))
        
        chickenatorFlyAction = SKAction.repeatForever(SKAction.animate(with: chickenatorFly, timePerFrame: CHICKENATOR_FLY_FRAME_TIME))
        chickenatorAttackHighAction = SKAction.repeat(SKAction.animate(with: chickenatorAttackHigh, timePerFrame: CHICKENATOR_ATTACK_FRAME_TIME), count: 3)
        chickenatorAttackLowAction = SKAction.repeat(SKAction.animate(with: chickenatorAttackLow, timePerFrame: CHICKENATOR_ATTACK_FRAME_TIME), count: 3)
        chickenatorAngryAction = SKAction.animate(with: chickenatorAngry, timePerFrame: CHICKENATOR_ANGRY_FRAME_TIME)
        
        pie.append(taCriminal1.textureNamed("pie1"))
        pie.append(taCriminal1.textureNamed("pie2"))
        pie.append(taCriminal1.textureNamed("pie3"))
        pie.append(taCriminal1.textureNamed("pie4"))
        pie.append(taCriminal1.textureNamed("pie5"))
        pie.append(taCriminal1.textureNamed("pie6"))
        
        bowlingBall.append(taCriminal1.textureNamed("bowlingball1"))
        bowlingBall.append(taCriminal1.textureNamed("bowlingball2"))
        bowlingBall.append(taCriminal1.textureNamed("bowlingball3"))
        bowlingBall.append(taCriminal1.textureNamed("bowlingball4"))
        
        pieAction = SKAction.repeatForever(SKAction.animate(with: pie, timePerFrame: 0.125))
        bowlingBallAction = SKAction.repeatForever(SKAction.animate(with: bowlingBall, timePerFrame: 0.125))
        
        for i in 1 ... 11 {
            bumbleRunning.append(taBumble1.textureNamed("run\(i)"))
        }
        bumbleRunningAction = SKAction.repeatForever(SKAction.animate(with: bumbleRunning, timePerFrame: BUMBLE_RUN_FRAME_TIME))
        
        // Running Animation.
        for i in 1 ... 9 {
            criminalRunning.append(taCriminal1.textureNamed("crook_sequence_run000\(i)"))
        }
        criminalRunning.append(taCriminal1.textureNamed("crook_sequence_run0010"))
        criminalRunning.append(taCriminal1.textureNamed("crook_sequence_run0011"))
        
        criminalRunningAction = SKAction.repeatForever(SKAction.animate(with: criminalRunning, timePerFrame: CRIMINAL_RUN_FRAME_TIME))
    }

    open func PreloadTextures() {
        let atlases = [taCriminal1, taCriminal2, taBumble1, taBumble2, taTools, taTools2, taTornado, taLevelCommon, taShoppingMall, taBank, taCasino, taMuseum]
    
        SKTextureAtlas.preloadTextureAtlases(atlases, withCompletionHandler: TexturesLoaded)
    }
    
    open func IsPreloadingComplete() -> Bool {
        return isPreloaded
    }
    
    fileprivate func TexturesLoaded() {
        isPreloaded = true
    }
    
}
