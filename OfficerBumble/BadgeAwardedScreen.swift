import Foundation
import SpriteKit

open class BadgeAwardedScreen : GameScene {
    fileprivate var gameStateManager: GameStateManager
    fileprivate let criminalsCaught: Int
    fileprivate let badge: BadgeManager.Badge
    fileprivate let nextBadge: BadgeManager.Badge?
    
    init(size: CGSize, gameStateManager: GameStateManager, isMuted: Bool, criminalsCaught: Int, badge: BadgeManager.Badge, nextBadge: BadgeManager.Badge?) {
        self.gameStateManager = gameStateManager
        self.criminalsCaught = criminalsCaught
        self.badge = badge
        self.nextBadge = nextBadge
        
        super.init(size: size, resourceName: "badgeawarded", isMuted: isMuted)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func didMove(to view: SKView) {
        super.didMove(to: view)
        
        var text = "Congratulations on your \(criminalsCaught)\(Int.GetNumericSuffix(criminalsCaught)) career bust. Those McBurgler Brothers are really starting to get the message. As a token of the forces' appreciation, we're promoting you to \(badge.badgeName)."
        
        if ( nextBadge != nil ) {
            let nextBadgeIn = nextBadge!.criminalsCaught - criminalsCaught
            text = text + " Arrest \(nextBadgeIn) more criminals and there's a \(nextBadge!.badgeName) promotion in it for you."
        }
        
        let popup = Popup()
        popup.ShowOK(text, display: display, width: 1.0, scene: self, world: world!, inputManager: inputManager, okBlock: { self.gameStateManager.NextLevel(self) })
                
        NotificationCenter.default.post(name: Notification.Name(rawValue: EVENT_TYPE.PROMOTION.rawValue), object: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: EVENT_TYPE.SHOW_AD.rawValue), object: nil)
    }
    
    func shareSuccess() {
        self.gameStateManager.NextLevel(self)
    }
    
    func ShareFailed(_ message: String) {
    }
    
}
