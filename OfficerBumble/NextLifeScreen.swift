//
//  NextLifeScreen.swift
//  OfficerBumble
//
//  Created by Ben Pierce on 2015-02-10.
//  Copyright (c) 2015 Benjamin Pierce. All rights reserved.
//

import Foundation
import SpriteKit

open class NextLifeScreen : GameScene {
    fileprivate var gameStateManager: GameStateManager
    
    init(size: CGSize, gameStateManager: GameStateManager, isMuted: Bool) {
        self.gameStateManager = gameStateManager
        
        super.init(size: size, resourceName: "nextlife", isMuted: isMuted)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func didMove(to view: SKView) {
        super.didMove(to: view)
        
        let text: String = "Bumble! You're rocking a score of \(gameStateManager.GetScore()). Score \(gameStateManager.GetNextFreeLifeScore()) more points and we'll award you with a 1UP!"
        
        let popup = Popup()
        popup.ShowOK(text, display: display, width: 1.0, scene: self, world: world!, inputManager: inputManager, okBlock: { self.gameStateManager.NextLevel(self) } )
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: EVENT_TYPE.PROMOTION.rawValue), object: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: EVENT_TYPE.SHOW_AD.rawValue), object: nil)
    }
    
}
