/*
===============================================================================
InputManager

Provides a translation layer between user input actions and scene objects by
dispatching user input events to parties that have registered to be notified.

Currently this class supports Buttons and SKSpriteNodes.

NOTE: We need to have the isPaused logic in here because, even though a particular
node like World is set to paused, it still receives input which will then be acted
upon as soon as the node is unpaused. This makes for a rather unpleasant experience
for the end user, so we have no choice but to tie inputManager to isPaused at this
point.
===============================================================================
*/

import Foundation
import SpriteKit

open class InputManager {
    fileprivate let display: Display    // We need a reference to this so that we can quickly determine where the press events occur.
    fileprivate var buttons: [String: GameButton] = [:]          // Dictionary so that we can quickly find a registered button.
    fileprivate var listeners: [String: InputListener] = [:]     // Dictionary so that we can quickly find a registered listener.
    
    // This structure is used to hold references to an object's actions, corresponding to each type of input action.
    fileprivate struct InputListener {
        var aPressedRunBlock : () -> ()
        var aReleasedRunBlock : () -> ()
        var bPressedRunBlock : () -> ()
        var bReleasedRunBlock : () -> ()
    }
    
    enum TOUCH_EVENT {
        case pressed
        case released
    }
    
    public init (display: Display) {
        self.display = display
    }
    
    // Register a button for UI events..
    open func RegisterButton(_ button: GameButton) {
        assert(button.name != nil, "Cannot register a button with no name!")
        
        buttons[button.name!] = button
    }

    // Deregister a button from UI events.
    open func DeRegisterButton(_ button: GameButton) {
        assert(button.name != nil, "Cannot deregister a button with no name!")
        
        buttons.removeValue(forKey: button.name!)
    }
    
    // Deregister a button by it's name.
    open func DeRegisterButtonWithName(_ buttonName: String) {
        buttons.removeValue(forKey: buttonName)
    }
    
    // Register an SKSpriteNode listener so that it can respond to all UI events.
    open func RegisterListener(_ listener: SKSpriteNode, aPressedRunBlock: @escaping () -> (), aReleasedRunBlock: @escaping () -> (), bPressedRunBlock: @escaping () -> (), bReleasedRunBlock: @escaping () -> ()) {
        
        assert(listener.name != nil, "Cannot register a listener that has no name!")
        
        listeners[listener.name!] = InputListener(aPressedRunBlock: aPressedRunBlock, aReleasedRunBlock: aReleasedRunBlock, bPressedRunBlock: bPressedRunBlock, bReleasedRunBlock: bReleasedRunBlock)
    }
    
    // Degister an SKSpriteNode listener so that it no longer receives UI events.
    open func DeRegisterListener(_ listener: SKSpriteNode) {
        assert(listener.name != nil, "Cannot deregister a listener that has no name!")
        
        listeners.removeValue(forKey: listener.name!)
    }
    
    // Releases all button references to Scene code blocks, and releases all UI event registrations.
    open func DeRegisterAll() {
        // Loop through each button and deregister the press event so that we're not holding a reference to the scene.
        for value in buttons.values {
            value.Release()
        }
        
        buttons = [:]
        listeners = [:]
    }
    
    // Dispatch any touch events. If the world is paused, isPaused will be set to true. If the world is
    // paused, then only buttons associated with a popup will be allowed to receive input.
    open func DispatchTouch(_ nodeName: String, touchPoint: CGPoint, isPaused: Bool) {
        let button = GetButton(nodeName)
        
        var parentName : String = ""
        if ( button != nil && button!.parent != nil && button!.parent!.name != nil ) {
            parentName = button!.parent!.name!
        }
        
        // If it's a button press, we should dispatch the event to the button and nothing else.
        if ( button != nil ) {
            if ( !isPaused || (isPaused && parentName == "Popup") ) {
                button!.Pressed()
            }
        } else {
            if ( !isPaused ) {
                // Figure out the button event.
                let event : BUTTON_EVENT = (display.GetTouchLocation(touchPoint.x) == .left) ? .button_A_PRESSED : .button_B_PRESSED
                NotifyListeners(event)
            }
        }
    }
    
    // Dispatch touch release events. If the game is paused, we don't deliver events to anything.
    open func DispatchRelease(_ touchPoint: CGPoint, isPaused: Bool) {
        if ( !isPaused ) {
            let event: BUTTON_EVENT = (display.GetTouchLocation(touchPoint.x) == .left) ? .button_A_RELEASED : .button_B_RELEASED
            NotifyListeners(event)
        }
    }
    
    // Used for unit tests to determine if something has been registered.
    open func IsRegistered(_ node: SKSpriteNode) -> Bool {
        let button = buttons[node.name!]
        let listener = listeners[node.name!]
        
        if ( button == nil && listener == nil ) {
            return false
        } else {
            return true
        }
    }
    
    // Notify all listeners that a particular UI event has happened.
    fileprivate func NotifyListeners(_ event: BUTTON_EVENT) {
        // Let all registered nodes know about the the touch event.
        for value in listeners.values {
            switch(event) {
            case .button_A_PRESSED:
                value.aPressedRunBlock()
            case .button_A_RELEASED:
                value.aReleasedRunBlock()
            case .button_B_PRESSED:
                value.bPressedRunBlock()
            case .button_B_RELEASED:
                value.bReleasedRunBlock()
            }
        }
    }
    
    // Returns a button if it's been registered as a UI listener.
    fileprivate func GetButton(_ nodeName: String) -> GameButton? {
        return buttons[nodeName]
    }
    
}
