//
//  BumbleTests.swift
//  OfficerBumble
//
//  Created by Ben Pierce on 2015-01-08.
//  Copyright (c) 2015 Benjamin Pierce. All rights reserved.
//
/*
import UIKit
import XCTest
import SpriteKit
import OfficerBumble

class BumbleTests: XCTestCase {

    let view = SKView()
    var iPadScene : SKScene!
    var display : Display!
    var inputManager: InputManager!
    
    let touchPointA = CGPoint(x: -100, y: 0)
    let touchPointB = CGPoint(x: 100, y: 0)
    
    // Setup for each test
    override func setUp() {
        super.setUp()
        
        iPadScene = SKScene()
        iPadScene.size = CGSize(width: 2048, height: 1536)
        display = Display(size: iPadScene.size)
        inputManager = InputManager(display: display)
    }
    
    // Teardown for each test
    override func tearDown() {
        
        inputManager.DeRegisterAll()    // Cleanup references
        
        super.tearDown()
    }

    func testBumbleJump() {
        let bumble = GetBumble()
        
        // Make him jump.
        inputManager.DispatchTouch(bumble.name!, touchPoint: touchPointB, isPaused: false)
        XCTAssert(bumble.currentState == Bumble.STATE.JUMPING, "Bumble state should be jumping!")
    }
    
    func testBumbleDuck() {
        let bumble = GetBumble()
        
        inputManager.DispatchTouch(bumble.name!, touchPoint: touchPointA, isPaused: false)
        XCTAssert(bumble.currentState == Bumble.STATE.DUCKING, "Bumble state should be ducking!")
    }
    
    func testBumbleDuckRelease() {
        let bumble = GetBumble()
        
        // Make him duck.
        inputManager.DispatchTouch(bumble.name!, touchPoint: touchPointA, isPaused: false)
        XCTAssert(bumble.currentState == Bumble.STATE.DUCKING, "Bumble state should be ducking!")
        
        // Make him stand up on A Released.
        inputManager.DispatchRelease(touchPointA, isPaused: false)
        XCTAssert(bumble.currentState == Bumble.STATE.DUCKED_READY_TO_RUN, "Bumble state should be ducked and ready to run!")
    }
    
    // Tests that Bumble goes from ducking to ducking complete, to running.
    func testBumbleDuckToRunTransition() {
        let bumble = GetBumble()
        
        // Make him duck.
        inputManager.DispatchTouch(bumble.name!, touchPoint: touchPointA, isPaused: false)
        XCTAssert(bumble.currentState == Bumble.STATE.DUCKING, "Bumble state should be ducking!")
        var duckTime: CFTimeInterval = CACurrentMediaTime()
        
        // Make him stand up on A Released.
        inputManager.DispatchRelease(touchPointA, isPaused: false)
        XCTAssert(bumble.currentState == Bumble.STATE.DUCKED_READY_TO_RUN, "Bumble state should be ducked and ready to run!")
        
        // We need to remove Bumble's actions otherwise the system will think he's still doing the duck animation.
        bumble.removeAllActions()
        XCTAssert(bumble.currentState == Bumble.STATE.DUCKED_READY_TO_RUN, "Bumble state should be ducked and ready to run!")
        
        bumble.Update(duckTime + 500, isPaused: false) // Set it to some time in the future
        XCTAssert(bumble.currentState == Bumble.STATE.RUNNING, "Bumble should be running!")
    }
    
    // Bumble should stay ducked
    func testBumbleDuckAndHold() {
        let bumble = GetBumble()
        
        // Make him duck.
        inputManager.DispatchTouch(bumble.name!, touchPoint: touchPointA, isPaused: false)
        XCTAssert(bumble.currentState == Bumble.STATE.DUCKING, "Bumble state should be ducking!")
        var duckTime: CFTimeInterval = CACurrentMediaTime()
        
        // We need to remove Bumble's actions otherwise the system will think he's still doing the duck animation.
        bumble.removeAllActions()
        XCTAssert(bumble.currentState == Bumble.STATE.DUCKING, "Bumble state should be ducked!")
        
        bumble.Update(duckTime + 500, isPaused: false) // Set it to some time in the future
        XCTAssert(bumble.currentState == Bumble.STATE.DUCKING, "Bumble state should be ducked!")
    }
    
    private func GetBumble() -> Bumble {
        let bumble = Bumble(display: display)
        bumble.Initialize(inputManager, difficulty: Easy(display: display)) // Bind to input.
        XCTAssert(bumble.currentState == Bumble.STATE.RUNNING, "Bumble state should initially be running!")
        
        return bumble
    }
}
*/
