/*
===============================================================================

Enums

Holds all of the game's package-level enums

===============================================================================
*/

import Foundation
import SpriteKit

// Events we might want to listen to.
enum EVENT_TYPE : String {
    case BUMBLE_FALL_BOWLING_BALL = "BUMBLE_FALL_BOWLING_BALL"  // When Bumble is hit with bowling ball
    case BUMBLE_FALL_CHICKENATOR = "BUMBLE_FALL_CHICKENATOR"    // When Bumble is hit with a chickenator
    case BUMBLE_FALL_PIE = "BUMBLE_FALL_PIE"                    // When Bumble is hit with pie
    case BUMBLE_DUCK = "BUMBLE_DUCK"                            // When Bumble ducks
    case BUMBLE_JUMP = "BUMBLE_JUMP"                            // When Bumble jumps
    case BUMBLE_ESCALATOR = "BUMBLE_ESCALATOR"                  // When Bumble uses an escalator
    case BUMBLE_HEADSHAKE = "BUMBLE_HEADSHAKE"                  // When Bumble shakes the pie off his face
    case BUMBLE_WINK = "BUMBLE_WINK"                            // When Bumble winks after catching criminal
    case CRIMINAL_CAUGHT = "CRIMINAL_CAUGHT"                    // When the criminal is caught
    case CRIMINAL_SECOND_WIND = "CRIMINAL_SECOND_WIND"          // When the criminal gets a second wind
    case CRIMINAL_YIKES = "CRIMINAL_YIKES"                      // When the Bumble gets closed to the criminal and he freaks
    case CRIMINAL_ESCAPE = "CRIMINAL_ESCAPE"                    // When the criminal escapes
    case CRIMINAL_LAUGH = "CRIMINAL_LAUGH"                      // When the criminal laughs at Bumble for being too slow (on easy)
    case ROBOTHROWER_SHOOT = "ROBOTHROWER_SHOOT"                // When the robothrower throws something low
    case ROBOTHROWER_THROW = "ROBOTHROWER_THROW"                // When the robothrower catapaults something
    case BUTTON_PRESSED = "BUTTON_PRESSED"                      // When a button is pressed
    case GAME_OVER = "GAME_OVER"                                // On game over scene
    case FREE_MAN = "FREE_MAN"                                  // When Bumble gets a free man
    case PROMOTION = "PROMOTION"                                // On promotion scene
    case SCORE_WEAPON = "SCORE_WEAPON"                          // Whenever a weapon goes behind Bumble.
    case BUMBLE_JUMP_COMPLETE = "BUMBLE_JUMP_COMPLETE"          // Whenever Bumble finishes jumping.
    case BUMBLE_DUCK_COMPLETE = "BUMBLE_DUCK_COMPLETE"          // Whenever Bumble finishes ducking.
    case APP_BECAME_ACTIVE = "APP_BECAME_ACTIVE"                // Whenever the application becomes active.
    case LEVEL_WON = "LEVEL_WON"                                // Whenever Bumble catches the criminal.
    case BUMBLE_RECOVER_FROM_FALL = "BUMBLE_RECOVER_FROM_FALL"  // Whenever Bumble recovers from a fall.
    case SHOW_AD = "SHOW_AD"                                    // Whenever we want to show an ad.
}

public enum BODY_TYPE : UInt32 {
    case none = 0
    case bumble = 1
    case bowling_BALL = 2
    case pie = 4
    case chickenator_HIGH = 8
    case chickenator_LOW = 16
    case criminal = 32
    case exit = 64
    case escalator = 128
    
    var name : String {
        get {
            switch(self) {
            case .none:
                return "NONE"
            case .bumble:
                return "BUMBLE"
            case .bowling_BALL:
                return "BOWLING_BALL"
            case .pie:
                return "PIE"
            case .chickenator_HIGH:
                return "CHICKENATOR_HIGH"
            case .chickenator_LOW:
                return "CHICKENATOR_LOW"
            case .criminal:
                return "CRIMINAL"
            case .exit:
                return "EXIT"
            case .escalator:
                return "ESCALATOR"
            }
        }
    }
}

public enum ZPOSITION: CGFloat {
    case popup_UI = 128
    case popup = 64
    case hud = 32
    case foreground = 16
    case normal = 8
    case background_FLOOR = 4
    case background_WALL = 2
    case background = 1

    static func GetByName(_ name: String) -> ZPOSITION {
        switch(name) {
            case "POPUP_UI":
                return popup_UI
            case "POPUP":
                return popup
            case "BACKGROUND":
                return background
            case "BACKGROUND_WALL":
                return background_WALL
            case "BACKGROUND_FLOOR":
                return background_FLOOR
            case "NORMAL":
                return normal
            case "FOREGROUND":
                return foreground
            case "HUD":
                return hud
            default:
                return normal
        }
    }
}

public enum DIRECTION : UInt32 {
    case left = 1
    case right = 2
}

enum BUTTON_EVENT : UInt32 {
    case button_A_PRESSED = 1
    case button_A_RELEASED = 2
    case button_B_PRESSED = 4
    case button_B_RELEASED = 8
}

public enum CRIMINAL_WEAPON {
    case pie
    case chickenator_HIGH
    case chickenator_LOW
    case bowling_BALL
}
