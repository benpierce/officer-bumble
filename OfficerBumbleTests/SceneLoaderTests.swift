/*
===============================================================================
SceneLoaderTests

Unit tests for every possible Scene Loader scenario.
===============================================================================
*/
/*
import XCTest
import OfficerBumble
import SpriteKit

class SceneLoaderTests: XCTestCase {
    
    let scene = SKScene()
    let iPadScene = SKScene()
    let SCENE_HEIGHT = CGFloat(435)
    let SCENE_WIDTH = CGFloat(700)
    let FLOAT_PRECISION = CGFloat(0.015)
    
    override func setUp() {
        super.setUp()
        scene.size.height = SCENE_HEIGHT
        scene.size.width = SCENE_WIDTH
        
        iPadScene.size.height = 1536
        iPadScene.size.width = 2048
    }
    
    override func tearDown() {
        // Put teardown code here.
        super.tearDown()
    }

    func testSplashScreen() {
        let display = Display(size: scene.size)
        let loader = SceneLoader()
        loader.Initialize(display, _scene : scene, resourceName : "splashscreen")
        
        AssertHasWorldAndHUD(scene)
        
        // Validate first and only sub-node
        var world = scene.childNodeWithName("//World") as SKSpriteNode
        XCTAssert(world.children.count == 1, "World should have one child")  // Just the splash screen image.
        XCTAssert(world.children[0].name == "Logo", "Child should be called Logo")
    }
    
    func testTitleScreen() {
        let display = Display(size: scene.size)
        let loader = SceneLoader()
        loader.Initialize(display, _scene : scene, resourceName : "titlescreen")
        
        AssertHasWorldAndHUD(scene)
        
        // Validate world exists.
        var world = scene.childNodeWithName("//World") as SKSpriteNode
        XCTAssert(world.children.count == 1, "World node should have one child.")
        XCTAssert(world.children[0].name == "Title", "Child name should be Title")
        
        // Validate sub-nodes exist.
        var title = scene.childNodeWithName("//Title") as SKSpriteNode
        XCTAssert(title.children.count == 8, "Title node should have 7 children")
    }
    
    // Tests that scene items marked "hud-element" are a part of the scene rather than a part of a node.
    // Also tests that the scene is given a name.
    func testHUD() {
        let display = Display(size : scene.size)
        let loader = SceneLoader()
        loader.Initialize(display, _scene : scene, resourceName : "training")
        
        AssertHasWorldAndHUD(scene)
        
        var world = scene.childNodeWithName("//World") as SKSpriteNode
        XCTAssertNotNil(world, "World can't be nil!")
        XCTAssert(world.parent!.name == scene.name, "World should be part of the scene!")
        
        var hud = scene.childNodeWithName("//HUD") as SKSpriteNode
        XCTAssertNotNil(hud, "HUD can't be nil!")
        XCTAssert(hud.parent!.name == scene.name, "HUD should be part of the scene!")
        
        var btnback = scene.childNodeWithName("//btnback") as SKSpriteNode
        XCTAssertNotNil(btnback, "btnback can't be nil!")
        XCTAssert(btnback.parent!.name == hud.name, "btnback should be part of the HUD!")
    }
    
    // Tests that a world that's bigger than what can be displayed on screen is properly sized.
    func testScrollingSceneWidth1() {
        let display = Display(size: scene.size)
        let loader = SceneLoader()
        loader.Initialize(display, _scene: scene, resourceName: "threewide")

        AssertHasWorldAndHUD(scene)
        
        // World should be 3 tiles wide which would equal:
        // 435 * 0.50 high.
        // (700 / aspectRatio wide) * 3
        var world = scene.childNodeWithName("//World") as SKSpriteNode
        XCTAssertNotNil(world, "World not found!")

        let size = world.size
        
        XCTAssertEqualWithAccuracy(world.size.height, CGFloat(217.5) * display.GetWideScreenCorrectionRatio(), CGFloat(0.01), "World height not correct!")
        XCTAssertEqualWithAccuracy(world.size.width, CGFloat(1305) * display.GetWideScreenCorrectionRatio(), CGFloat(0.01), "World width not correct!")
    }
    
    // Another test at creating a real-sized Bumble world and examining the width.
    func testScrollingSceneWidth2() {
        let display = Display(size: iPadScene.size)
        let loader = SceneLoader()
        loader.Initialize(display, _scene: scene, resourceName: "twentyonewide")
        
        AssertHasWorldAndHUD(scene)
        
        // World should be 3 tiles wide which would equal:
        // 1536 * 0.50 high.
        // (2048 / 1.3333333 wide) * 21
        var world = scene.childNodeWithName("//World") as SKSpriteNode
        XCTAssertNotNil(world, "World not found!")
        let size = world.size
        
        XCTAssertEqualWithAccuracy(world.size.height, CGFloat(768) * display.GetWideScreenCorrectionRatio(), CGFloat(0.01), "World height not correct!")
        XCTAssertEqualWithAccuracy(world.size.width, CGFloat(32256) * display.GetWideScreenCorrectionRatio(), CGFloat(0.01), "World width not correct!")
    }
    
    // Tests that a world that's bigger than what can be displayed vertically is properly sized.
    func testScrollingSceneHeight1() {
        let display = Display(size: scene.size)
        let loader = SceneLoader()
        loader.Initialize(display, _scene: scene, resourceName: "threehigh")
        
        AssertHasWorldAndHUD(scene)
        
        // World should be 3 tiles wide which would equal:
        // 435 * 0.50 high * 3
        // (700 / aspectRatio wide) * 3
        var world = scene.childNodeWithName("//World") as SKSpriteNode
        XCTAssertNotNil(world, "World not found!")
        let size = world.size
        
        XCTAssertEqualWithAccuracy(world.size.height, CGFloat(652.5) * display.GetWideScreenCorrectionRatio(), CGFloat(0.01), "World height not correct!")
        XCTAssertEqualWithAccuracy(world.size.width, CGFloat(1305) * display.GetWideScreenCorrectionRatio(), CGFloat(0.01), "World width not correct!")
    }
    
    // Tests that a world that's bigger than what can be displayed veritcally (4 screens up) is properly
    // sized.
    func testScrollingSceneHeight2() {
        let display = Display(size: iPadScene.size)
        let loader = SceneLoader()
        loader.Initialize(display, _scene: scene, resourceName: "fourhigh")
        
        AssertHasWorldAndHUD(scene)
        
        // World should be 3 tiles wide which would equal:
        // 1536 * 0.50 high * 4
        // (2048 / aspectRatio wide) * 3
        var world = scene.childNodeWithName("//World") as SKSpriteNode
        XCTAssertNotNil(world, "World not found!")
        let size = world.size
        
        XCTAssertEqualWithAccuracy(world.size.height, CGFloat(3072) * display.GetWideScreenCorrectionRatio(), CGFloat(0.01), "World height not correct!")
        XCTAssertEqualWithAccuracy(world.size.width, CGFloat(4608) * display.GetWideScreenCorrectionRatio(), CGFloat(0.01), "World width not correct!")
    }
    
    func testNestedScreen() {
        let display = Display(size : scene.size)
        let loader = SceneLoader()
        loader.Initialize(display, _scene : scene, resourceName : "nestedtest")
        
        AssertHasWorldAndHUD(scene)
        
        var world = scene.childNodeWithName("//World") as SKSpriteNode
        XCTAssert(world.children.count == 2, "World should have 2 child nodes!")
        
        // companylogo should have 3 children.
        var companylogo = scene.childNodeWithName("//companylogo")
        XCTAssertNotNil(companylogo, "Passed")
        XCTAssert(companylogo!.children.count == 3, "Passed")
        
        // lb should have one child.
        var lb = scene.childNodeWithName("//lb")
        XCTAssertNotNil(lb, "Passed")
        XCTAssert(lb!.children.count == 1, "Passed")
        
        // Validate that loading exists with no children.
        var loading = scene.childNodeWithName("//loading")
        XCTAssertNotNil(loading, "Passed")
        XCTAssert(loading!.children.count == 0, "Passed")
    }

    func testDoesntLoseParent() {
        let display = Display(size : scene.size)
        
        let loader = SceneLoader()
        loader.Initialize(display, _scene : scene, resourceName : "parenttest")
        
        AssertHasWorldAndHUD(scene)
        
        var world = scene.childNodeWithName("//World") as SKSpriteNode
        XCTAssert(world.children.count == 1, "World should have 1 child node!")
        
        // companylogo should have 2 children.
        var companylogo = scene.childNodeWithName("//companylogo")
        XCTAssertNotNil(companylogo, "Passed")
        XCTAssert(companylogo!.children.count == 2, "Passed")
        
        var fblogin1 = scene.childNodeWithName("//fblogin1")
        XCTAssertNotNil(fblogin1, "Passed")
        XCTAssert(fblogin1!.children.count == 2, "Passed")
    }
    
    /*
        Load siblingtest.xml into the scene and validate that there are 6 nodes and 
        that they are all in the exact location that we expect them to be in.
    
        Should look like this:
    
        companylogo
            fblogin1
                fblogin2
                fblogin3
            fblogin4
            fblogin5
    
        Aspect ratio is 1.6091954
    */
    func testDoesntLoseSibling() {
        let display = Display(size: scene.size)

        let loader = SceneLoader()
        loader.Initialize(display, _scene : scene, resourceName : "siblingtest")
        AssertHasWorldAndHUD(scene)
        
        // Validate companylogo size, position and children
        // Center screen is height / 2 and width / 2
        var companylogo = scene.childNodeWithName("//companylogo") as SKSpriteNode
        XCTAssertNotNil(companylogo, "CompanyLogo not found")
        XCTAssert(companylogo.children.count == 3, "Failed")
        XCTAssert(companylogo.size.width == 391.5 * display.GetWideScreenCorrectionRatio(), "Failed")
        XCTAssert(companylogo.size.height == 391.5 * display.GetWideScreenCorrectionRatio(), "Failed")
        XCTAssert(companylogo.position.x == 0, "Failed")
        XCTAssert(companylogo.position.y == 0, "Failed")
        
        // Validate fblogin1
        var fblogin1 = scene.childNodeWithName("//fblogin1") as SKSpriteNode
        XCTAssertNotNil(fblogin1, "Failed")
        XCTAssert(fblogin1.children.count == 2, "Failed")
        XCTAssert(fblogin1.size.width == 108.75 * display.GetWideScreenCorrectionRatio(), "Failed")
        XCTAssert(fblogin1.size.height == 108.75 * display.GetWideScreenCorrectionRatio(), "Failed")
        XCTAssert(fblogin1.position.x == 0, "Failed")  // Center in a parent node is 0
        XCTAssert(fblogin1.position.y == 141.375 * display.GetWideScreenCorrectionRatio(), "Failed")  // Top in a parent node is CENTER(0) + (parent_height / 2) - (node_height / 2)
        
        // Validate fblogin2
        var fblogin2 = scene.childNodeWithName("//fblogin2") as SKSpriteNode
        XCTAssertNotNil(fblogin2, "Failed")
        XCTAssert(fblogin2.children.count == 0, "Failed")
        XCTAssertEqualWithAccuracy(fblogin2.size.width, CGFloat(59.0625), FLOAT_PRECISION, "Failed")
        XCTAssert(fblogin2.size.height == 65.25 * display.GetWideScreenCorrectionRatio(), "Failed")
        XCTAssertEqualWithAccuracy(fblogin2.position.x, CGFloat(19.6875), FLOAT_PRECISION, "Failed")
        XCTAssert(fblogin2.position.y == 21.75 * display.GetWideScreenCorrectionRatio(), "Failed")
        
        // Validate fblogin3
        var fblogin3 = scene.childNodeWithName("//fblogin3") as SKSpriteNode
        XCTAssertNotNil(fblogin3, "Failed")
        XCTAssert(fblogin3.children.count == 0, "Failed")
        XCTAssertEqualWithAccuracy(fblogin3.size.width, CGFloat(59.0625), FLOAT_PRECISION, "Failed")
        XCTAssert(fblogin3.size.height == 65.25 * display.GetWideScreenCorrectionRatio(), "Failed")
        XCTAssert(fblogin3.position.x == 0, "Failed")
        XCTAssert(fblogin3.position.y == 0, "Failed")
        
        // Validate fblogin4
        var fblogin4 = scene.childNodeWithName("//fblogin4") as SKSpriteNode
        XCTAssertNotNil(fblogin4, "Failed")
        XCTAssert(fblogin4.children.count == 0, "Failed")
        XCTAssertEqualWithAccuracy(fblogin4.size.width, CGFloat(59.0625), FLOAT_PRECISION, "Failed")
        XCTAssert(fblogin4.size.height == 65.25 * display.GetWideScreenCorrectionRatio(), "Failed")
        XCTAssert(fblogin4.position.x == 0, "Failed")  // Center of sibling which is fblogin1.
        XCTAssert(fblogin4.position.y == 54.375 * display.GetWideScreenCorrectionRatio(), "Failed")  // Beneath fblogin1
        
        // Validate fblogin5
        var fblogin5 = scene.childNodeWithName("//fblogin5") as SKSpriteNode
        XCTAssertNotNil(fblogin5, "Failed")
        XCTAssert(fblogin5.children.count == 0, "Failed")
        XCTAssert(fblogin5.size.width == 43.5 * display.GetWideScreenCorrectionRatio(), "Failed")
        XCTAssert(fblogin5.size.height == 43.5 * display.GetWideScreenCorrectionRatio(), "Failed")
        XCTAssertEqualWithAccuracy(fblogin5.size.width, CGFloat(39.375), FLOAT_PRECISION, "Failed")
        XCTAssert(fblogin5.position.y == 54.375 * display.GetWideScreenCorrectionRatio(), "Failed")  // Center of fblogin4
    }
    
    private func AssertHasWorldAndHUD(scene: SKScene) {
        var world = scene.childNodeWithName("//World") as SKSpriteNode
        XCTAssertNotNil(world, "World not found!")
        XCTAssert(world.parent!.name == scene.name, "World should be descendent of scene!")
        
        var HUD = scene.childNodeWithName("//HUD") as SKSpriteNode
        XCTAssertNotNil(HUD, "HUD not found!")
        XCTAssert(HUD.parent!.name == scene.name, "HUD should be descendent of scene!")
    }
}
*/
