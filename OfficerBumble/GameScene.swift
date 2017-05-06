/*
===============================================================================
GameScene

Base class for all scenes - handles common functionality for all scenes.
===============================================================================
*/

import Foundation
import SpriteKit

open class GameScene : SKScene, SKPhysicsContactDelegate {
    var display: Display               // Represents the current view size and encapsulates all aspect ratio math.
    var sm : SoundManager?             // Handles all of the sound in the game.
    var inputManager: InputManager     // Manages device input and dispatches events to the interested nodes.
    var physicsManager: PhysicsManager // Responsible for handling all of the physics events.
    var resourceName: String = ""      // The resource name (xml file) that the scene is built off of.
    open var world: SKSpriteNode?
    open var hud: SKSpriteNode?
    var maximumWeaponVelocity = CGFloat(999)
    var lastTime: TimeInterval = 0
    
    var bumbleOriginalPosition: CGPoint?
    open var isScenePaused = false                // Determine if the game is currently paused.
    
    // Constructor
    public init(size: CGSize, resourceName: String, isMuted: Bool)
    {
        // Force Aspect Ratio
        //var newSize = CGSize(width: 1136, height: 640)

        self.resourceName = resourceName
        self.display = Display(size: size)
        self.inputManager = InputManager(display: display)
        self.physicsManager = PhysicsManager()
        self.sm = SoundManager(parentScene: self.resourceName)
        
        if ( isMuted ) {
            self.sm!.Mute()
        }
        
        super.init(size: size)

        //super.init(size: newSize)
        //self.scaleMode = .AspectFit
        self.scaleMode = .resizeFill
        
        // Default background color = white
        self.backgroundColor = SKColor.white
        self.anchorPoint = CGPoint(x: 0.5,y: 0.5)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
    }
    
    open override func didMove(to view: SKView) {
        // Load the scene from the XML file.
        let sceneLoader = SceneLoader()
        sceneLoader.Initialize(display, _scene : self, resourceName : resourceName)
        
        // The sound manager needs a reference to the scene because the scene plays sound effects represented as SKActions
        self.world = GetSpriteNodeOrDie("World")
        self.hud = GetSpriteNodeOrDie("HUD")
        
        // Set the HUD for the sound manager so we always play sounds, even if world is paused.
        sm!.SetHUD(self.hud!)
        
        // Setup Physics
        physicsWorld.contactDelegate = self
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Super hack but the IOS home screen causes the scene to pause and you can't get it unpaused!
        // So if we detect that the scene is paused that means that it's because someone came back into 
        // the application... we need to unpause it and pause the world.
        if ( self.isScenePaused ) {
            self.isScenePaused = false
            world!.isPaused = true
        }
        
        if let touch = touches.first {
            let location = touch.location(in: self)
            let node = self.atPoint(location)
            let name : String = ((node.name == nil) ? "" : node.name!)
            
            inputManager.DispatchTouch(name, touchPoint: location, isPaused: world!.isPaused)
        }
        
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let startPoint = touch.location(in: self)
            
            inputManager.DispatchRelease(startPoint, isPaused: world!.isPaused)
        }
    }
    
    open func didBegin(_ contact: SKPhysicsContact) {
        physicsManager.CheckCollisions(contact)
    }
    
    /*
    ===============================================================================
    WireButton
    
    When buttons are initially created, they have no ability to act on user input. This
    covenience method validates that the button exists in the scene, then wires it
    up to the InputHandler object so that any click events on this button are properly
    received.
    ===============================================================================
    */
    func WireButton(_ buttonName: String, pressBlock: @escaping () -> ()) {
        let button = self.childNode(withName: "//\(buttonName)") as! GameButton?
        assert(button != nil, "\(resourceName) requires button \(buttonName)!")
        button!.Initialize(button!.name!, inputManager: inputManager, pressBlock: pressBlock)
    }

    /*
    ===============================================================================
    GetSpriteNodeOrDie
    
    Returns a sprite node from the entire scene hierarchy. If not found, then
    an assertion error will happen.
    ===============================================================================
    */
    func GetSpriteNodeOrDie(_ nodeName: String) -> SKSpriteNode {
        
        let searchString = "//\(nodeName)"
        
        let node = self.childNode(withName: searchString) as! SKSpriteNode?
        assert(node != nil, "\(resourceName) requires sprite node \(nodeName)!")
        
        return node!
    }
    
    func GetSpriteNodeOrNil(_ nodeName: String) -> SKSpriteNode? {
        let searchString = "//\(nodeName)"
        let node = self.childNode(withName: searchString) as! SKSpriteNode?
        
        return node
    }
    
    func ShowLoading() {
        let atlas = SKTextureAtlas(named: "tools")
        let loading = SKSpriteNode(texture: atlas.textureNamed("loading"))
        let height = display.GetNormalizedScreenHeightByPercentage(0.26)
        let width = display.GetNormalizedScreenWidthByPercentage(1)
        loading.size = CGSize(width: width, height: height)
        loading.position = CGPoint(x: 0, y: 0)
        loading.zPosition = ZPOSITION.popup.rawValue
        hud!.addChild(loading)
    }
    
    func CreateMuteButton() -> ToggleButton? {
        var result: ToggleButton?
        
        if ( self.world != nil ) {
            let atlas = SKTextureAtlas(named: "tools")
            let button = ToggleButton(texture: atlas.textureNamed("audio_on"), texturePressed: atlas.textureNamed("audio_off"))
            button.name = "btnmute"
            button.zPosition = ZPOSITION.hud.rawValue
            button.size = display.GetSizeByPercentageOfScene(0.15, heightPercent: 0.15, considerAspectRatio: true)
            button.Initialize(button.name!, inputManager: inputManager, pressBlock: { self.sm!.ToggleSound(); })
            
            if ( sm!.IsMuted() ) {
                button.ToggleOff()
            }
            
            result = button
        }
        
        return result
    }
    
    func CreatePauseButton(_ runBlock: @escaping () -> ()) -> ToggleButton? {
        var result: ToggleButton?
        
        if ( self.world != nil ) {
            let atlas = SKTextureAtlas(named: "tools")
            let button = ToggleButton(texture: atlas.textureNamed("pause_on"), texturePressed: atlas.textureNamed("pause_off"))
            button.name = "btnpause"
            button.zPosition = ZPOSITION.hud.rawValue
            button.size = display.GetSizeByPercentageOfScene(0.15, heightPercent: 0.15, considerAspectRatio: true)
            button.Initialize(button.name!, inputManager: inputManager, pressBlock: runBlock )
            
            result = button
        }
        
        return result
    }
    
    func TransitionToTitle() {
        PresentScene(TitleScreen(size: self.size, resourceName: "titlescreen", isMuted: sm!.IsMuted()))
    }
    
    /*
    ===============================================================================
    PresentScene
    
    Transitioning to a different scene involves first making sure all scene references
    are dereferenced, then transitioning to the new scene. This function should handle
    all sub-class scene transitions.
    ===============================================================================
    */
    func PresentScene(_ scene: SKScene) {
        DereferenceAll() // Dereferences all pointers to the scene so that it can be released successfully.
        
        self.view?.presentScene(scene)
    }
  
    func CenterOnNode(_ node: SKSpriteNode) {
        let position = node.scene!.convert(node.position, from: world!)
        world!.position = CGPoint(x: world!.position.x - position.x, y: world!.position.y - position.y)
    }
    
    func BumbleCamera(_ bumble: Bumble) {
        let position = bumble.scene!.convert(bumble.position, from: world!)
        
        if ( bumble.cameraPositionCaptureRequired ) {
            bumbleOriginalPosition = bumble.scene!.convert(bumble.position, from: world!)
            
            bumble.cameraPositionCaptureRequired = false
        }
        
        var deltaX = CGFloat(0)
        var deltaY = CGFloat(0)
        
        if ( bumble.cameraEnabled ) {
            deltaX = position.x - bumbleOriginalPosition!.x
            deltaY = position.y - bumbleOriginalPosition!.y
        } else {
            deltaY = position.y - bumbleOriginalPosition!.y
        }
            
        let x = world!.position.x - deltaX
        let y = world!.position.y - deltaY
        
        world!.position = CGPoint(x: x, y: y)
    }
    
    override open func update(_ currentTime: TimeInterval)  {
        let bumble = GetSpriteNodeOrNil("bumble") as! Bumble?
        
        // We never want the scene paused.
        if ( self.isScenePaused ) {
            self.isScenePaused = false
        }
        
        if ( bumble != nil ) {
            var minimumWeaponVelocity = CGFloat(999)
            
            // Loop through each weapon and call the Update() method.
            self.enumerateChildNodes(withName: "//Weapon_*", using: {
                (node: SKNode!, stop: UnsafeMutablePointer <ObjCBool>) -> Void in
    
                let weapon = node as! Weapon
                if ( !weapon.isBehindBumble && abs(weapon.GetVelocityPerSecond()) < minimumWeaponVelocity ) {
                    minimumWeaponVelocity = abs(weapon.GetVelocityPerSecond())
                }
                
                weapon.Update(currentTime, display: self.display)
            })
            
            self.maximumWeaponVelocity = minimumWeaponVelocity
            
            BumbleCamera(bumble!)
        }
        
        super.update(currentTime)
    }

    /*
    ===============================================================================
    DereferenceAll
    
    If any scene objects reference the scene, the scene will never actually be destroyed and 
    we'll have a memory leak. This function will remove all associated references and should
    always be called before transitioning to a new scene.
    ===============================================================================
    */
    open func DereferenceAll() {
        NotificationCenter.default.removeObserver(self)
        self.sm = nil
        self.inputManager.DeRegisterAll()
        self.physicsManager.RemoveAllContacts()
    }

}
