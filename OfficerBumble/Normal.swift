import Foundation
import SpriteKit

open class Normal : Difficulty {
    open var DifficultyName: String { get { return "Normal" } }
    open var STARTING_LIVES: Int { get { return 3 } }
    open var MAX_LIVES: Int { get { return 5 } }
    open var FREE_LIFE_SCORE: Int { get { return 15000 } }
    open var ONE_HIT_KILLS: Bool { get { return false } }
    
    // Bumble Constants
    open var BUMBLE_INVINCIBILITY_TIME: TimeInterval { get { return 0.5 } }
    fileprivate var BUMBLE_MAX_VELOCITY: CGFloat { get { return CGFloat(1) } }
    open var BUMBLE_MIN_VELOCITY_TIME: TimeInterval { get { return 2.5 } }
    open var BUMBLE_MAX_VELOCITY_TIME: TimeInterval { get { return 0.2 } }
    
    // Criinal Constants
    fileprivate var CRIMINAL_VELOCITY: CGFloat { get { return CGFloat(0.9) } }
    open var CRIMINAL_MAX_WEAPONS_IN_QUEUE: Int { get { return 3 } }
    open var CRIMINAL_MIN_TIME_BETWEEN_ATTACKS: TimeInterval { get { return 0.25 } }
    open var CRIMINAL_ATTACK_PERCENTAGE: Double { get { return 0.55 } }
    open var CRIMINAL_RANDOM_WEAPON_VELOCITY: Bool { get { return true } }
    open var CRIMINAL_PIE_ATTACK_PERCENTAGE: Double { get { return  0.45} }
    open var CRIMINAL_BOWLING_BALL_ATTACK_PERCENTAGE: Double { get { return 0.45 } }
    open var CRIMINAL_CHICKENATOR_ATTACK_PERCENTAGE: Double { get { return 0.1 } }
    
    fileprivate var CRIMINAL_PIE_VELOCITY_MIN: CGFloat { get { return 0.5 } }
    fileprivate var CRIMINAL_PIE_VELOCITY_MAX: CGFloat { get { return 1.30 } }
    fileprivate var CRIMINAL_BOWLING_BALL_VELOCITY_MIN: CGFloat { get { return 0.5 } }
    fileprivate var CRIMINAL_BOWLING_BALL_VELOCITY_MAX: CGFloat { get { return 1.30 } }
    fileprivate var CRIMINAL_CHICKENATOR_VELOCITY_MIN: CGFloat { get { return 0.4 } }
    fileprivate var CRIMINAL_CHICKENATOR_VELOCITY_MAX: CGFloat { get { return 0.9 } }
    
    open var CRIMINAL_ALLOW_MOCKING: Bool { get { return false } }
    fileprivate var CRIMINAL_MOCKING_DISTANCE_PERCENT: CGFloat { get { return CGFloat(0.9) } }
    fileprivate var CRIMINAL_MOCKING_DISTANCE_END_PERCENT: CGFloat { get { return CGFloat(0.75) } }
    
    open var CRIMINAL_ALLOW_SECOND_WIND: Bool { get { return true } }
    fileprivate var CRIMINAL_SECOND_WIND_DISTANCE_PERCENT: CGFloat { get { return CGFloat(0.23) } }
    open var CRIMINAL_SECOND_WIND_DURATION: TimeInterval { get { return 2 } }
    open var CRIMINAL_MAX_SECOND_WINDS: Int { get { return 3 } }
    open var CRIMINAL_MAX_SECOND_WINDS_FLOOR1: Int { get { return 3 } }
    open var CRIMINAL_MAX_SECOND_WINDS_FLOOR2: Int { get { return 2 } }
    open var CRIMINAL_MAX_SECOND_WINDS_FLOOR3: Int { get { return 1 } }
    open var CRIMINAL_MAX_SECOND_WINDS_FLOOR4: Int { get { return 0 } }
    open var CRIMINAL_SECOND_WIND_CHANCE_FLOOR1: Double { get { return 0.85 } }
    open var CRIMINAL_SECOND_WIND_CHANCE_FLOOR2: Double { get { return 0.55 } }
    open var CRIMINAL_SECOND_WIND_CHANCE_FLOOR3: Double { get { return 0.10 } }
    open var CRIMINAL_SECOND_WIND_CHANCE_FLOOR4: Double { get { return 0.0 } }
    
    // Translated Items based on Screen Size/Aspect Ratio to save having to do the calculations over and over
    // when they're used.
    fileprivate var mBUMBLE_MAX_VELOCITY_PER_SECOND: CGFloat = CGFloat(0)
    fileprivate var mCRIMINAL_VELOCITY_PER_SECOND: CGFloat = CGFloat(0)
    fileprivate var mCRIMINAL_PIE_VELOCITY_PER_SECOND_MIN: CGFloat = CGFloat(0)
    fileprivate var mCRIMINAL_PIE_VELOCITY_PER_SECOND_MAX: CGFloat = CGFloat(0)
    fileprivate var mCRIMINAL_BOWLING_BALL_VELOCITY_PER_SECOND_MIN: CGFloat = CGFloat(0)
    fileprivate var mCRIMINAL_BOWLING_BALL_VELOCITY_PER_SECOND_MAX: CGFloat = CGFloat(0)
    fileprivate var mCRIMINAL_CHICKENATOR_VELOCITY_PER_SECOND_MIN: CGFloat = CGFloat(0)
    fileprivate var mCRIMINAL_CHICKENATOR_VELOCITY_PER_SECOND_MAX: CGFloat = CGFloat(0)
    fileprivate var mCRIMINAL_MOCKING_DISTANCE: CGFloat = CGFloat(0)
    fileprivate var mCRIMINAL_MOCKING_DISTANCE_END: CGFloat = CGFloat(0)
    fileprivate var mCRIMINAL_SECOND_WIND_DISTANCE: CGFloat = CGFloat(0)
    
    public init (display: Display) {
        mBUMBLE_MAX_VELOCITY_PER_SECOND = display.GetNormalizedScreenWidthByPercentage(BUMBLE_MAX_VELOCITY)
        mCRIMINAL_VELOCITY_PER_SECOND = display.GetNormalizedScreenWidthByPercentage(CRIMINAL_VELOCITY)
        mCRIMINAL_PIE_VELOCITY_PER_SECOND_MIN = display.GetNormalizedScreenWidthByPercentage(CRIMINAL_PIE_VELOCITY_MIN)
        mCRIMINAL_PIE_VELOCITY_PER_SECOND_MAX = display.GetNormalizedScreenWidthByPercentage(CRIMINAL_PIE_VELOCITY_MAX)
        mCRIMINAL_BOWLING_BALL_VELOCITY_PER_SECOND_MIN = display.GetNormalizedScreenWidthByPercentage(CRIMINAL_BOWLING_BALL_VELOCITY_MIN)
        mCRIMINAL_BOWLING_BALL_VELOCITY_PER_SECOND_MAX = display.GetNormalizedScreenWidthByPercentage(CRIMINAL_BOWLING_BALL_VELOCITY_MAX)
        mCRIMINAL_CHICKENATOR_VELOCITY_PER_SECOND_MIN = display.GetNormalizedScreenWidthByPercentage(CRIMINAL_CHICKENATOR_VELOCITY_MIN)
        mCRIMINAL_CHICKENATOR_VELOCITY_PER_SECOND_MAX = display.GetNormalizedScreenWidthByPercentage(CRIMINAL_CHICKENATOR_VELOCITY_MAX)
        mCRIMINAL_MOCKING_DISTANCE = display.GetNormalizedScreenWidthByPercentage(CRIMINAL_MOCKING_DISTANCE_PERCENT)
        mCRIMINAL_MOCKING_DISTANCE_END = display.GetNormalizedScreenWidthByPercentage(CRIMINAL_MOCKING_DISTANCE_END_PERCENT)
        mCRIMINAL_SECOND_WIND_DISTANCE = display.GetNormalizedScreenWidthByPercentage(CRIMINAL_SECOND_WIND_DISTANCE_PERCENT)
    }
    
    // Calculated Properties
    open var BUMBLE_MAX_VELOCITY_PER_SECOND: CGFloat { get { return mBUMBLE_MAX_VELOCITY_PER_SECOND } }
    open var CRIMINAL_VELOCITY_PER_SECOND: CGFloat { get { return mCRIMINAL_VELOCITY_PER_SECOND } }
    open var CRIMINAL_PIE_VELOCITY_PER_SECOND_MIN: CGFloat { get { return mCRIMINAL_PIE_VELOCITY_PER_SECOND_MIN } }
    open var CRIMINAL_PIE_VELOCITY_PER_SECOND_MAX: CGFloat { get { return mCRIMINAL_PIE_VELOCITY_PER_SECOND_MAX } }
    open var CRIMINAL_BOWLING_BALL_VELOCITY_PER_SECOND_MIN: CGFloat { get { return mCRIMINAL_BOWLING_BALL_VELOCITY_PER_SECOND_MIN } }
    open var CRIMINAL_BOWLING_BALL_VELOCITY_PER_SECOND_MAX: CGFloat { get { return mCRIMINAL_BOWLING_BALL_VELOCITY_PER_SECOND_MAX } }
    open var CRIMINAL_CHICKENATOR_VELOCITY_PER_SECOND_MIN: CGFloat { get { return mCRIMINAL_CHICKENATOR_VELOCITY_PER_SECOND_MIN } }
    open var CRIMINAL_CHICKENATOR_VELOCITY_PER_SECOND_MAX: CGFloat { get { return mCRIMINAL_CHICKENATOR_VELOCITY_PER_SECOND_MAX } }
    open var CRIMINAL_MOCKING_DISTANCE: CGFloat { get { return mCRIMINAL_MOCKING_DISTANCE } }
    open var CRIMINAL_MOCKING_DISTANCE_END: CGFloat { get { return mCRIMINAL_MOCKING_DISTANCE_END } }
    open var CRIMINAL_SECOND_WIND_DISTANCE: CGFloat { get{ return mCRIMINAL_SECOND_WIND_DISTANCE } }
}
