/*
===============================================================================
GameStateManager

Manages game state transitions such as winning a level or losing a level, 
showing a promotional screen. Also keeps track of game state specific data such
as score, lives, difficulty, etc...
===============================================================================
*/

import Foundation
import SpriteKit

open class GameStateManager {
    fileprivate let PROMOTION_SCREEN_PERCENTAGE = 0.3   // 30% chance of seeing a promotional screen when you win a level.
    
    fileprivate var difficulty: Difficulty
    fileprivate var score: Int = 0
    fileprivate var lives: Int = 0
    fileprivate var level: Int = 1
    fileprivate var showTutorial: Bool = true
    fileprivate var currentLevelType: LEVEL = LEVEL.shopping_MALL
    fileprivate var showLoading: Bool = true
    
    // All the different level types in the game.
    fileprivate enum LEVEL: Int {
        case shopping_MALL = 1
        case museum = 2
        case bank = 3
        case casino = 4
        
        static func Name(_ level: Int) -> String {
            switch(level) {
            case 1:
                return "shoppingmall"
            case 2:
                return "museum"
            case 3:
                return "bank"
            case 4:
                return "casino"
            default:
                return "shoppingmall"
            }
        }
    }
    
    public init(difficulty: Difficulty) {
        self.difficulty = difficulty

        InitializeGame()
    }
    
    open func NewGame(_ gameScene: GameScene) {
        InitializeGame()
        StartGame(gameScene)
    }
    
    fileprivate func InitializeGame() {
        score = 0
        lives = difficulty.STARTING_LIVES
        level = 1
        currentLevelType = LEVEL.shopping_MALL
        showTutorial = true
    }
    
    open func StartGame(_ gameScene: GameScene) {
        StartLevel(gameScene)
    }

    /*
    ===============================================================================
    LevelWon
    
    Called whenever Bumble captures a criminal. Will increment the level, and determine
    if we should show any kind of promotional screen including:
    
    1. Badge Awarded - If you've gotten a badge.
    2. Next Badge - To show you which badge you're in the running to get.
    3. Next Free Life - To show you how many more points you need to get your next free life.
    4. Invite Some Friends - Asks you to invite some friends from Facebook (only if you're logged into Facebook.
    ===============================================================================
    */
    open func LevelWon(_ gameScene: GameScene) {
        level = level + 1
        showTutorial = false
        let gm = GameSharedPreferences()
        
        var caught = gm.ReadInteger(gm.CRIMINALS_CAUGHT_PREFERENCE)
        var caughtHardcore = gm.ReadInteger(gm.CRIMINALS_CAUGHT_HARDCORE_PREFERENCE)
        let bm = BadgeManager()
        
        caught = caught + 1
        if ( difficulty.DifficultyName == "Hardcore" ) {
            caughtHardcore = caughtHardcore + 1
        }
        
        // Save the # of Criminals Caught
        IncrementTotalCriminalsCaught()
        
        // Save your high scores locally.
		//LeaderboardServices().SaveLocally(self, criminalsCaught: caught, criminalsCaughtHardcore: caughtHardcore)
		
        let badge = bm.QueryBadge(caught)
        let nextBadge = bm.GetNextBadge(caught + 1)
        
        if(badge != nil) {
            ShowBadgeAwardedScreen(gameScene, criminalsCaught: caught, badge: badge!, nextBadge: nextBadge)
        } else
        {
            if (!ShowPromotionScreen(gameScene)) {
                NextLevel(gameScene)    // Will eventually add bonus score.
            }
        }
    }
    
    fileprivate func ShowPromotionScreen(_ gameScene: GameScene) -> Bool {
        var result = false
        let random = Double.random(0, max: 1)
        
        if ( random <= PROMOTION_SCREEN_PERCENTAGE) {
            // Figure out the promotion screen to show.
            result = true
            
            let screen = Int.random(1...3)
            
            if ( screen == 1 ) {
                //ShowInviteFriendsScreen(gameScene)
                ShowNextBadgeScreen(gameScene)
            } else if ( screen == 2 ) {
                ShowNextBadgeScreen(gameScene)
            } else if ( screen == 3 ) {
                ShowFreeManScreen(gameScene)
            }
        }
        
        return result
    }
    
    /*
    fileprivate func ShowInviteFriendsScreen(_ gameScene: GameScene) {
        let isMuted = (gameScene.sm != nil) ? gameScene.sm!.IsMuted() : false
        
        let newScene = FacebookInviteScreen(size: gameScene.size, gameStateManager: self, isMuted: isMuted)
        let sceneAction = SKAction.run( { gameScene.PresentScene(newScene) } )
        gameScene.run(sceneAction)
    }
    */
    
    fileprivate func ShowBadgeAwardedScreen(_ gameScene: GameScene, criminalsCaught: Int, badge: BadgeManager.Badge, nextBadge: BadgeManager.Badge?) {
        let isMuted = (gameScene.sm != nil) ? gameScene.sm!.IsMuted() : false
        
        let newScene = BadgeAwardedScreen(size: gameScene.size, gameStateManager: self, isMuted: isMuted, criminalsCaught: criminalsCaught, badge: badge, nextBadge: nextBadge)
        let sceneAction = SKAction.run( { gameScene.PresentScene(newScene) } )
        gameScene.run(sceneAction)
    }
    
    /*
    ===============================================================================
    ShowNextBadgeScreen
    
    Shows the promotional screen that tells you when you're due for the next
    badge.
    ===============================================================================
    */
    fileprivate func ShowNextBadgeScreen(_ gameScene: GameScene) {
        let isMuted = (gameScene.sm != nil) ? gameScene.sm!.IsMuted() : false
        
        let gm = GameSharedPreferences()
        let criminalsCaught = gm.ReadInteger(gm.CRIMINALS_CAUGHT_PREFERENCE)
        
        let nextBadge = BadgeManager().GetNextBadge(criminalsCaught)
        
        let newScene = NextBadgeScreen(size: gameScene.size, gameStateManager: self, isMuted: isMuted, criminalsCaught: criminalsCaught, nextBadge: nextBadge)
        let sceneAction = SKAction.run( { gameScene.PresentScene(newScene) } )
        gameScene.run(sceneAction)
    }
    
    fileprivate func ShowFreeManScreen(_ gameScene: GameScene) {
        let isMuted = (gameScene.sm != nil) ? gameScene.sm!.IsMuted() : false
        
        let sceneAction = SKAction.run( { gameScene.PresentScene(NextLifeScreen(size: gameScene.size, gameStateManager: self, isMuted: isMuted)) } )
        gameScene.run(sceneAction)
    }
    
    open func LevelLost(_ gameScene: GameScene) {
        showTutorial = false
        
        // On easy or normal you get to continue.
        if( difficulty.DifficultyName == "Hardcore") {
            StartGameOver(gameScene)
        } else {
            lives = lives - 1
            
            // If we're out of lives, then show game over screen.
            // else Now we can show an ad/retry screen.
            if(lives <= 0) {
                StartGameOver(gameScene)
            } else {
                StartLevel(gameScene)
            }
        }
    }
    
    open func IncrementScore(_ points: Int) -> Bool {
        var freelife = false
        
        let nextFreeLife = (score / difficulty.FREE_LIFE_SCORE) * difficulty.FREE_LIFE_SCORE + difficulty.FREE_LIFE_SCORE
        let freeLifeCandidate = (score < nextFreeLife && score + points >= nextFreeLife) ? true : false
        self.score = self.score + points
        
        if ( freeLifeCandidate && lives < difficulty.MAX_LIVES) {
            freelife = true
            lives = lives + 1
            NotificationCenter.default.post(name: Notification.Name(rawValue: EVENT_TYPE.FREE_MAN.rawValue), object: nil)
        }
        
        return freelife
    }
    
    open func NextLevel(_ gameScene: GameScene) {
        let nextLevel = GetRandomLevelWithoutRepeats()
        self.currentLevelType = nextLevel
        StartLevel(gameScene)
    }
    
    open func ShowTutorial() -> Bool {
        return showTutorial
    }
    
    open func GetScore() -> Int {
        return self.score
    }
    
    open func GetNextFreeLifeScore() -> Int {
        let mod = self.score % difficulty.FREE_LIFE_SCORE
        return difficulty.FREE_LIFE_SCORE - mod
    }
    
    open func GetLives() -> Int {
        return self.lives
    }
    
    open func GetDifficulty() -> Difficulty {
        return self.difficulty
    }
    
    open func GetLevel() -> Int {
        return self.level
    }
    
    open func GetResourceName() -> String {
        return LEVEL.Name(currentLevelType.rawValue)
    }
    
    /****************************************************************************************************
     Private Methods
    *****************************************************************************************************/
    fileprivate func StartLevel(_ gameScene: GameScene) {
        let isMuted = (gameScene.sm != nil) ? gameScene.sm!.IsMuted() : false
        
        let sceneAction = SKAction.run({ gameScene.PresentScene(LevelScreen(size: gameScene.size, gameStateManager: self, isMuted: isMuted)) })
        
        if ( showLoading ) {
            showLoading = false   // So we only show the loading bar on initial load of first level.

            let loadingAction = SKAction.run(gameScene.ShowLoading)
            let sequence = SKAction.sequence([loadingAction, sceneAction])
            gameScene.run(sequence)
        } else {
            gameScene.PresentScene(LevelScreen(size: gameScene.size, gameStateManager: self, isMuted: isMuted))
        }
    }
    
    fileprivate func StartGameOver(_ gameScene: GameScene) {
        let isMuted = (gameScene.sm != nil) ? gameScene.sm!.IsMuted() : false
        
        let sceneAction = SKAction.run( { gameScene.PresentScene(GameOverScreen(size: gameScene.size, gameStateManager: self, isMuted: isMuted)) } )
        gameScene.run(sceneAction)
    }
    
    fileprivate func StartGameOverHardcore(_ gameScene: GameScene) {
        let isMuted = (gameScene.sm != nil) ? gameScene.sm!.IsMuted() : false
        
        let sceneAction = SKAction.run( { gameScene.PresentScene(GameOverScreen(size: gameScene.size, gameStateManager: self, isMuted: isMuted)) } )
        gameScene.run(sceneAction)
    }
    
    // Will eventually return a level that's random (but different) than the one we're currently on. This is just so
    // people don't become bored by having the same level repeat over and over in the same order every time.
    fileprivate func GetRandomLevelWithoutRepeats() -> LEVEL {
        var random: Int = 0
        var nextLevel = currentLevelType
        
        while nextLevel == currentLevelType {
            random = Int.random(1...4)
            switch (random) {
            case 1:
                nextLevel = LEVEL.shopping_MALL
            case 2:
                nextLevel = LEVEL.museum
            case 3:
                nextLevel = LEVEL.bank
            case 4:
                nextLevel = LEVEL.casino
            default:
                nextLevel = LEVEL.shopping_MALL
            }
        }
        
        
        return nextLevel
    }
    
    /*
    ===============================================================================
    IncrementTotalCriminalsCaught
    
    Uses NSUserDefaults to retrieve the number of criminals that have been caught,
    increments by 1, and then re-saves it.
    ===============================================================================
    */
    private func IncrementTotalCriminalsCaught() -> Int {
        let defaults: UserDefaults = UserDefaults.standard
        var caught: Int = 0
        
        if (defaults.object(forKey: "criminalsCaught") as? Int) != nil {
            caught = defaults.object(forKey: "criminalsCaught") as! Int
        }
        
        caught = caught + 1
        defaults.set(caught, forKey: "criminalsCaught")
        defaults.synchronize()
        
        return caught
    }
}
