/*
===============================================================================
TitleScreen

Displays the game's title screen and wires up all of the buttons to their
respective actions.
===============================================================================
*/

import SpriteKit

class TitleScreen: GameScene {
    
    fileprivate var popup = Popup()
    fileprivate let offscreenPosition = CGPoint(x: -5000, y: -5000)
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        if ( sm != nil ) {
            sm!.PlayTitleMusic()
        
            if ( sm!.IsMuted() ) {
                sm!.ToggleMusic()
            }
        }
        
        WireButtons()
    }
    
    fileprivate func WireButtons() {
        // Training Button.
        super.WireButton("btntraining", pressBlock: TransitionToTraining)
        super.WireButton("btneasy", pressBlock: StartEasy)
        super.WireButton("btnnormal", pressBlock: StartNormal)
        super.WireButton("btnhard", pressBlock: StartHard)
        super.WireButton("btnhardcore", pressBlock: StartHardcore)
    }
    
    fileprivate func StartEasy() {
        let difficulty = Easy(display: super.display)
        let gameStateManager = GameStateManager(difficulty: difficulty)
        gameStateManager.StartGame(self)
    }
    
    fileprivate func StartNormal() {
        let difficulty = Normal(display: super.display)
        let gameStateManager = GameStateManager(difficulty: difficulty)
        gameStateManager.StartGame(self)
    }
    
    fileprivate func StartHard() {
        let difficulty = Hard(display: super.display)
        let gameStateManager = GameStateManager(difficulty: difficulty)
        gameStateManager.StartGame(self)
    }
    
    fileprivate func StartHardcore() {
        let difficulty = Hardcore(display: super.display)
        let gameStateManager = GameStateManager(difficulty: difficulty)
        gameStateManager.StartGame(self)
    }
    
    fileprivate func TransitionToTraining() {
        let loadingAction = SKAction.run(super.ShowLoading)
        let sceneAction = SKAction.run( self.PresentTraining )
        let sequence = SKAction.sequence([loadingAction, sceneAction])
        self.run(sequence)
    }
    
        fileprivate func PresentTraining() {
        super.PresentScene(Training(size: self.size, resourceName: "training", isMuted: IsMuted()))
    }
    
    fileprivate func PresentLeaderboard() {
        super.PresentScene(LeaderboardScreen(size: self.size, resourceName: "leaderboard", isMuted: IsMuted()))
    }
    
    fileprivate func IsMuted() -> Bool {
        var result = false
        
        if ( sm != nil ) {
            result = sm!.IsMuted()
        }
        
        return result
    }
}
