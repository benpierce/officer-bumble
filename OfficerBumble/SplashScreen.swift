/*
===============================================================================
SplashScreen

Displays the game's splash screen and transitions to the title screen after 
1.5 seconds.
===============================================================================
*/

import SpriteKit

class SplashScreen: GameScene {
    
    let SPLASH_SCREEN_DELAY = 0.0   // How long the splash screen should stay up (in seconds).
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // Transition to TitleScreen after the delay
        run(SKAction.sequence([
            SKAction.wait(forDuration: SPLASH_SCREEN_DELAY),
            SKAction.run() {
                self.TransitionToTitleScreen()
            },
        ]))
    }

    fileprivate func TransitionToTitleScreen() {
        super.PresentScene(TitleScreen(size: self.size, resourceName: "titlescreen", isMuted: false))
    }
}
