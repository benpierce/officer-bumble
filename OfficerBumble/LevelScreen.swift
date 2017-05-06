/*
===============================================================================
LevelScreen
===============================================================================
*/

import SpriteKit

class LevelScreen: GameScene {
    fileprivate let SCORE_INCREMENT = 50
    fileprivate let BASE_LEVEL_CLEARED_SCORE = 1000
    
    var bumble : Bumble?
    var criminal : Criminal?
    var hudManager : HUDManager?
    var gameStateManager : GameStateManager
    var toast: Toast?
    
    /* Pause Related Items
    
       There's a bug with SpriteKit whereby if you come back in after pushing the home button, 
       the scene itself will be paused and all nodes will be unpaused. We never want the scene 
       paused so we handle that in the base classe's update() method, however the world should
       be paused when you come back in. Unfortunately, if you set world!.paused = true immediately
       in the first frame, it won't take until someone clicks somewhere... so we have to set the pause
       a few frames out to ensure that it happens without any user interaction.
    */
    var pausePopup = Popup()    // Popup that will be used to show pausing.
    var pauseFrame = 0          // How many frames to pause the game in?
    var worldPauseFrame = 0
    var needsPause = false      // Whether or not we should be in a future frame.
    var needsWorldPause = false
    
    init(size: CGSize, gameStateManager: GameStateManager, isMuted: Bool) {
        self.gameStateManager = gameStateManager
        
        super.init(size: size, resourceName: gameStateManager.GetResourceName(), isMuted: isMuted)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        NotificationCenter.default.addObserver(self, selector: #selector(LevelScreen.QueuePause), name: NSNotification.Name(rawValue: EVENT_TYPE.APP_BECAME_ACTIVE.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LevelScreen.LevelWon), name: NSNotification.Name(rawValue: EVENT_TYPE.LEVEL_WON.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LevelScreen.LevelLost), name: NSNotification.Name(rawValue: EVENT_TYPE.CRIMINAL_ESCAPE.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LevelScreen.IncrementScore), name: NSNotification.Name(rawValue: EVENT_TYPE.SCORE_WEAPON.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LevelScreen.CriminalCaughtScore), name: NSNotification.Name(rawValue: EVENT_TYPE.CRIMINAL_CAUGHT.rawValue), object: nil)
        
        if ( gameStateManager.GetDifficulty().DifficultyName == "Hardcore") {
            NotificationCenter.default.addObserver(self, selector: #selector(LevelScreen.GameOverHardcore), name: NSNotification.Name(rawValue: EVENT_TYPE.BUMBLE_RECOVER_FROM_FALL.rawValue), object: nil)
        }
        
        // Toast
        toast = Toast(hud: self.hud!)
        
        // Wire up Bumble to UI events.
        bumble = (super.GetSpriteNodeOrDie("bumble") as! Bumble)
        bumble!.Initialize(inputManager, difficulty: gameStateManager.GetDifficulty())
        bumble!.SetPhysics(physicsManager)
        bumble!.Run()
        BumbleCamera(bumble!)
        
        // Get Criminal.
        criminal = (super.GetSpriteNodeOrDie("criminal") as! Criminal)
        criminal!.Initialize(world!, physicsManager: physicsManager, bumble: bumble!, difficulty: gameStateManager.GetDifficulty())
        criminal!.SetPhysics(physicsManager)
        criminal!.Run()
        physicsWorld.contactDelegate = self
        
        print("Bumble initial position is \(bumble!.position.x), \(bumble!.position.y)")
        
        AddHUD()
        
        if ( gameStateManager.ShowTutorial() ) {
            needsWorldPause = true
            toast!.Show("Level \(gameStateManager.GetLevel())", timeToDisplay: 3, showTimer: true, display: display, completionBlock: BeginGame)
        } else {
            toast!.Show("Level \(gameStateManager.GetLevel())", timeToDisplay: 1, display: display, completionBlock: {})
        }
        
        sm!.PlayInGameMusic()
        
        if ( sm!.IsMuted() ) {
            sm!.ToggleMusic()
        }
        
        // Initialize HUD so we see the scores and lives right away.
        hudManager!.UpdateScore(gameStateManager.GetScore())
        hudManager!.UpdateLives(gameStateManager.GetLives(), hud: hud!, display: display)
        if ( gameStateManager.GetDifficulty().DifficultyName == "Hardcore" ) {
            hudManager!.HideLives()
        }
    }
    
    fileprivate func BeginGame() {
        if ( !pausePopup.IsOpen() ) {
            needsWorldPause = false
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        NeedsPause()    // Check to see if we've got a pause queued up from the home screen.
        
        bumble!.Update(currentTime, isPaused: world!.isPaused)
        criminal!.Update(currentTime, bumble: bumble!, maximumWeaponVelocity: super.maximumWeaponVelocity, isPaused: world!.isPaused)
        hudManager!.Update(bumble!, criminal: criminal!, world: world!)
        toast!.Update(currentTime)
        
        super.update(currentTime)
    }
    
    fileprivate func AddHUD() {
        let muteButton = super.CreateMuteButton()
        let pauseButton = super.CreatePauseButton(PauseGame)
        hudManager = HUDManager(muteButton: muteButton!, pauseButton: pauseButton!)
        
        hudManager!.Show(super.display, hud: super.hud!, lives: gameStateManager.GetLives())
    }
    
    fileprivate func NeedsPause() {
        if ( needsPause ) {
            pauseFrame = pauseFrame - 1
            if ( pauseFrame == 0 ) {
                needsPause = false
                PauseGame()
            }
        }
        
        if ( needsWorldPause ) {
            world!.isPaused = true
        } else {
            world!.isPaused = false
        }
    }
    
    @objc fileprivate func QueuePause() {
        needsPause = true
        pauseFrame = 2
    }
    
    fileprivate func QueueWorldPause() {
        needsWorldPause = true
        worldPauseFrame = 1
    }
    
    fileprivate func PauseGame() {
        if ( pausePopup.IsOpen() ) {
            pausePopup.Close(world!, scene: self)
        }
        
        hudManager!.TogglePauseOff()
        pausePopup.ShowPaused(display, width: 1.0, scene: self, world: world!, inputManager: inputManager, resumeBlock: UnpauseGame, mainmenuBlock: TransitionToTitle)
    }
    
    fileprivate func UnpauseGame() {
        hudManager!.TogglePauseOn()
        self.pausePopup.Close(self.world!, scene: self)
    }
    
    @objc fileprivate func LevelWon() {
        // Pause the world, and show a toast that the criminal got away before transitioning to the next level.
        world!.isPaused = true
        gameStateManager.LevelWon(self)
    }
    
    @objc fileprivate func LevelLost() {
        // Pause the world, and show a toast that the criminal got away before transitioning to the next level.
        world!.isPaused = true
        toast!.Show("HE GOT AWAY", timeToDisplay: 0.75, display: display, completionBlock: { self.gameStateManager.LevelLost(self) } )
    }
    
    @objc fileprivate func GameOverHardcore() {
        self.gameStateManager.LevelLost(self)
    }
    
    @objc fileprivate func CriminalCaughtScore() {
        if ( gameStateManager.IncrementScore(BASE_LEVEL_CLEARED_SCORE) ) {
            hudManager!.UpdateLives(gameStateManager.GetLives(), hud: hud!, display: display)
        }
        hudManager!.UpdateScore(gameStateManager.GetScore())
    }
    
    @objc fileprivate func IncrementScore() {
        if ( gameStateManager.IncrementScore(SCORE_INCREMENT) ) {
            hudManager!.UpdateLives(gameStateManager.GetLives(), hud: hud!, display: display)
        }
        hudManager!.UpdateScore(gameStateManager.GetScore())
    }
}
