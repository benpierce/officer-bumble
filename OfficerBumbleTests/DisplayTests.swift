/*
===============================================================================
DisplayTests

Unit tests for every accessible member of the Display class.
===============================================================================
*/
/*
import UIKit
import XCTest
import SpriteKit
import OfficerBumble

class DisplayTests: XCTestCase {

    let FLOAT_PRECISION = CGFloat(0.015)
    let scene = SKScene()
    let iPadScene = SKScene()
    let node = SKSpriteNode()
    let sibling = SKSpriteNode()
    let parent = SKSpriteNode()
    let emptyMargin = Margin(marginTop : 0, marginBottom : 0, marginLeft : 0, marginRight : 0)
    
    override func setUp() {
        super.setUp()
        
        iPadScene.size.height = 1536
        iPadScene.size.width = 2048
        
        scene.size.height = 375
        scene.size.width = 500
        
        parent.size.height = 250
        parent.size.width = 350
        parent.position = CGPoint(x: 45, y: 101)
        
        sibling.size.height = 100
        sibling.size.width = 100
        sibling.position = CGPoint(x: 33, y: 45)
        
        node.size.height = 50
        node.size.width = 50
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    // 2048 x 1536 (iPad with Retina Size)
    func testSceneAnchorNoMargin() {
        let display = Display(size: iPadScene.size)
        
        // Top Left
        var point = display.GetSceneAnchor(node, margin : emptyMargin, anchorTo : Display.ANCHOR.TOP_LEFT)
        XCTAssert(point.x == -999, "Failed")
        XCTAssert(point.y == 743, "Failed")
        
        // Top Center
        point = display.GetSceneAnchor(node, margin : emptyMargin, anchorTo : Display.ANCHOR.TOP_CENTER)
        XCTAssert(point.x == 0, "Failed")
        XCTAssert(point.y == 743, "Failed")
        
        // Top Right
        point = display.GetSceneAnchor(node, margin : emptyMargin, anchorTo : Display.ANCHOR.TOP_RIGHT)
        XCTAssert(point.x == 999, "Failed")
        XCTAssert(point.y == 743, "Failed")
        
        // Center Left
        point = display.GetSceneAnchor(node, margin : emptyMargin, anchorTo : Display.ANCHOR.CENTER_LEFT)
        XCTAssert(point.x == -999, "Failed")
        XCTAssert(point.y == 0, "Failed")
        
        // Center
        point = display.GetSceneAnchor(node, margin : emptyMargin, anchorTo : Display.ANCHOR.CENTER)
        XCTAssert(point.x == 0, "Failed")
        XCTAssert(point.y == 0, "Failed")
        
        // Center Right
        point = display.GetSceneAnchor(node, margin : emptyMargin, anchorTo : Display.ANCHOR.CENTER_RIGHT)
        XCTAssert(point.x == 999, "Failed")
        XCTAssert(point.y == 0, "Failed")
        
        // Bottom Left
        point = display.GetSceneAnchor(node, margin : emptyMargin, anchorTo : Display.ANCHOR.BOTTOM_LEFT)
        XCTAssert(point.x == -999, "Failed")
        XCTAssert(point.y == -743, "Failed")
        
        // Bottom Center
        point = display.GetSceneAnchor(node, margin : emptyMargin, anchorTo : Display.ANCHOR.BOTTOM_CENTER)
        XCTAssert(point.x == 0, "Failed")
        XCTAssert(point.y == -743, "Failed")
        
        // Bottom Right
        point = display.GetSceneAnchor(node, margin : emptyMargin, anchorTo : Display.ANCHOR.BOTTOM_RIGHT)
        XCTAssert(point.x == 999, "Failed")
        XCTAssert(point.y == -743, "Failed")
    }
    
    // 500 x 375 (some obscure size)
    func testSiblingAnchorNoMargin() {
        let display = Display(size: scene.size)
        
        // Top Left
        var point = display.GetSiblingAnchor(node, sibling : sibling, margin : emptyMargin, anchorTo : Display.ANCHOR.TOP_LEFT)
        XCTAssert(point.x == -42, "Failed")
        XCTAssert(point.y == 120, "Failed")
        
        // Top Center
        point = display.GetSiblingAnchor(node, sibling : sibling, margin : emptyMargin, anchorTo : Display.ANCHOR.TOP_CENTER)
        XCTAssert(point.x == 33, "Failed")
        XCTAssert(point.y == 120, "Failed")
     
        // Top Right
        point = display.GetSiblingAnchor(node, sibling : sibling, margin : emptyMargin, anchorTo : Display.ANCHOR.TOP_RIGHT)
        XCTAssert(point.x == 108, "Failed")
        XCTAssert(point.y == 120, "Failed")
        
        // Center Left
        point = display.GetSiblingAnchor(node, sibling : sibling, margin : emptyMargin, anchorTo : Display.ANCHOR.CENTER_LEFT)
        XCTAssert(point.x == -42, "Failed")
        XCTAssert(point.y == 45, "Failed")
        
        // Center
        point = display.GetSiblingAnchor(node, sibling : sibling, margin : emptyMargin, anchorTo : Display.ANCHOR.CENTER)
        XCTAssert(point.x == 33, "Failed")
        XCTAssert(point.y == 45, "Failed")
        
        // Center Right
        point = display.GetSiblingAnchor(node, sibling : sibling, margin : emptyMargin, anchorTo : Display.ANCHOR.CENTER_RIGHT)
        XCTAssert(point.x == 108, "Failed")
        XCTAssert(point.y == 45, "Failed")
        
        // Bottom Left
        point = display.GetSiblingAnchor(node, sibling : sibling, margin : emptyMargin, anchorTo : Display.ANCHOR.BOTTOM_LEFT)
        XCTAssert(point.x == -42, "Failed")
        XCTAssert(point.y == -30, "Failed")
        
        // Bottom Center
        point = display.GetSiblingAnchor(node, sibling : sibling, margin : emptyMargin, anchorTo : Display.ANCHOR.BOTTOM_CENTER)
        XCTAssert(point.x == 33, "Failed")
        XCTAssert(point.y == -30, "Failed")
        
        // Bottom Right
        point = display.GetSiblingAnchor(node, sibling : sibling, margin : emptyMargin, anchorTo : Display.ANCHOR.BOTTOM_RIGHT)
        XCTAssert(point.x == 108, "Failed")
        XCTAssert(point.y == -30, "Failed")
    }
    
    // 500 x 375 (an obscure size
    func testParentAnchorNoMargin() {
        let display = Display(size: scene.size)
        
        // Top Left
        var point = display.GetParentAnchor(node, parent: parent, margin : emptyMargin, anchorTo : Display.ANCHOR.TOP_LEFT)
        XCTAssert(point.x == -150, "Failed")
        XCTAssert(point.y == 100, "Failed")
        
        // Top Center
        point = display.GetParentAnchor(node, parent: parent, margin : emptyMargin, anchorTo : Display.ANCHOR.TOP_CENTER)
        XCTAssert(point.x == 0, "Failed")
        XCTAssert(point.y == 100, "Failed")
        
        // Top Right
        point = display.GetParentAnchor(node, parent: parent, margin : emptyMargin, anchorTo : Display.ANCHOR.TOP_RIGHT)
        XCTAssert(point.x == 150, "Failed")
        XCTAssert(point.y == 100, "Failed")
        
        // Center Left
        point = display.GetParentAnchor(node, parent: parent, margin : emptyMargin, anchorTo : Display.ANCHOR.CENTER_LEFT)
        XCTAssert(point.x == -150, "Failed")
        XCTAssert(point.y == 0, "Failed")
        
        // Center
        point = display.GetParentAnchor(node, parent: parent, margin : emptyMargin, anchorTo : Display.ANCHOR.CENTER)
        XCTAssert(point.x == 0, "Failed")
        XCTAssert(point.y == 0, "Failed")
        
        // Center Right
        point = display.GetParentAnchor(node, parent: parent, margin : emptyMargin, anchorTo : Display.ANCHOR.CENTER_RIGHT)
        XCTAssert(point.x == 150, "Failed")
        XCTAssert(point.y == 0, "Failed")
        
        // Bottom Left
        point = display.GetParentAnchor(node, parent: parent, margin : emptyMargin, anchorTo : Display.ANCHOR.BOTTOM_LEFT)
        XCTAssert(point.x == -150, "Failed")
        XCTAssert(point.y == -100, "Failed")
        
        // Bottom Center
        point = display.GetParentAnchor(node, parent: parent, margin : emptyMargin, anchorTo : Display.ANCHOR.BOTTOM_CENTER)
        XCTAssert(point.x == 0, "Failed")
        XCTAssert(point.y == -100, "Failed")
        
        // Bottom Right
        point = display.GetParentAnchor(node, parent: parent, margin : emptyMargin, anchorTo : Display.ANCHOR.BOTTOM_RIGHT)
        XCTAssert(point.x == 150, "Failed")
        XCTAssert(point.y == -100, "Failed")
    }
    
    // Test Top Right, Center, Bottom Left
    // Parent is 350 x 250, iPad is 2048 x 1536
    func testParentAnchorWithMargin() {
        let display = Display(size: iPadScene.size)
        let margin1 = Margin(marginTop : 0.1, marginBottom : 0.1, marginLeft : 0.023, marginRight : 0.04)
        let margin2 = Margin(marginTop: 0.01, marginBottom: 0.00, marginLeft: 0.054, marginRight: 0.044)
        let margin3 = Margin(marginTop: 0.0, marginBottom: 0.2, marginLeft: 0.15, marginRight: 0.0)
        
        // Top Right (150, 100 without margin).
        // Margin evaluates to: 153.6 Top, 153.6 Bottom, 47.104 Left, 81.92 Right
        var point = display.GetParentAnchor(node, parent: parent, margin : margin1, anchorTo : Display.ANCHOR.TOP_RIGHT)
        XCTAssertEqualWithAccuracy(point.x, CGFloat(130.416), FLOAT_PRECISION, "Failed")
        XCTAssertEqualWithAccuracy(point.y, CGFloat(100), FLOAT_PRECISION, "Failed")
        
        // Center (0, 0 without the margin).
        // Margin evaluates to: 15.36 Top, 0 Bottom, 110.592 Left, 90.112 Right
        point = display.GetParentAnchor(node, parent: parent, margin: margin2, anchorTo: Display.ANCHOR.CENTER)
        XCTAssertEqualWithAccuracy(point.x, CGFloat(11.52), FLOAT_PRECISION, "Failed")
        XCTAssertEqualWithAccuracy(point.y, CGFloat(-15.36) * display.GetWideScreenCorrectionRatio(), FLOAT_PRECISION, "Failed")
        
        // Bottom Left (-150 and -100 without the margin).
        // Margin evaluates to: 0 Top, 307.2 Bottom, 307.2 Left, 0 Right
        point = display.GetParentAnchor(node, parent: parent, margin: margin3, anchorTo: Display.ANCHOR.BOTTOM_LEFT)
        XCTAssertEqualWithAccuracy(point.x, CGFloat(22.8), FLOAT_PRECISION, "Failed")
        XCTAssertEqualWithAccuracy(point.y, CGFloat(130.4), FLOAT_PRECISION, "Failed")
    }
    
    // Test Top Center, Center Right, Bottom Center
    // Scene is 2048 x 1536
    // Sibling is 100 x 100 and at 33, y: 45 in the scene.
    func testSiblingAnchorWithMargin() {
        let display = Display(size: iPadScene.size)
        let margin1 = Margin(marginTop : 0.01, marginBottom : 0.0, marginLeft : 0.0, marginRight : 0.045)
        let margin2 = Margin(marginTop: 0.00, marginBottom: 0.00, marginLeft: 0.07, marginRight: 0.0)
        let margin3 = Margin(marginTop: 0.0, marginBottom: 0.2, marginLeft: 0.06, marginRight: 0.023)
        
        // Top Center (33, 120 without margin).
        // Margin evaluates to: 15.36 Top, 0 Bottom, 0 Left, 92.16 Right
        var point = display.GetSiblingAnchor(node, sibling: sibling, margin : margin1, anchorTo : Display.ANCHOR.TOP_CENTER)
        XCTAssertEqualWithAccuracy(point.x, CGFloat(-18.84), FLOAT_PRECISION, "Failed")
        XCTAssertEqualWithAccuracy(point.y, CGFloat(108.48), FLOAT_PRECISION, "Failed")
        
        // Center Right (108, 45 without the margin).
        // Margin evaluates to: 0 Top, 0 Bottom, 143.36 Left, 0 Right
        point = display.GetSiblingAnchor(node, sibling: sibling, margin: margin2, anchorTo: Display.ANCHOR.CENTER_RIGHT)
        XCTAssertEqualWithAccuracy(point.x, CGFloat(188.64), FLOAT_PRECISION, "Failed")
        XCTAssertEqualWithAccuracy(point.y, CGFloat(45), FLOAT_PRECISION, "Failed")
        
        // Bottom Center (33 and -30 without the margin).
        // Margin evaluates to: 0 Top, 307.2 Bottom, 122.88 Left, 47.104 Right
        point = display.GetSiblingAnchor(node, sibling: sibling, margin: margin3, anchorTo: Display.ANCHOR.BOTTOM_CENTER)
        XCTAssertEqualWithAccuracy(point.x, CGFloat(75.624), FLOAT_PRECISION, "Failed")
        XCTAssertEqualWithAccuracy(point.y, CGFloat(200.4), FLOAT_PRECISION, "Failed")
    }
    
    // iPadScene size scene (2048 x 1536)
    // Test Top Left, Center, and Bottom Right
    func testSceneAnchorWithMargin() {
        let display = Display(size: iPadScene.size)
        let margin1 = Margin(marginTop : 0.05, marginBottom : 0.1, marginLeft : 0.01, marginRight : 0.02)
        let margin2 = Margin(marginTop: 0.00, marginBottom: 0.04, marginLeft: 0.05, marginRight: 0.0)
        let margin3 = Margin(marginTop: 1.0, marginBottom: 0.0, marginLeft: 0.0, marginRight: 0.5)
        
        // Top Left (-999 and 743 without the margin).
        // Margin evaluates to: 76.8 Top, 153.6 Bottom, 20.48 Left, 40.96 Right
        var point = display.GetSceneAnchor(node, margin : margin1, anchorTo : Display.ANCHOR.TOP_LEFT)
        XCTAssertEqualWithAccuracy(point.x, CGFloat(-1010.52), FLOAT_PRECISION, "Failed")
        XCTAssertEqualWithAccuracy(point.y, CGFloat(800.6), FLOAT_PRECISION, "Failed")
        
        // Center (0, 0 without the margin).
        // Margin evaluates to: 0 Top, 61.44 Bottom, 102.4 Left, 0 Right
        point = display.GetSceneAnchor(node, margin: margin2, anchorTo: Display.ANCHOR.CENTER)
        XCTAssertEqualWithAccuracy(point.x, CGFloat(57.6), FLOAT_PRECISION, "Failed")
        XCTAssertEqualWithAccuracy(point.y, CGFloat(61.44) * display.GetWideScreenCorrectionRatio(), FLOAT_PRECISION, "Failed")
        
        // Bottom Right (999 and -743 without the margin).
        // Margin evaluates to: 1536 Top, 0 Bottom, 0 Left, 1024 Right
        point = display.GetSceneAnchor(node, margin: margin3, anchorTo: Display.ANCHOR.BOTTOM_RIGHT)
        XCTAssertEqualWithAccuracy(point.x, CGFloat(423), FLOAT_PRECISION, "Failed")
        XCTAssertEqualWithAccuracy(point.y, CGFloat(-1895), FLOAT_PRECISION, "Failed")
    }
    
    // Tests some screen width by % normalizations by aspect ratio.
    func testGetNormalizedScreenWidthByPercentage() {
        let display = Display(size: iPadScene.size)
        
        XCTAssertEqualWithAccuracy(display.GetNormalizedScreenWidthByPercentage(0), CGFloat(0), FLOAT_PRECISION, "Failed")
        XCTAssertEqualWithAccuracy(display.GetNormalizedScreenWidthByPercentage(0.25), CGFloat(384) * display.GetWideScreenCorrectionRatio(), FLOAT_PRECISION, "Failed")
        XCTAssertEqualWithAccuracy(display.GetNormalizedScreenWidthByPercentage(0.50), CGFloat(768) * display.GetWideScreenCorrectionRatio(), FLOAT_PRECISION, "Failed")
        XCTAssertEqualWithAccuracy(display.GetNormalizedScreenWidthByPercentage(0.75), CGFloat(1152) * display.GetWideScreenCorrectionRatio(), FLOAT_PRECISION, "Failed")
        XCTAssertEqualWithAccuracy(display.GetNormalizedScreenWidthByPercentage(1.0), CGFloat(1536) * display.GetWideScreenCorrectionRatio(), FLOAT_PRECISION, "Failed")
        XCTAssertEqualWithAccuracy(display.GetNormalizedScreenWidthByPercentage(0.85), CGFloat(1305.6) * display.GetWideScreenCorrectionRatio(), FLOAT_PRECISION, "Failed")
    }
    
    func testGetNormalizedScreenHeightByPercentage() {
        let display = Display(size: scene.size)
        
        XCTAssertEqualWithAccuracy(display.GetNormalizedScreenHeightByPercentage(0), CGFloat(0), FLOAT_PRECISION, "Failed")
        XCTAssertEqualWithAccuracy(display.GetNormalizedScreenHeightByPercentage(0.25), CGFloat(93.75) * display.GetWideScreenCorrectionRatio(), FLOAT_PRECISION, "Failed")
        XCTAssertEqualWithAccuracy(display.GetNormalizedScreenHeightByPercentage(0.50), CGFloat(187.5) * display.GetWideScreenCorrectionRatio(), FLOAT_PRECISION, "Failed")
        XCTAssertEqualWithAccuracy(display.GetNormalizedScreenHeightByPercentage(0.75), CGFloat(281.25) * display.GetWideScreenCorrectionRatio(), FLOAT_PRECISION, "Failed")
        XCTAssertEqualWithAccuracy(display.GetNormalizedScreenHeightByPercentage(1.0), CGFloat(375) * display.GetWideScreenCorrectionRatio(), FLOAT_PRECISION, "Failed")
        XCTAssertEqualWithAccuracy(display.GetNormalizedScreenHeightByPercentage(0.85), CGFloat(318.75) * display.GetWideScreenCorrectionRatio(), FLOAT_PRECISION, "Failed")
    }
    
    func testGetSize() {
        let display = Display(size: scene.size)
        
        let size = display.GetSize(50, height: 50)
        XCTAssert(size.width == 37.5 * display.GetWideScreenCorrectionRatio(), "Failed")
        XCTAssert(size.height == 50 * display.GetWideScreenCorrectionRatio(), "Failed")
        
        let size2 = display.GetSize(500, height: 100)
        XCTAssert(size2.width == 375 * display.GetWideScreenCorrectionRatio(), "Failed")
        XCTAssert(size2.height == 100 * display.GetWideScreenCorrectionRatio(), "Failed")
    }
    
    func testGetSizeByPercentageOfScene() {
        let display = Display(size: iPadScene.size)
        
        let size = display.GetSizeByPercentageOfScene(0.5, heightPercent: 0.75, considerAspectRatio: false)
        XCTAssert(size.width == 1024, "Failed")
        XCTAssert(size.height == 1152, "Failed")
        
        let size2 = display.GetSizeByPercentageOfScene(0.5, heightPercent: 0.75, considerAspectRatio: true)
        XCTAssert(size2.width == 768 * display.GetWideScreenCorrectionRatio(), "Failed")
        XCTAssert(size2.height == 1152 * display.GetWideScreenCorrectionRatio(), "Failed")
    }
    
    func testGetTouchLocation() {
        let display = Display(size: iPadScene.size)
        
        XCTAssert(display.GetTouchLocation(-1) == .LEFT, "Failed")
        XCTAssert(display.GetTouchLocation(1) == .RIGHT, "Failed")
        XCTAssert(display.GetTouchLocation(0) == .LEFT, "Failed")
        
        XCTAssert(display.GetTouchLocation(234) == .RIGHT, "Failed")
        XCTAssert(display.GetTouchLocation(-1001) == .LEFT, "Failed")
    }

}
*/
