//
//  GameSharedPreferences.swift
//  OfficerBumble
//
//  Created by Ben Pierce on 2015-02-15.
//  Copyright (c) 2015 Benjamin Pierce. All rights reserved.
//

import Foundation
open class GameSharedPreferences {
    
    // Constants used to access commonly used preferences.
    open let FBID_PREFERENCE = "FBID"
    open let FIRST_NAME_PREFERENCE = "FIRST_NAME"
    open let LAST_NAME_PREFERENCE = "LAST_NAME"
    open let PROFILE_PIC_PREFERENCE = "FBPIC"
    open let FB_FRIENDS_PREFERENCE = "Friends"
    open let CRIMINALS_CAUGHT_PREFERENCE = "CriminalsCaught"
    open let CRIMINALS_CAUGHT_HARDCORE_PREFERENCE = "CrimianlsCaughtHardcore"
    open let HIGH_SCORE_PREFERENCE = "HighScore"
    open let HIGH_SCORE_HARDCORE_PREFERENCE = "HighScoreHardcore"
    
    open func ReadString(_ key: String) -> String {
        return UserDefaults.standard.value(forKey: key)! as! String
    }
    
    open func WriteString(_ key: String, value: String) -> Void {
        let defaults = UserDefaults.standard
        
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
    
    open func WriteInteger(_ key :String, value: Int) -> Void {
        let defaults = UserDefaults.standard
        
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
    
    open func ReadInteger(_ key: String) -> Int {
        let defaults = UserDefaults.standard
        return defaults.integer(forKey: key)
    }
}
