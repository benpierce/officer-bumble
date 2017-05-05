/*
===============================================================================
GameButton

Buttons are pretty simple, they consist of two different images (a regular state,
and a pressed state). The Pressed method will issue a notification that the button
was pressed, change the texture, and run whatever action is associated with the
button.
===============================================================================
*/

import Foundation
import SpriteKit

open class GameButton : SKSpriteNode {
    
    var texturePressed : SKAction?      // The (optional) texture to show when a button is pressed.
    var pressBlock : (() -> ())?        // Code block to run when the button is pressed.
    var textureDefault: SKTexture?
    var textureWhenPressed: SKTexture?
    
    public init(texture: SKTexture, texturePressed: SKTexture) {
        self.textureDefault = texture
        self.textureWhenPressed = texturePressed
        
        super.init(texture: texture, color: UIColor.clear, size: CGSize(width: 0, height: 0))
        
        self.texturePressed = SKAction.setTexture(texturePressed)
    }
    
    public init() {
        super.init(texture: nil, color: UIColor.clear, size: CGSize(width: 0, height: 0))
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    ===============================================================================
    Initialize
    
    When a button is first created, it has no access to user input and cannot determine
    whether or not is was pressed. Initialize wires up the button to the user input which
    will call the Pressed() method whenever the button is pressed.
    
    pressBlock represents the action to take inside of Pressed() after all sound effects
    and animations are played.
    ===============================================================================
    */
    open func Initialize(_ name: String, inputManager: InputManager, pressBlock: @escaping () -> ()) {
        self.name = name
        self.pressBlock = pressBlock
        
        inputManager.RegisterButton(self)
    }
    
    /*
    ===============================================================================
    Pressed
    
    Buttons all share common functionality when pressed. They first play a sound (via 
    the generation of a system wide notification), then change their texture to 
    indication they've been pressed, and finally they run their designated action.
    ===============================================================================
    */
    func Pressed() {
        if ( pressBlock != nil ) {
            NotificationCenter.default.post(name: Notification.Name(rawValue: EVENT_TYPE.BUTTON_PRESSED.rawValue), object: nil)
            
            let delay = SKAction.wait(forDuration: 0.2)                           // A small delay so that we can see the button transition.
            var sequence: SKAction
            let block = SKAction.run(pressBlock!)                          // Which block of code to run when the button is pressed.
            
            self.removeAllActions()
            if(self.name == "btneasy" || self.name == "btnnormal" || self.name == "btnhard" || self.name == "btnhardcore") {
                
                // The buttons that actually animate properly.
                if ( texturePressed == nil ) {
                   sequence = SKAction.sequence([block])   // Group everything together.
                } else {
                   sequence = SKAction.sequence([self.texturePressed!, delay, block])
                }
                self.run(sequence)
            } else {
                /*************** HUGE BUG ************************************************
                    No idea why, but self.run() doesn't work on any button on the popup menu.
                 
                    Unfortunately, this looks like a SWIFT bug, as I can't even get it to 
                    do a print statement -- it doesn't run anything in the closure.
                 
                    Workaround is to just run the closure action without doing the animate.
                **************************************************************************/
                pressBlock!()
            }
        }
    }
    
    func Reset() {
        if ( texture != nil ) {
            let resetAction = SKAction.setTexture(self.texture!)
            self.run(resetAction)
        }
    }
    
    /*
    ===============================================================================
    Release
    
    Buttons that contain a reference to a scene's code block are considered to have a 
    reference to that scene. If a scene is transitioned but we haven't released the references
    to these code blocks the scene will remain in memory forever. This method is called
    by the InputHandler whenever a button needs to be deregistered as a listener.
    ===============================================================================
    */
    func Release() {
        pressBlock = nil
    }
}
