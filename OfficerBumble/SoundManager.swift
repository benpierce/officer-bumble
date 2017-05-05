/*
===============================================================================
SoundManager

Caches all of the game's sounds and wires itself into the Notification Center so that
it can play sounds without having to be coupled directly into the rest of the game
framework.

IMPORTANT: This class holds a reference to the scene that created it, so it's
important that the calling class sets the reference to it's SoundManager instance
to nil before transitioning scenes - otherwise memory leak.
===============================================================================
*/

import AVFoundation
import SpriteKit

open class SoundManager: NSObject {
    
    fileprivate let TITLE_MUSIC = "badguys"
    fileprivate let GAME_MUSIC = "heist"
    
    // Reference to the scene so that we have access to SKActions for sound.
    fileprivate var backgroundMusicPlayer: AVAudioPlayer!
    fileprivate var soundOn: Bool = true
    fileprivate var hud: SKSpriteNode?
    fileprivate var parentScene: String
    
    // Cached versions of all the sound effects
    fileprivate let SOUND_BUMBLE_FALL_BOWLING_BALL = SKAction.playSoundFileNamed("bowling.wav", waitForCompletion: true)
    fileprivate let SOUND_BUMBLE_FALL_CHICKENATOR = SKAction.playSoundFileNamed("chicken.wav", waitForCompletion: true)
    fileprivate var SOUND_BUMBLE_FALL_PIE = SKAction.playSoundFileNamed("splat.wav", waitForCompletion: true)
    fileprivate let SOUND_BUMBLE_DUCK = SKAction.playSoundFileNamed("duck.wav", waitForCompletion: true)
    fileprivate let SOUND_BUMBLE_JUMP = SKAction.playSoundFileNamed("jump.wav", waitForCompletion: true)
    fileprivate let SOUND_BUMBLE_ESCALATOR = SKAction.playSoundFileNamed("escalator.wav", waitForCompletion: true)
    fileprivate let SOUND_BUMBLE_HEADSHAKE = SKAction.playSoundFileNamed("headshake.wav", waitForCompletion: true)
    fileprivate var SOUND_BUMBLE_WINK = SKAction.playSoundFileNamed("wink.wav", waitForCompletion: true)
    fileprivate var SOUND_CRIMINAL_CAUGHT = SKAction.playSoundFileNamed("scramble.wav", waitForCompletion: true)
    fileprivate var SOUND_CRIMINAL_SECOND_WIND = SKAction.playSoundFileNamed("secondwind.wav", waitForCompletion: true)
    fileprivate var SOUND_CRIMINAL_YIKES = SKAction.playSoundFileNamed("yikes.wav", waitForCompletion: true)
    fileprivate let SOUND_CRIMINAL_ESCAPE = SKAction.playSoundFileNamed("criminalescape.wav", waitForCompletion: true)
    fileprivate let SOUND_CRIMINAL_LAUGH = SKAction.playSoundFileNamed("laugh.wav", waitForCompletion: true)
    fileprivate let SOUND_ROBOTHROWER_SHOOT = SKAction.playSoundFileNamed("robotshoot.wav", waitForCompletion: true)
    fileprivate let SOUND_ROBOTHROWER_THROW = SKAction.playSoundFileNamed("robotthrow.wav", waitForCompletion: true)
    fileprivate let SOUND_BUTTON_PRESSED = SKAction.playSoundFileNamed("button.wav", waitForCompletion: true)
    fileprivate let SOUND_GAME_OVER = SKAction.playSoundFileNamed("failure.wav", waitForCompletion: true)
    fileprivate let SOUND_FREE_MAN = SKAction.playSoundFileNamed("freeman.wav", waitForCompletion: true)
    fileprivate let SOUND_PROMOTION = SKAction.playSoundFileNamed("promotion.wav", waitForCompletion: true)
    
    public init(parentScene: String) {
        self.parentScene = parentScene
        
        super.init()
        ConfigureNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        StopMusic()
    }
    
    open func ToggleSound() {
        soundOn = !soundOn
        ToggleMusic()
    }
    
    open func IsMuted() -> Bool {
        return !soundOn
    }
    
    open func Mute() {
        if ( soundOn ) {
            ToggleSound()
        }
    }
    
    open func PlayTitleMusic() {
        PlayMusic(TITLE_MUSIC)
    }

    open func PlayInGameMusic() {
        PlayMusic(GAME_MUSIC)
    }

    fileprivate func PlayMusic(_ file : String) {
        if (backgroundMusicPlayer == nil) {
            
            let backgroundMusicURL = Bundle.main.url(forResource: file, withExtension: "mp3")
            
            do {
               backgroundMusicPlayer = try AVAudioPlayer(contentsOf: backgroundMusicURL!)
               backgroundMusicPlayer.delegate = self
               if backgroundMusicPlayer == nil {
                  print("nil AVAudioPlayer")
               } else {
                  backgroundMusicPlayer.numberOfLoops = -1
                  backgroundMusicPlayer.prepareToPlay()
                  backgroundMusicPlayer.play()
               }
            } catch {
                print("Error initializing sound")
            }
         }
    }

    func StopMusic() {
        if backgroundMusicPlayer != nil {
            if backgroundMusicPlayer.isPlaying {
                backgroundMusicPlayer.stop()
            }
        }
    }
 
    func ToggleMusic() {
        if backgroundMusicPlayer != nil {
            if backgroundMusicPlayer.isPlaying {
                self.backgroundMusicPlayer.pause()
            } else {
                self.backgroundMusicPlayer.play()
            }
        }
    }
    
    fileprivate func ConfigureNotifications() {
        // Bumble Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(SoundManager.PlayBumbleFallBowlingBall), name: NSNotification.Name(rawValue: EVENT_TYPE.BUMBLE_FALL_BOWLING_BALL.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SoundManager.PlayBumbleFallChickenator), name: NSNotification.Name(rawValue: EVENT_TYPE.BUMBLE_FALL_CHICKENATOR.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SoundManager.PlayBumbleFallPie), name: NSNotification.Name(rawValue: EVENT_TYPE.BUMBLE_FALL_PIE.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SoundManager.PlayBumbleDuck), name: NSNotification.Name(rawValue: EVENT_TYPE.BUMBLE_DUCK.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SoundManager.PlayBumbleJump), name: NSNotification.Name(rawValue: EVENT_TYPE.BUMBLE_JUMP.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SoundManager.PlayBumbleEscalator), name: NSNotification.Name(rawValue: EVENT_TYPE.BUMBLE_ESCALATOR.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SoundManager.PlayBumbleHeadshake), name: NSNotification.Name(rawValue: EVENT_TYPE.BUMBLE_HEADSHAKE.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SoundManager.PlayBumbleWink), name: NSNotification.Name(rawValue: EVENT_TYPE.BUMBLE_WINK.rawValue), object: nil)
        
        // Criminal Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(SoundManager.PlayCriminalCaught), name: NSNotification.Name(rawValue: EVENT_TYPE.CRIMINAL_CAUGHT.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SoundManager.PlayCriminalSecondWind), name: NSNotification.Name(rawValue: EVENT_TYPE.CRIMINAL_SECOND_WIND.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SoundManager.PlayCriminalYikes), name: NSNotification.Name(rawValue: EVENT_TYPE.CRIMINAL_YIKES.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SoundManager.PlayCriminalEscape), name: NSNotification.Name(rawValue: EVENT_TYPE.CRIMINAL_ESCAPE.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SoundManager.PlayCriminalLaugh), name: NSNotification.Name(rawValue: EVENT_TYPE.CRIMINAL_LAUGH.rawValue), object: nil)

        // Robothrower 2000 Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(SoundManager.PlayRobothrowerShoot), name: NSNotification.Name(rawValue: EVENT_TYPE.ROBOTHROWER_SHOOT.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SoundManager.PlayRobothrowerThrow), name: NSNotification.Name(rawValue: EVENT_TYPE.ROBOTHROWER_THROW.rawValue), object: nil)

        // Misc Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(SoundManager.PlayButtonPressed), name: NSNotification.Name(rawValue: EVENT_TYPE.BUTTON_PRESSED.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SoundManager.PlayGameOver), name: NSNotification.Name(rawValue: EVENT_TYPE.GAME_OVER.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SoundManager.PlayFreeMan), name: NSNotification.Name(rawValue: EVENT_TYPE.FREE_MAN.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SoundManager.PlayPromotion), name: NSNotification.Name(rawValue: EVENT_TYPE.PROMOTION.rawValue), object: nil)
    }
    
    func SetHUD(_ hud: SKSpriteNode) {
        self.hud = hud
    }
    
    @objc func PlayBumbleFallBowlingBall() {
        if ( soundOn ) {
            hud!.run(SOUND_BUMBLE_FALL_BOWLING_BALL)
        }
    }
    
    @objc func PlayBumbleFallChickenator() {
        if ( soundOn ) {
            hud!.run(SOUND_BUMBLE_FALL_CHICKENATOR)
        }
    }
    
    @objc func PlayBumbleFallPie() {
        if ( soundOn ) {
            hud!.run(SOUND_BUMBLE_FALL_PIE)
        }
    }
    
    @objc func PlayBumbleDuck() {
        if ( soundOn ) {
            hud!.run(SOUND_BUMBLE_DUCK)
        }
    }
    
    @objc func PlayBumbleJump() {
        if ( soundOn ) {
            hud!.run(SOUND_BUMBLE_JUMP)
        }
    }
    
    @objc func PlayBumbleEscalator() {
        if ( soundOn ) {
            hud!.run(SOUND_BUMBLE_ESCALATOR)
        }
    }
    
    @objc func PlayBumbleHeadshake() {
        if ( soundOn ) {
            hud!.run(SOUND_BUMBLE_HEADSHAKE)
        }
    }
    
    @objc func PlayBumbleWink() {
        if ( soundOn ) {
            hud!.run(SOUND_BUMBLE_WINK)
        }
    }

    @objc func PlayCriminalCaught() {
        if ( soundOn ) {
            hud!.run(SOUND_CRIMINAL_CAUGHT)
        }
    }
    
    @objc func PlayCriminalSecondWind() {
        if ( soundOn ) {
            hud!.run(SOUND_CRIMINAL_SECOND_WIND)
        }
    }
    
    @objc func PlayCriminalYikes() {
        if ( soundOn ) {
            hud!.run(SOUND_CRIMINAL_YIKES)
        }
    }
    
    @objc func PlayCriminalEscape() {
        if ( soundOn ) {
            hud!.run(SOUND_CRIMINAL_ESCAPE)
        }
    }
    
    @objc func PlayCriminalLaugh() {
        if ( soundOn ) {
            hud!.run(SOUND_CRIMINAL_LAUGH)
        }
    }
    
    @objc func PlayRobothrowerShoot() {
        if ( soundOn ) {
            hud!.run(SOUND_ROBOTHROWER_SHOOT)
        }
    }
    
    @objc func PlayRobothrowerThrow() {
        if ( soundOn ) {
            hud!.run(SOUND_ROBOTHROWER_THROW)
        }
    }
    
    @objc func PlayButtonPressed() {
        if ( soundOn ) {
            hud!.run(SOUND_BUTTON_PRESSED)
        }
    }
    
    @objc func PlayGameOver() {
        if ( soundOn ) {
            hud!.run(SOUND_GAME_OVER)
        }
    }
    
    @objc func PlayFreeMan() {
        if ( soundOn ) {
            hud!.run(SOUND_FREE_MAN)
        }
    }

    @objc func PlayPromotion() {
        if ( soundOn ) {
            hud!.run(SOUND_PROMOTION)
        }
    }
}

// MARK: AVAudioPlayerDelegate
extension SoundManager : AVAudioPlayerDelegate {
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("finished playing \(flag)")
    }
    
    
    public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("\(error!.localizedDescription)")
    }
    
}
