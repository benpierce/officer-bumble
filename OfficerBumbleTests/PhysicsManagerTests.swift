//
//  PhysicsManagerTests.swift
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

class PhysicsManagerTests: XCTestCase {

    private var physicsManager = PhysicsManager()
    
    let view = SKView()
    var iPadScene : SKScene!
    var display : Display!
    
    override func setUp() {
        super.setUp()
        
        iPadScene = SKScene(size: CGSize(width: 2048, height: 1536))
        display = Display(size: iPadScene.size)
        let physicsManager = PhysicsManager()
    }
    
    override func tearDown() {
        physicsManager.RemoveAllContacts()
        
        super.tearDown()
    }

    // Tests that adding one contact works.
    func testAddContact() {
        // Verify that we can add a contact.
        let bumble = Bumble(display: display)
        physicsManager.AddContact(bumble.name!, physicsHandler: bumble, collideAgainstBodyType: BODY_TYPE.CRIMINAL, runBlock: CollideEvent)
        
        let contactCount = physicsManager.GetContactCount(bumble.name!)
        XCTAssert(contactCount == 1, "Bumble should have 1 contact!")
    }
    
    // Test that we can remove one contact.
    func testRemoveContact() {
        // Verify that we can add a contact.
        let bumble = Bumble(display: display)
        physicsManager.AddContact(bumble.name!, physicsHandler: bumble, collideAgainstBodyType: BODY_TYPE.CRIMINAL, runBlock: CollideEvent)
        
        var contactCount = physicsManager.GetContactCount(bumble.name!)
        XCTAssert(contactCount == 1, "Bumble should have 1 contact!")
        
        physicsManager.RemoveContact(bumble.name!)
        contactCount = physicsManager.GetContactCount(bumble.name!)
        XCTAssert(contactCount == 0, "Bumble sholudn't have any contacts!")
    }
    
    func testAddMultipleContacts() {
        let bumble = Bumble(display: display)
        physicsManager.AddContact(bumble.name!, physicsHandler: bumble, collideAgainstBodyType: BODY_TYPE.CRIMINAL, runBlock: CollideEvent)
        physicsManager.AddContact(bumble.name!, physicsHandler: bumble, collideAgainstBodyType: BODY_TYPE.BOWLING_BALL, runBlock: CollideEvent)
        
        let bowlingBall = BowlingBall(display: display, floorLevel: 1, direction: .LEFT, velocity: 1, bumble: bumble)
        physicsManager.AddContact(bowlingBall.name!, physicsHandler: bowlingBall, collideAgainstBodyType: BODY_TYPE.BUMBLE, runBlock: CollideEvent)
        
        var contactCount = physicsManager.GetContactCount(bumble.name!)
        var contactCount2 = physicsManager.GetContactCount(bowlingBall.name!)
        
        XCTAssert(contactCount == 2, "Bumble should have 2 contacts!")
        XCTAssert(contactCount2 == 1, "Bowling ball should have 1 contact!")
    }
    
    func testRemoveMultipleContacts() {
        let bumble = Bumble(display: display)
        physicsManager.AddContact(bumble.name!, physicsHandler: bumble, collideAgainstBodyType: BODY_TYPE.CRIMINAL, runBlock: CollideEvent)
        physicsManager.AddContact(bumble.name!, physicsHandler: bumble, collideAgainstBodyType: BODY_TYPE.BOWLING_BALL, runBlock: CollideEvent)
        
        let bowlingBall = BowlingBall(display: display, floorLevel: 1, direction: .LEFT, velocity: 1, bumble: bumble)
        physicsManager.AddContact(bowlingBall.name!, physicsHandler: bowlingBall, collideAgainstBodyType: BODY_TYPE.BUMBLE, runBlock: CollideEvent)
        
        var contactCount = physicsManager.GetContactCount(bumble.name!)
        var contactCount2 = physicsManager.GetContactCount(bowlingBall.name!)
        
        XCTAssert(contactCount == 2, "Bumble should have 2 contacts!")
        XCTAssert(contactCount2 == 1, "Bowling ball should have 1 contact!")
        
        physicsManager.RemoveContact(bumble.name!)
        contactCount = physicsManager.GetContactCount(bumble.name!)
        contactCount2 = physicsManager.GetContactCount(bowlingBall.name!)
        XCTAssert(contactCount == 0, "Bumble should have no contact events!")
        XCTAssert(contactCount2 == 1, "Bowling ball should have 1 contact!")
        
        physicsManager.RemoveContact(bowlingBall.name!)
        contactCount2 = physicsManager.GetContactCount(bowlingBall.name!)
        XCTAssert(contactCount == 0, "Bowling ball should have no contacts!")
    }
    
    func testRemoveAllContacts() {
        let bumble = Bumble(display: display)
        physicsManager.AddContact(bumble.name!, physicsHandler: bumble, collideAgainstBodyType: BODY_TYPE.CRIMINAL, runBlock: CollideEvent)
        physicsManager.AddContact(bumble.name!, physicsHandler: bumble, collideAgainstBodyType: BODY_TYPE.BOWLING_BALL, runBlock: CollideEvent)
        
        let bowlingBall = BowlingBall(display: display, floorLevel: 1, direction: .LEFT, velocity: 1, bumble: bumble)
        physicsManager.AddContact(bowlingBall.name!, physicsHandler: bowlingBall, collideAgainstBodyType: BODY_TYPE.BUMBLE, runBlock: CollideEvent)
        
        var contactCount = physicsManager.GetContactCount(bumble.name!)
        var contactCount2 = physicsManager.GetContactCount(bowlingBall.name!)
        
        XCTAssert(contactCount == 2, "Bumble should have 2 contacts!")
        XCTAssert(contactCount2 == 1, "Bowling ball should have 1 contact!")
        
        physicsManager.RemoveAllContacts()
        contactCount = physicsManager.GetContactCount(bumble.name!)
        contactCount2 = physicsManager.GetContactCount(bowlingBall.name!)
        XCTAssert(contactCount == 0, "Bumble should have 0 contacts!")
        XCTAssert(contactCount2 == 0, "Bowling ball should have 0 contacts!")
    }
    
    func testBumbleContacts() {
        let bumble = GetBumble()
        XCTAssertEqual(physicsManager.GetContactCount("BumbleCollision"), 6)
    }
    
    func testPieContacts() {
        let pie = GetPie()
        XCTAssert(physicsManager.GetContactCount(pie.name!) == 1, "Pie should have 1 contact!")
    }
    
    func testBowlingBallContacts() {
        let bowlingball = GetBowlingBall()
        XCTAssert(physicsManager.GetContactCount(bowlingball.name!) == 1, "Bowling ball should have 1 contact!")
    }
    
    private func CollideEvent(firstBody: SKSpriteNode, secondBody: SKSpriteNode) {
        
    }
    
    func testChickenatorContacts() {
        let chickenator = GetChickenatorHigh()
        XCTAssert(physicsManager.GetContactCount(chickenator.name!) == 1, "Chickenator should have 1 contact!")
        
        let chickenator2 = GetChickenatorLow()
        XCTAssert(physicsManager.GetContactCount(chickenator.name!) == 1, "Chickeantor should have 1 contact!")
    }
    
    func testRemoveContactPie() {
        let pie = GetPie()
        XCTAssert(physicsManager.GetContactCount(pie.name!) == 1, "Pie should have 1 contact!")
        
        physicsManager.RemoveContact(pie.name!)
        XCTAssert(physicsManager.GetContactCount(pie.name!) == 0, "Pie should have 0 contacts!")
    }
    
    func testRemoveContactBowlingBall() {
        let bowlingball = GetBowlingBall()
        XCTAssert(physicsManager.GetContactCount(bowlingball.name!) == 1, "Bowlingball should have 1 contact!")
        
        physicsManager.RemoveContact(bowlingball.name!)
        XCTAssert(physicsManager.GetContactCount(bowlingball.name!) == 0, "Bowlingball should have 0 contacts!")
    }
    
    func testRemoveContactChickenatorHigh() {
        let chickenator = GetChickenatorHigh()
        XCTAssert(physicsManager.GetContactCount(chickenator.name!) == 1, "Chickenator should have 1 contact!")
        
        physicsManager.RemoveContact(chickenator.name!)
        XCTAssert(physicsManager.GetContactCount(chickenator.name!) == 0, "Chickenator should have 0 contacts!")
    }
    
    func testRemoveContactChickenatorLow() {
        let chickenator = GetChickenatorLow()
        XCTAssert(physicsManager.GetContactCount(chickenator.name!) == 1, "Chickenator should have 1 contact!")
        
        physicsManager.RemoveContact(chickenator.name!)
        XCTAssert(physicsManager.GetContactCount(chickenator.name!) == 0, "Chickenator should have 0 contacts!")
    }
    
    func testBumbleBowlingBallCollision() {
        // Wish I knew how to simulate this.
    }
    
    func testBumblePieCollision() {
        // Wish I knew how to simulate this.
    }
    
    func testBumbleChickenatorHighCollision() {
        // Wish I knew how to simulate this.
    }
    
    func testBumbleChickenatorLowCollision() {
        // Wish I knew how to simulate this.
    }
    
    func testBowlingBallBumbleCollision() {
        // Wish I knew how to simulate this.
    }
    
    func testPieBumbleCollision() {
        // Wish I knew how to simulate this.
    }
    
    func testChickenatorHighBumbleCollision() {
        // Wish I knew how to simulate this.
    }
    
    func testChickenatorLowBumbleCollision() {
        // Wish I knew how to simulate this.
    }
    
    private func GetBumble() -> Bumble {
        let bumble = Bumble(display: display)
        bumble.SetPhysics(physicsManager)
        XCTAssert(bumble.currentState == Bumble.STATE.RUNNING, "Bumble state should initially be running!")
        
        return bumble
    }
    
    private func GetPie() -> Pie {
        let bumble = GetBumble()
        let pie = Pie(display: display, floorLevel: 1, direction: .LEFT, velocity: 1, bumble: bumble)
        pie.SetPhysics(physicsManager)
        
        return pie
    }
    
    private func GetBowlingBall() -> BowlingBall {
        let bumble = GetBumble()
        let bowlingball = BowlingBall(display: display, floorLevel: 1, direction: .LEFT, velocity: 1, bumble: bumble)
        bowlingball.SetPhysics(physicsManager)
        
        return bowlingball
    }
    
    private func GetChickenatorLow() -> Chickenator {
        let bumble = GetBumble()
        let chickenator = Chickenator(display: display, floorLevel: 1, direction: .LEFT, velocity: 1, bumble: bumble)
        chickenator.SetPhysics(physicsManager)
        
        return chickenator
    }
    
    private func GetChickenatorHigh() -> Chickenator {
        let bumble = GetBumble()
        let chickenator = Chickenator(display: display, floorLevel: 1, direction: .LEFT, velocity: 1, bumble: bumble)
        chickenator.SetPhysics(physicsManager)
        
        return chickenator
    }
    
}
*/
