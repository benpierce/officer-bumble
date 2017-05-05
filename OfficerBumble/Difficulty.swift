//
//  Difficulty.swift
//  OfficerBumble
//
//  Created by Ben Pierce on 2015-02-02.
//  Copyright (c) 2015 Benjamin Pierce. All rights reserved.
//

import Foundation
import SpriteKit

public protocol Difficulty {
    var DifficultyName: String { get }
    var STARTING_LIVES: Int { get }
    var MAX_LIVES: Int { get }
    var FREE_LIFE_SCORE: Int { get }
    var ONE_HIT_KILLS: Bool { get }
    
    // Bumble Constants
    var BUMBLE_INVINCIBILITY_TIME: TimeInterval { get }
    var BUMBLE_MAX_VELOCITY_PER_SECOND: CGFloat { get }
    var BUMBLE_MIN_VELOCITY_TIME: TimeInterval { get }
    var BUMBLE_MAX_VELOCITY_TIME: TimeInterval { get }
    
    // Criinal Constants
    var CRIMINAL_VELOCITY_PER_SECOND: CGFloat { get }
    var CRIMINAL_MAX_WEAPONS_IN_QUEUE: Int { get }
    var CRIMINAL_MIN_TIME_BETWEEN_ATTACKS: TimeInterval { get }
    var CRIMINAL_ATTACK_PERCENTAGE: Double { get }
    var CRIMINAL_RANDOM_WEAPON_VELOCITY: Bool { get }
    var CRIMINAL_PIE_ATTACK_PERCENTAGE: Double { get }
    var CRIMINAL_BOWLING_BALL_ATTACK_PERCENTAGE: Double { get }
    var CRIMINAL_CHICKENATOR_ATTACK_PERCENTAGE: Double { get }
    var CRIMINAL_PIE_VELOCITY_PER_SECOND_MIN: CGFloat { get }
    var CRIMINAL_PIE_VELOCITY_PER_SECOND_MAX: CGFloat { get }
    var CRIMINAL_BOWLING_BALL_VELOCITY_PER_SECOND_MIN: CGFloat { get }
    var CRIMINAL_BOWLING_BALL_VELOCITY_PER_SECOND_MAX: CGFloat { get }
    var CRIMINAL_CHICKENATOR_VELOCITY_PER_SECOND_MIN: CGFloat { get }
    var CRIMINAL_CHICKENATOR_VELOCITY_PER_SECOND_MAX: CGFloat { get }
    
    var CRIMINAL_ALLOW_MOCKING: Bool { get }
    var CRIMINAL_MOCKING_DISTANCE: CGFloat { get }
    var CRIMINAL_MOCKING_DISTANCE_END: CGFloat { get }
    
    var CRIMINAL_ALLOW_SECOND_WIND: Bool { get }
    var CRIMINAL_SECOND_WIND_DISTANCE: CGFloat { get }
    var CRIMINAL_SECOND_WIND_DURATION: TimeInterval { get }
    var CRIMINAL_MAX_SECOND_WINDS: Int { get }
    var CRIMINAL_MAX_SECOND_WINDS_FLOOR1: Int { get }
    var CRIMINAL_MAX_SECOND_WINDS_FLOOR2: Int { get }
    var CRIMINAL_MAX_SECOND_WINDS_FLOOR3: Int { get }
    var CRIMINAL_MAX_SECOND_WINDS_FLOOR4: Int { get }
    var CRIMINAL_SECOND_WIND_CHANCE_FLOOR1: Double { get }
    var CRIMINAL_SECOND_WIND_CHANCE_FLOOR2: Double { get }
    var CRIMINAL_SECOND_WIND_CHANCE_FLOOR3: Double { get }
    var CRIMINAL_SECOND_WIND_CHANCE_FLOOR4: Double { get }
}




