/*
===============================================================================
Popup

Handles all logic related to showing a popup box with a customizable set of
buttons.
===============================================================================
*/

import Foundation
import SpriteKit

final class Popup : SKSpriteNode {
    
    fileprivate let FONT_SIZE = CGFloat(0.0625)
    fileprivate let DEFAULT_BUTTON_MARGIN = Margin(marginTop: 0, marginBottom: 0.025, marginLeft: 0, marginRight: 0)
    fileprivate let BUTTON_MARGIN_LEFT = Margin(marginTop: 0, marginBottom: 0.025, marginLeft: 0.07, marginRight: 0)
    fileprivate let BUTTON_MARGIN_RIGHT = Margin(marginTop: 0, marginBottom: 0.025, marginLeft: 0, marginRight: 0.07)
    fileprivate let BUTTON_MARGIN_RIGHT_NT = Margin(marginTop: 0, marginBottom: 0.10, marginLeft: 0, marginRight: 0.07)
    fileprivate let FB_BUTTON_MARGIN = Margin(marginTop: 0, marginBottom: 0.05, marginLeft: 0.15, marginRight: 0)
    fileprivate let FB_BUTTON_HEIGHT = CGFloat(0.2)
    fileprivate let FB_BUTTON_WIDTH = CGFloat(0.2)
    
    //private let BUTTON_HEIGHT = CGFloat(0.076)  // Height of all buttons.
    fileprivate let BUTTON_HEIGHT = CGFloat(0.1)
    
    // Top and bottom padding for the label.
    fileprivate let TOP_PADDING_PERCENT = CGFloat(0.02)     // How much padding should we leave at the top of the label (in % of screen height).
    fileprivate let BOTTOM_PADDING_PERCENT = CGFloat(0.06)  // How much padding should we leave at the bottom of the label (in % of screen height).
    
    // State Constants
    fileprivate var isOpen : Bool = false                           // Whether or not the popup is currently open.
    fileprivate var label: MultiLineTextLabel?                    // Our multiline label to display text.

    // Initialize the popup in memory.
    init() {
        let texture = textureManager.taTools.textureNamed("popup")        // We have to start off with something since this inherits from SKSpriteNode.
        super.init(texture: texture, color: UIColor.clear, size: texture.size())  // Initialize the parent.
        self.name = "Popup"
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    ===============================================================================
    ShowOK
    
    Shows a popup box with an ok button.
    ===============================================================================
    */
    func ShowOK(_ text: String, display: Display, width: CGFloat, scene : GameScene, world: SKSpriteNode, inputManager: InputManager, okBlock: @escaping () -> ()) {
        Show(text, display: display, width: width, scene: scene, world: world)
        
        let button = GetOKButton(display, anchorTo: Display.ANCHOR.BOTTOM_CENTER, okBlock: okBlock, inputManager: inputManager, alignRight: false)
        
        self.addChild(button)
    }
    
    func ShowShareNoThanks(_ text: String, display: Display, width: CGFloat, scene : GameScene, world: SKSpriteNode, inputManager: InputManager, okBlock: @escaping () -> (), shareBlock: @escaping () -> ()) {
        Show(text, display: display, width: width, height: 0.95, scene: scene, world: world)
        
        let okButton = GetNoThanksButton(display, anchorTo: Display.ANCHOR.BOTTOM_RIGHT, noThanksBlock: okBlock, inputManager: inputManager)
        let shareButton = GetShareButton(display, anchorTo: Display.ANCHOR.BOTTOM_LEFT, shareBlock: shareBlock, inputManager: inputManager)
        self.addChild(okButton)
        self.addChild(shareButton)
    }
    
    func ShowInviteNoThanks(_ text: String, display: Display, width: CGFloat, scene : GameScene, world: SKSpriteNode, inputManager: InputManager, noThanksBlock: @escaping () -> (), inviteBlock: @escaping () -> ()) {
    
        Show(text, display: display, width: width, height: 0.60, scene: scene, world: world)
    
        let noThanksButton = GetNoThanksButton(display, anchorTo: Display.ANCHOR.BOTTOM_RIGHT, noThanksBlock: noThanksBlock, inputManager: inputManager)
        let inviteButton = GetInviteButton(display, anchorTo: Display.ANCHOR.BOTTOM_LEFT, inviteBlock: inviteBlock, inputManager: inputManager)
        self.addChild(noThanksButton)
        self.addChild(inviteButton)
    }
    
    func ShowPaused(_ display: Display, width: CGFloat, scene : GameScene, world: SKSpriteNode, inputManager: InputManager, resumeBlock: @escaping () -> (), mainmenuBlock: @escaping () -> ()) {
        Show("Paused", display: display, width: width, scene: scene, world: world)
        
        let mainmenuButton = GetMainMenuButton(display, anchorTo: Display.ANCHOR.BOTTOM_LEFT, mainmenuBlock: mainmenuBlock, inputManager: inputManager)
        let resumeButton = GetResumeButton(display, anchorTo: Display.ANCHOR.BOTTOM_RIGHT, resumeBlock: resumeBlock, inputManager: inputManager)
        
        self.addChild(resumeButton)
        self.addChild(mainmenuButton)
    }
    
    func ShowMainMenuTryAgain(_ text: String, display: Display, width: CGFloat, scene: GameScene, world: SKSpriteNode, inputManager: InputManager, tryagainBlock: @escaping () -> (), mainmenuBlock: @escaping () -> ()) {
        
        Show(text, display: display, width: width, scene: scene, world: world)
        
        let mainmenuButton = GetMainMenuButton(display, anchorTo: Display.ANCHOR.BOTTOM_LEFT, mainmenuBlock: mainmenuBlock, inputManager: inputManager)
        let tryagainButton = GetTryAgainButton(display, anchorTo: Display.ANCHOR.BOTTOM_RIGHT, tryagainBlock: tryagainBlock, inputManager: inputManager)
        
        self.addChild(mainmenuButton)
        self.addChild(tryagainButton)
    }
    
    fileprivate func GetOKButton(_ display: Display, anchorTo: Display.ANCHOR, okBlock: @escaping () -> (), inputManager: InputManager, alignRight: Bool) -> GameButton {
        
        inputManager.DeRegisterButtonWithName("PopupOK")    // DeRegister in case there are any old references hanging around.
        let size = display.GetSizeByPercentageOfScene(0.25, heightPercent : BUTTON_HEIGHT, considerAspectRatio: true)
        // 0.33
        
        let okButton = GameButton(texture: textureManager.taTools.textureNamed("btnok1"), texturePressed: textureManager.taTools.textureNamed("btnok2"))
        okButton.Initialize("PopupOK", inputManager: inputManager, pressBlock: okBlock)
        okButton.size = size
        if ( alignRight ) {
            okButton.position = display.GetParentAnchor(okButton, parent : self, margin : BUTTON_MARGIN_RIGHT, anchorTo: anchorTo)
        } else {
            okButton.position = display.GetParentAnchor(okButton, parent : self, margin : DEFAULT_BUTTON_MARGIN, anchorTo: anchorTo)
        }
        okButton.zPosition = ZPOSITION.popup_UI.rawValue
        
        return okButton
    }
    
    fileprivate func GetShareButton(_ display: Display, anchorTo: Display.ANCHOR, shareBlock: @escaping () -> (), inputManager: InputManager) -> GameButton {
        inputManager.DeRegisterButtonWithName("PopupShare") // Deregister in case there are any old references hanging around.
        let size = display.GetSizeByPercentageOfScene(FB_BUTTON_WIDTH, heightPercent: FB_BUTTON_HEIGHT, considerAspectRatio: true)
        
        let shareButton = GameButton(texture: textureManager.taTools.textureNamed("btnshare1"), texturePressed: textureManager.taTools.textureNamed("btnshare2"))
        shareButton.Initialize("PopupShare", inputManager: inputManager, pressBlock: shareBlock)
        shareButton.size = size
        shareButton.position = display.GetParentAnchor(shareButton, parent : self, margin: FB_BUTTON_MARGIN, anchorTo: anchorTo)
        shareButton.zPosition = ZPOSITION.popup_UI.rawValue
        
        return shareButton
    }

    fileprivate func GetInviteButton(_ display: Display, anchorTo: Display.ANCHOR, inviteBlock: @escaping () -> (), inputManager: InputManager) -> GameButton {
        inputManager.DeRegisterButtonWithName("PopupInvite") // Deregister in case there are any old references hanging around.
        let size = display.GetSizeByPercentageOfScene(FB_BUTTON_WIDTH, heightPercent: FB_BUTTON_HEIGHT, considerAspectRatio: true)
        
        let shareButton = GameButton(texture: textureManager.taTools.textureNamed("btninvite1"), texturePressed: textureManager.taTools.textureNamed("btninvite2"))
        shareButton.Initialize("PopupInvite", inputManager: inputManager, pressBlock: inviteBlock)
        shareButton.size = size
        shareButton.position = display.GetParentAnchor(shareButton, parent : self, margin: FB_BUTTON_MARGIN, anchorTo: anchorTo)
        shareButton.zPosition = ZPOSITION.popup_UI.rawValue
        
        return shareButton
    }
    
    fileprivate func GetMainMenuButton(_ display: Display, anchorTo: Display.ANCHOR, mainmenuBlock: @escaping () -> (), inputManager: InputManager) -> GameButton {
        inputManager.DeRegisterButtonWithName("PopupMainMenu")
        let size = display.GetSizeByPercentageOfScene(0.4, heightPercent: BUTTON_HEIGHT, considerAspectRatio: true)
        let mainmenuButton = GameButton(texture: textureManager.taTools.textureNamed("btnmainmenu1"), texturePressed: textureManager.taTools.textureNamed("btnmainmenu2"))
        mainmenuButton.Initialize("PopupMainMenu", inputManager: inputManager, pressBlock: mainmenuBlock)
        mainmenuButton.size = size
        mainmenuButton.position = display.GetParentAnchor(mainmenuButton, parent: self, margin : BUTTON_MARGIN_LEFT, anchorTo: anchorTo)
        mainmenuButton.zPosition = ZPOSITION.popup_UI.rawValue
        
        return mainmenuButton
    }

    fileprivate func GetNoThanksButton(_ display: Display, anchorTo: Display.ANCHOR, noThanksBlock: @escaping () -> (), inputManager: InputManager) -> GameButton
    {
        inputManager.DeRegisterButtonWithName("PopupNoThanks")
        let size = display.GetSizeByPercentageOfScene(0.44, heightPercent: BUTTON_HEIGHT, considerAspectRatio: true)
        let tryagainButton = GameButton(texture: textureManager.taTools.textureNamed("btnnothanks1"), texturePressed: textureManager.taTools.textureNamed("btnnothanks2"))
        tryagainButton.Initialize("PopupNoThanks", inputManager: inputManager, pressBlock: noThanksBlock)
        tryagainButton.size = size
        tryagainButton.position = display.GetParentAnchor(tryagainButton, parent: self, margin : BUTTON_MARGIN_RIGHT_NT, anchorTo: anchorTo)
        tryagainButton.zPosition = ZPOSITION.popup_UI.rawValue
        
        return tryagainButton
    }
    
    fileprivate func GetTryAgainButton(_ display: Display, anchorTo: Display.ANCHOR, tryagainBlock: @escaping () -> (), inputManager: InputManager) -> GameButton
    {
        inputManager.DeRegisterButtonWithName("PopupTryAgain")
        let size = display.GetSizeByPercentageOfScene(0.44, heightPercent: BUTTON_HEIGHT, considerAspectRatio: true)
        let tryagainButton = GameButton(texture: textureManager.taTools.textureNamed("btntryagain1"), texturePressed: textureManager.taTools.textureNamed("btntryagain2"))
        tryagainButton.Initialize("PopupTryAgain", inputManager: inputManager, pressBlock: tryagainBlock)
        tryagainButton.size = size
        tryagainButton.position = display.GetParentAnchor(tryagainButton, parent: self, margin : BUTTON_MARGIN_RIGHT, anchorTo: anchorTo)
        tryagainButton.zPosition = ZPOSITION.popup_UI.rawValue
        
        return tryagainButton
    }
    
    fileprivate func GetResumeButton(_ display: Display, anchorTo: Display.ANCHOR, resumeBlock: @escaping () -> (), inputManager: InputManager) -> GameButton {
        inputManager.DeRegisterButtonWithName("PopupResume")
        let size = display.GetSizeByPercentageOfScene(0.4, heightPercent: BUTTON_HEIGHT, considerAspectRatio: true)
        let resumeButton = GameButton(texture: textureManager.taTools.textureNamed("btnresume1"), texturePressed: textureManager.taTools.textureNamed("btnresume2"))
        resumeButton.Initialize("PopupResume", inputManager: inputManager, pressBlock: resumeBlock)
        resumeButton.size = size
        resumeButton.position = display.GetParentAnchor(resumeButton, parent: self, margin : BUTTON_MARGIN_RIGHT, anchorTo: anchorTo)
        resumeButton.zPosition = ZPOSITION.popup_UI.rawValue
        
        return resumeButton
    }
    
    /*
    ===============================================================================
    Close
    
    Close the popup screen (remove everything popup related from the scene and all children) and
    unpause the world.
    ===============================================================================
    */
    func Close(_ world: SKSpriteNode, scene: GameScene) {
        self.removeAllChildren()
        self.removeFromParent()
        isOpen = false
        scene.isPaused = false 
        world.isPaused = false
    }
    
    func IsOpen() -> Bool {
        return isOpen
    }

    
    fileprivate func Show(_ text : String, display : Display, width: CGFloat, scene : GameScene, world: SKSpriteNode) {
        Show(text, display: display, width: width, height: 0, scene: scene, world: world)
    }
    
    /*
    ===============================================================================
    Show
    
    Sets up all of the base functionality of a popup (IE: the text, the sizing, etc...)
    Does not setup any of the buttons.
    ===============================================================================
    */
    fileprivate func Show(_ text : String, display : Display, width: CGFloat, height: CGFloat, scene : GameScene, world: SKSpriteNode) {
        isOpen = true
        
        let font_height = display.GetNormalizedScreenHeightByPercentage(FONT_SIZE)
        let font_width = display.GetNormalizedScreenWidthByPercentage(FONT_SIZE)
        let width_on_screen = display.GetNormalizedScreenWidthByPercentage(width)
        
        // Center the popup on the scene.
        self.name = "Popup"
        self.zPosition = ZPOSITION.popup.rawValue
        
        let top_padding = display.GetNormalizedScreenHeightByPercentage(self.TOP_PADDING_PERCENT)
        let bottom_padding = display.GetNormalizedScreenHeightByPercentage(self.BOTTOM_PADDING_PERCENT)
        
        label = MultiLineTextLabel(text: text, name: "Popup", parent: self, width: width_on_screen, font_width: font_width, font_height: font_height, top_padding: top_padding, bottom_padding: bottom_padding)
        
        // We can't setup the position information until we know how big the labels are.
        self.position = display.GetSceneAnchor(self, anchorTo: Display.ANCHOR.CENTER)   // Always center on screen.
        
        // If height is 0, then we should dynamically calculate it.
        if ( height == 0 ) {
            self.size.height = label!.GetHeight() + display.GetNormalizedScreenHeightByPercentage(BUTTON_HEIGHT)
        } else {
            self.size.height = display.GetNormalizedScreenHeightByPercentage(height)
        }
        
        self.size.width = label!.GetWidth()
        
        scene.addChild(self)    // Add to the scene so that it won't be affected by pausing.
        
        // Add the label
        label!.Show()

        scene.isPaused = true
        world.isPaused = true
    }
}
