//
//  NextLifeScreen.swift
//  OfficerBumble
//
//  Created by Ben Pierce on 2015-02-10.
//  Copyright (c) 2015 Benjamin Pierce. All rights reserved.
//

import Foundation
import SpriteKit

open class NextBadgeScreen : GameScene {
    fileprivate var gameStateManager: GameStateManager
    fileprivate let criminalsCaught: Int
    fileprivate let nextBadge: BadgeManager.Badge?
    
    init(size: CGSize, gameStateManager: GameStateManager, isMuted: Bool, criminalsCaught: Int, nextBadge: BadgeManager.Badge?) {
        self.gameStateManager = gameStateManager
        self.criminalsCaught = criminalsCaught
        self.nextBadge = nextBadge
        
        super.init(size: size, resourceName: "nextbadge", isMuted: isMuted)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func didMove(to view: SKView) {
        super.didMove(to: view)
        
        var text = "Keep up the good work Bumble! You've caught your \(criminalsCaught)\(Int.GetNumericSuffix(criminalsCaught)) McBurgler Brother."
        if ( nextBadge != nil ) {
            text = text + " Arrest \(nextBadge!.criminalsCaught - criminalsCaught) more McBurgler "
            if ( nextBadge!.criminalsCaught == 1) {
                text = text + "Brother"
            } else {
                text = text + "Brothers"
            }
            text = text + " and there's a \(nextBadge!.badgeName) promotion in it for you!"
        }
        
        let popup = Popup()
        popup.ShowOK(text, display: display, width: 1.0, scene: self, world: world!, inputManager: inputManager, okBlock: { self.gameStateManager.NextLevel(self) } )
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: EVENT_TYPE.PROMOTION.rawValue), object: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: EVENT_TYPE.SHOW_AD.rawValue), object: nil)
    }
    
}
