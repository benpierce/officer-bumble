//
//  WeaponTests.swift
//  OfficerBumble
//
//  Created by Ben Pierce on 2015-01-13.
//  Copyright (c) 2015 Benjamin Pierce. All rights reserved.
//
/*
import UIKit
import XCTest
import SpriteKit
import OfficerBumble

class WeaponTests: XCTestCase {

    var iPadScene = SKScene()
    var display: Display!
    var howFarBehind = CGFloat(0)
    
    override func setUp() {
        super.setUp()
        
        iPadScene.size.height = 1536
        iPadScene.size.width = 2048
        howFarBehind = iPadScene.size.width / 2.0
        
        display = Display(size: iPadScene.size)
    }
    
    override func tearDown() {
        iPadScene.removeAllChildren()
        
        super.tearDown()
    }

    // Bumble going right, weapon going left
    func testWentBehindBumbleLeft() {
        let bumble = GetBumble()
        bumble.direction = .RIGHT
        let world = GetWorld(iPadScene.size)
        
        iPadScene.addChild(world)   // Create world the same size.
        
        // Add Bumble to world and position him.
        world.addChild(bumble)
        bumble.position = CGPoint(x: -(iPadScene.size.width / 2) + bumble.size.width + 400, y: 0)
        
        // Now create a bowling ball and put it in front of him.
        let bowlingBall = BowlingBall(display: display, floorLevel: 1, direction: .LEFT, velocity: 1, bumble: bumble)
        world.addChild(bowlingBall)
        bowlingBall.position = CGPoint(x: bumble.position.x + (bumble.size.width / 2.0) + (bowlingBall.size.width / 2.0) + 1, y: 0)
        
        // Check bowling ball initial properties.
        XCTAssert(bowlingBall.isBehindBumble == false, "Failed")
        AssertNode(world, nodeName: bowlingBall.name!)
        
        bowlingBall.Update(CACurrentMediaTime(), display: display)
        XCTAssert(bowlingBall.isBehindBumble == false, "Failed")
        AssertNode(world, nodeName: bowlingBall.name!)
        
        // Put Bowling Ball right behind Bumble.
        bowlingBall.position = CGPoint(x: bumble.position.x - (bumble.size.width / 2.0) - (bowlingBall.size.width / 2.0) - 1, y: 0)
        bowlingBall.Update(CACurrentMediaTime(), display: display)
        XCTAssert(bowlingBall.isBehindBumble, "Failed")
        AssertNode(world, nodeName: bowlingBall.name!)
        
        // Put Bowling Ball off screen behind Bumble.
        bowlingBall.position = CGPoint(x: bumble.position.x - howFarBehind, y: 0)
        bowlingBall.Update(CACurrentMediaTime(), display: display)
        AssertNoNode(world, nodeName: bowlingBall.name!)
    }
    
    // Bumble going right, weapon going left
    func testWentBehindBumbleScrollableWorldLeft() {
        let bumble = GetBumble()
        bumble.direction = .RIGHT
        
        let world = GetWorld(CGSize(width: iPadScene.size.width * 5, height: iPadScene.size.height * 5))
        
        iPadScene.addChild(world)   // Create world the same size.
        
        // Add Bumble to world and position him.
        world.addChild(bumble)
        bumble.position = CGPoint(x: 0, y: 0)
        
        // Now create a bowling ball and put it in front of him.
        let pie = Pie(display: display, floorLevel: 1, direction: .LEFT, velocity: 1, bumble: bumble)
        world.addChild(pie)
        pie.position = CGPoint(x: bumble.position.x + (bumble.size.width / 2.0) + (pie.size.width / 2.0) + 1, y: 0)
        
        // Check bowling ball initial properties.
        XCTAssert(pie.isBehindBumble == false, "Failed")
        AssertNode(world, nodeName: pie.name!)
        
        pie.Update(CACurrentMediaTime(), display: display)
        XCTAssert(pie.isBehindBumble == false, "Failed")
        AssertNode(world, nodeName: pie.name!)
        
        // Put Bowling Ball right behind Bumble.
        pie.position = CGPoint(x: bumble.position.x - (bumble.size.width / 2.0) - (pie.size.width / 2.0) - 1, y: 0)
        pie.Update(CACurrentMediaTime(), display: display)
        XCTAssert(pie.isBehindBumble, "Failed")
        AssertNode(world, nodeName: pie.name!)
        
        // Put Bowling Ball off screen behind Bumble.
        pie.position = CGPoint(x: bumble.position.x - howFarBehind, y: 0)
        pie.Update(CACurrentMediaTime(), display: display)
        AssertNoNode(world, nodeName: pie.name!)
    }
    
    // Bumble going left, weapon going right.
    func testWentBehindBumbleRight() {
        let bumble = GetBumble()
        bumble.direction = .LEFT
        
        let world = GetWorld(iPadScene.size)
        
        iPadScene.addChild(world)   // Create world the same size.
        
        // Add Bumble to world and position him.
        world.addChild(bumble)
        bumble.position = CGPoint(x: iPadScene.size.width / 2 - bumble.size.width, y: 0)
        
        // Now create a bowling ball and put it in front of him.
        let chickenator = Chickenator(display: display, floorLevel: 1, direction: .RIGHT, velocity: 1, bumble: bumble)
        world.addChild(chickenator)
        chickenator.position = CGPoint(x: bumble.position.x - (bumble.size.width / 2) - (chickenator.size.width / 2.0) - 1, y: 0)
        
        // Check chickenator initial properties.
        XCTAssert(chickenator.isBehindBumble == false, "Failed")
        AssertNode(world, nodeName: chickenator.name!)
        
        chickenator.Update(CACurrentMediaTime(), display: display)
        XCTAssert(chickenator.isBehindBumble == false, "Failed")
        AssertNode(world, nodeName: chickenator.name!)
        
        // Put Chickenator right behind Bumble.
        chickenator.position = CGPoint(x: bumble.position.x + (bumble.size.width / 2.0) + (chickenator.size.width / 2.0) + 1, y: 0)
        chickenator.Update(CACurrentMediaTime(), display: display)
        XCTAssert(chickenator.isBehindBumble, "Failed")
        AssertNode(world, nodeName: chickenator.name!)
        
        // Put Chickenator off screen behind Bumble.
        chickenator.position = CGPoint(x: bumble.position.x + howFarBehind, y: 0)
        chickenator.Update(CACurrentMediaTime(), display: display)
        AssertNoNode(world, nodeName: chickenator.name!)
    }
    
    // Bumble going left, weapon going right
    func testWentBehindBumbleScrollableWorldRight() {
        let bumble = GetBumble()
        bumble.direction = .LEFT
        
        let world = GetWorld(CGSize(width: iPadScene.size.width * 5, height: iPadScene.size.height * 5))
        
        iPadScene.addChild(world)   // Create world the same size.
        
        // Add Bumble to world and position him.
        world.addChild(bumble)
        bumble.position = CGPoint(x: 0, y: 0)
        
        // Now create a bowling ball and put it in front of him.
        let pie = Pie(display: display, floorLevel: 1, direction: .RIGHT, velocity: 1, bumble: bumble)
        world.addChild(pie)
        pie.position = CGPoint(x: bumble.position.x - (bumble.size.width / 2.0) - (pie.size.width / 2.0) - 1, y: 0)
        
        // Check bowling ball initial properties.
        XCTAssert(pie.isBehindBumble == false, "Failed")
        AssertNode(world, nodeName: pie.name!)
        
        pie.Update(CACurrentMediaTime(), display: display)
        XCTAssert(pie.isBehindBumble == false, "Failed")
        AssertNode(world, nodeName: pie.name!)
        
        // Put Bowling Ball right behind Bumble.
        pie.position = CGPoint(x: bumble.position.x + (bumble.size.width / 2.0) + (pie.size.width / 2.0) + 1, y: 0)
        pie.Update(CACurrentMediaTime(), display: display)
        XCTAssert(pie.isBehindBumble, "Failed")
        AssertNode(world, nodeName: pie.name!)
        
        // Put Bowling Ball off screen behind Bumble.
        pie.position = CGPoint(x: bumble.position.x + howFarBehind, y: 0)
        pie.Update(CACurrentMediaTime(), display: display)
        AssertNoNode(world, nodeName: pie.name!)
    }
    
    private func GetWorld(size: CGSize) -> SKSpriteNode {
        let world = SKSpriteNode()
        world.size = size
        world.name = "World"
        
        return world
    }

    private func AssertNode(parent: SKSpriteNode, nodeName: String) {
        let searchString = "//\(nodeName)"
        let node = parent.childNodeWithName(searchString) as SKSpriteNode?
        XCTAssertNotNil(node, "Failed")
    }
    
    private func AssertNoNode(parent: SKSpriteNode, nodeName: String) {
        let searchString = "//\(nodeName)"
        let node = parent.childNodeWithName(searchString) as SKSpriteNode?
        XCTAssertNil(node, "Failed")
    }
    
    private func GetBumble() -> Bumble {
        let bumble = Bumble(display: display)
        XCTAssert(bumble.currentState == Bumble.STATE.RUNNING, "Bumble state should initially be running!")
        
        return bumble
    }

}
*/
