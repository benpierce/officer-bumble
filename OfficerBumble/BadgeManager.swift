//
//  PromotionManager.swift
//  OfficerBumble
//
//  Created by Ben Pierce on 2015-02-11.
//  Copyright (c) 2015 Benjamin Pierce. All rights reserved.
//

import Foundation
import SpriteKit

open class BadgeManager {
    public struct Badge {
        public var badgeName: String = ""
        public var criminalsCaught: Int = 0
    }
    
    fileprivate var badges = [Badge]()
    
    public init() {
        InitializeBadges()
    }
    
    open func InitializeBadges() {
        badges.append(Badge(badgeName: "Recruit", criminalsCaught: 1))
        badges.append(Badge(badgeName: "Officer", criminalsCaught: 4))
        badges.append(Badge(badgeName: "Deputy", criminalsCaught: 12))
        badges.append(Badge(badgeName: "Corporal", criminalsCaught: 18))
        badges.append(Badge(badgeName: "Sergeant", criminalsCaught: 30))
        badges.append(Badge(badgeName: "Sergeant Major", criminalsCaught: 50))
        badges.append(Badge(badgeName: "Captain", criminalsCaught: 75))
        badges.append(Badge(badgeName: "Major", criminalsCaught: 125))
        badges.append(Badge(badgeName: "Lieutenant", criminalsCaught: 200))
        badges.append(Badge(badgeName: "Inspector", criminalsCaught: 300))
        badges.append(Badge(badgeName: "Commander", criminalsCaught: 500))
        badges.append(Badge(badgeName: "Deputy Chief", criminalsCaught: 800))
        badges.append(Badge(badgeName: "Chief", criminalsCaught: 1500))
    }
    
    open func GetNextBadge(_ criminalsCaught: Int) -> Badge? {
        var result: Badge? = nil
    
        for badge in badges {
            if ( badge.criminalsCaught > criminalsCaught ) {
                result = badge
                break
            }
        }
    
        return result
    }
    
    open func QueryBadge(_ criminalsCaught: Int) -> Badge? {
        var result: Badge? = nil
        
        for badge in badges {
            if ( badge.criminalsCaught == criminalsCaught ) {
                result = badge
                break
            }
        }
        
        return result
    }
}
