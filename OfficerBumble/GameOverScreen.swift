//
//  GameOverScreen.swift
//  OfficerBumble
//
//  Created by Ben Pierce on 2015-02-04.
//  Copyright (c) 2015 Benjamin Pierce. All rights reserved.
//

import Foundation
import SpriteKit

final class GameOverScreen: GameScene {

    fileprivate let HARDCORE_AD_PERCENTAGE = 33     // % of time we'll see an ad in hardcore mode.
    fileprivate var gameStateManager: GameStateManager
    
    init(size: CGSize, gameStateManager: GameStateManager, isMuted: Bool) {
        self.gameStateManager = gameStateManager
    
        super.init(size: size, resourceName: "gameoverscreen", isMuted: isMuted)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func didMove(to view: SKView) {
        super.didMove(to: view)
    
        var text: String = ""
        var showAd: Bool = true
        
        if ( gameStateManager.GetDifficulty().DifficultyName == "Hardcore") {
            text = "Bumble, that McBurgler Brother played you for a fool! Perhaps you're not as hardcore as you think! Clean yourself up and report back to duty when you're ready."
            
            let num: Int = Int.random(1...100)
            if ( num <= HARDCORE_AD_PERCENTAGE ) {
                showAd = true
            } else {
                showAd = false
            }
        } else {
            text = "Bumble you let that McBurgler Brother get away! Collect your wits and report back to duty as soon as possible!"
        }
        
        let popup = Popup()
        popup.ShowMainMenuTryAgain(text, display: display, width: 1.0, scene: self, world: world!, inputManager: inputManager, tryagainBlock: self.NewGame, mainmenuBlock: TransitionToTitle)
        
        if ( showAd ) {
            NotificationCenter.default.post(name: Notification.Name(rawValue: EVENT_TYPE.SHOW_AD.rawValue), object: nil)
        }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: EVENT_TYPE.GAME_OVER.rawValue), object: nil)
    }
    
    fileprivate func NewGame() {
        gameStateManager.NewGame(self)
    }
}
