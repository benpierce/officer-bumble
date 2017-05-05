/*
===============================================================================
InputManagerTests

Unit tests for InputManager class and everything that can receive input.
===============================================================================

import UIKit
import XCTest
import SpriteKit
import OfficerBumble

class InputManagerTests: XCTestCase {

    let iPadScene = SKScene()
    var display : Display!
    var inputManager: InputManager!
    
    let touchPointA = CGPoint(x: -100, y: 0)
    let touchPointB = CGPoint(x: 100, y: 0)
    
    override func setUp() {
        super.setUp()
        
        iPadScene.size.height = 1536
        iPadScene.size.width = 2048
        
        display = Display(size: iPadScene.size)
        inputManager = InputManager(display: display)
    }
    
    override func tearDown() {
        
        inputManager.DeRegisterAll()    // Cleanup references
        
        super.tearDown()
    }
    
    func testBumbleAPressed() {
        let bumble = GetBumble()
        
        inputManager.DispatchTouch(bumble.name!, touchPoint: touchPointA, isPaused: false)
        XCTAssert(bumble.currentState == Bumble.STATE.DUCKING, "Bumble state should be ducking!")
    }
    
    func testBumbleAReleased() {
        let bumble = GetBumble()
        
        // Make him duck.
        inputManager.DispatchTouch(bumble.name!, touchPoint: touchPointA, isPaused: false)
        XCTAssert(bumble.currentState == Bumble.STATE.DUCKING, "Bumble state should be ducking!")
        
        // Make him stand up on A Released.
        inputManager.DispatchRelease(touchPointA, isPaused: false)
        XCTAssert(bumble.currentState == Bumble.STATE.DUCKED_READY_TO_RUN, "Bumble state should be ducked and ready to run!")
    }
    
    func testBumbleBPressed() {
        let bumble = GetBumble()
        
        // Make him jump.
        inputManager.DispatchTouch(bumble.name!, touchPoint: touchPointB, isPaused: false)
        XCTAssert(bumble.currentState == Bumble.STATE.JUMPING, "Bumble state should be jumping!")
    }
    
    func testBumbleBReleased() {
        let bumble = GetBumble()
        
        // Make him jump.
        inputManager.DispatchTouch(bumble.name!, touchPoint: touchPointB, isPaused: false)
        XCTAssert(bumble.currentState == Bumble.STATE.JUMPING, "Bumble state should be jumping!")
        
        inputManager.DispatchRelease(touchPointB, isPaused: false)
        XCTAssert(bumble.currentState == Bumble.STATE.JUMPING, "Bumble state should be jumping!")
    }
    
    func testButtonPressed() {
        let button = GetButton()
        
        inputManager.DispatchTouch(button.name!, touchPoint: touchPointA, isPaused: false)
        XCTAssert(button.hasActions() == true, "Button should have an action!")
    }
    
    func testButtonRegistered() {
        let button = GetButton()
        XCTAssert(inputManager.IsRegistered(button) == true, "Button should be registered!")
    }
    
    func testButtonDeRegistered() {
        let button = GetButton()
        XCTAssert(inputManager.IsRegistered(button) == true, "Button should be registered!")
        
        // DeRegister by Name
        inputManager.DeRegisterButtonWithName(button.name!)
        XCTAssert(inputManager.IsRegistered(button) == false, "Button should not be registered anymore!")
        
        // DeRegister by Button
        let button2 = GetButton()
        XCTAssert(inputManager.IsRegistered(button2) == true, "Button should be registered!")
        inputManager.DeRegisterButton(button2)
        XCTAssert(inputManager.IsRegistered(button2) == false, "Button should not be registered anymore!")
    }
    
    func testRegisterListener() {
        let bumble = GetBumble()
        XCTAssert(inputManager.IsRegistered(bumble) == true, "Bumble should be registered!")
    }
    
    func testDeRegisterListener() {
        let bumble = GetBumble()
        XCTAssert(inputManager.IsRegistered(bumble) == true, "Bumble should be registered!")

        inputManager.DeRegisterListener(bumble)
        XCTAssert(inputManager.IsRegistered(bumble) == false, "Bumble should not be registered!")
    }
    
    func testDeRegisterAll() {
        let bumble = GetBumble()
        let button1 = GetButton()
        XCTAssert(inputManager.IsRegistered(bumble) == true, "Bumble should be registered!")
        XCTAssert(inputManager.IsRegistered(button1) == true, "Button should be registered!")
        
        inputManager.DeRegisterAll()
        XCTAssert(inputManager.IsRegistered(bumble) == false, "Bumble should not be registered!")
        XCTAssert(inputManager.IsRegistered(button1) == false, "Button should not be registered!")
    }
    
    // Making sure that if a button is pressed, input isn't sent to a listener.
    func testButtonReceivesInputOverListener() {
        let bumble = GetBumble()
        let button = GetButton()
        
        // Send input to button.
        inputManager.DispatchTouch(button.name!, touchPoint: touchPointA, isPaused: false)
        
        XCTAssert(bumble.currentState == Bumble.STATE.RUNNING, "Bumble state should be set to running!")
        XCTAssert(button.hasActions(), "Button should have an action!")
    }
    
    // Making sure that if the world is paused, we're not sending any events to listeners.
    func testPausedDoesntSendEventsToListeners() {
        let bumble = GetBumble()
        
        inputManager.DispatchTouch(bumble.name!, touchPoint: touchPointA, isPaused: true)
        XCTAssert(bumble.currentState == Bumble.STATE.RUNNING, "Bumble state should be set to running!")
    }
    
    // Tests that if the world is paused, buttons don't get input.
    func testPausedDoesntSendEventsToRegularButtons() {
        let button = GetButton()
        
        inputManager.DispatchTouch(button.name!, touchPoint: touchPointA, isPaused: true)
        XCTAssert(button.hasActions() == false, "Button should not have any actions!")
    }
    
    // Tests that even if the world is paused, popup buttons still receive input.
    func testPausedSendsEventsToPopupButtons() {
        let popup = SKSpriteNode()
        popup.name = "Popup"
        
        let button = GetButton()
        popup.addChild(button)
        
        inputManager.DispatchTouch(button.name!, touchPoint: touchPointA, isPaused: true)
        XCTAssert(button.hasActions(), "Button should have actions!")
    }
    
    private func GetBumble() -> Bumble {
        let bumble = Bumble(display: display)
        bumble.Initialize(inputManager, difficulty: Easy(display: display)) // Bind to input.
        XCTAssert(bumble.currentState == Bumble.STATE.RUNNING, "Bumble state should initially be running!")
        
        return bumble
    }
    
    private func GetButton() -> GameButton {
        let button = GameButton(texture: SKTexture(imageNamed: "fblogin"), texturePressed: SKTexture(imageNamed: "fblogout"))
        button.Initialize("TestButton", inputManager: inputManager, pressBlock: {}) // Bind to input.
        XCTAssert(button.hasActions() == false, "Buttons should have no actions scheduled!")
        
        return button
    }
}
*/

