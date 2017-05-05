import Foundation
import SpriteKit

open class FacebookInviteScreen : GameScene {
    /*
    fileprivate var gameStateManager: GameStateManager
    
    init(size: CGSize, gameStateManager: GameStateManager, isMuted: Bool) {
        self.gameStateManager = gameStateManager
        
        super.init(size: size, resourceName: "facebookinvite", isMuted: isMuted)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func didMove(to view: SKView) {
        super.didMove(to: view)
        
        let text = "Bumble, the town is overrun with McBurgler Brothers. Invite some new recruits from Facebook to help clean up this city!"
        
        let popup = Popup()
        
        popup.ShowInviteNoThanks(text, display: display, width: 1.0, scene: self, world: world!, inputManager: inputManager, noThanksBlock: { self.gameStateManager.NextLevel(self) }, inviteBlock: {FB.invite(self.inviteSuccess, failure: self.inviteFailed) } )
    
        NotificationCenter.default.post(name: Notification.Name(rawValue: EVENT_TYPE.PROMOTION.rawValue), object: nil)
    }
    
    func inviteSuccess() {
        self.gameStateManager.NextLevel(self)
    }
    
    func inviteFailed(_ message: String) {
        print("Invite Failed \(message)")
    }
    */
    
}
