/*
===============================================================================
Display

Handles all display dependent math.
===============================================================================
*/

import Foundation
import SpriteKit

open class Display {
    
    // We need to target a specific aspect ratio, otherwise relative sprite sizes are going to be different for each 
    // different aspect ratio.
    fileprivate let TARGET_ASPECT_RATIO = CGSize(width: 16, height: 9)
    
    // Possible anchor points.
    public enum ANCHOR : String {
        case TOP_LEFT = "TOP_LEFT"
        case CENTER_LEFT = "CENTER_LEFT"
        case BOTTOM_LEFT = "BOTTOM_LEFT"
        case TOP_CENTER = "TOP_CENTER"
        case CENTER = "CENTER"                  // Doesn't apply to sibling.
        case BOTTOM_CENTER = "BOTTOM_CENTER"
        case TOP_RIGHT = "TOP_RIGHT"
        case CENTER_RIGHT = "CENTER_RIGHT"
        case BOTTOM_RIGHT = "BOTTOM_RIGHT"
    }
    
    // Location that a touch occurs.
    public enum TOUCH_LOCATION {
        case left
        case right
    }
    
    // If no margin is passed in.
    fileprivate let emptyMargin = Margin(marginTop : 0, marginBottom : 0, marginLeft : 0, marginRight : 0)
    
    // Cache the scene's size as well as the various aspect ratios.
    open var sceneSize : CGSize
    fileprivate var aspectRatioX : CGFloat
    fileprivate var aspectRatioY : CGFloat
    
    // If we're in 4:3 aspect ratio, we need to size the sprites as if they were in 16:9 aspect ratio.
    // In order to do this we'll need to apply an additional calculation whenever we calculate sizes.
    fileprivate var wideScreenCorrection: CGFloat
    
    public init(size: CGSize) {
        self.sceneSize = size
        
        self.aspectRatioX = 16 / 9
        self.aspectRatioY = 1
        
        // Calculate aspect ratios.
        if(self.sceneSize.width > self.sceneSize.height) {
            self.aspectRatioX = self.sceneSize.width / self.sceneSize.height
            self.aspectRatioY = 1
        } else {
            self.aspectRatioY = self.sceneSize.height / self.sceneSize.width
            self.aspectRatioX = 1
        }
        
        // Figure out our wide screen sizing correction.
        let targetHeight = TARGET_ASPECT_RATIO.height / TARGET_ASPECT_RATIO.width * self.sceneSize.width
        wideScreenCorrection = targetHeight / self.sceneSize.height
    }
    
    open func GetWideScreenCorrectionRatio() -> CGFloat {
        return wideScreenCorrection
    }
    
    // Is the screen ratio 4:3?
    open func Is43() -> Bool {
        if ( self.sceneSize.height / self.sceneSize.width == 0.75 ) {
            return true
        } else {
            return false
        }
    }
    
    // Returns a % of the screen width that is scaled by the display's aspect ratio.
    open func GetNormalizedScreenWidthByPercentage(_ screenWidthPercentage: CGFloat) -> CGFloat {
        return self.sceneSize.width * (screenWidthPercentage / self.aspectRatioX) * self.wideScreenCorrection
    }
    
    // Returns a % of the screen height that is scaled by the display's aspect ratio.
    open func GetNormalizedScreenHeightByPercentage(_ screenHeightPercentage: CGFloat) -> CGFloat {
        return self.sceneSize.height * (screenHeightPercentage / self.aspectRatioY) * self.wideScreenCorrection
    }
    
    // Returns a size that's scaled to the display's aspect ratio.
    open func GetSize(_ width: CGFloat, height: CGFloat) -> CGSize {
        return CGSize(width: width / self.aspectRatioX * wideScreenCorrection, height : height / self.aspectRatioY * wideScreenCorrection)
    }
    
    // Returns a size as a percentage of the screen, scaled to the display's aspect ratio.
    open func GetSizeByPercentageOfScene(_ widthPercent: CGFloat, heightPercent: CGFloat, considerAspectRatio : Bool) -> CGSize {
        if(considerAspectRatio) {
            return CGSize(width: widthPercent * self.sceneSize.width / self.aspectRatioX * wideScreenCorrection, height: heightPercent * self.sceneSize.height / self.aspectRatioY * wideScreenCorrection)
        } else {
            return CGSize(width: widthPercent * self.sceneSize.width, height: heightPercent * self.sceneSize.height)
        }
    }
    
    // Returns the location of the screen (right or left) depending on the x position passed into the function.
    open func GetTouchLocation(_ x : CGFloat) -> TOUCH_LOCATION {
        if (x <= 0) {
            return TOUCH_LOCATION.left
        } else {
            return TOUCH_LOCATION.right
        }
    }
    
    // Returns a point within a scene based on an ANCHOR
    open func GetSceneAnchor(_ node: SKSpriteNode, anchorTo: ANCHOR) -> CGPoint
    {
        return GetAnchor(node, parentSize: self.sceneSize, margin: emptyMargin, anchorTo: anchorTo)
    }
    
    // Returns a point within a scene based on an ANCHOR and margin.
    open func GetSceneAnchor(_ node: SKSpriteNode, margin: Margin, anchorTo: ANCHOR) -> CGPoint {
        return GetAnchor(node, parentSize: self.sceneSize, margin: margin, anchorTo: anchorTo)
    }
    
    // Returns a position relative to a sibling at the same level in the node tree, without a margin having to
    // be specified.
    open func GetSiblingAnchor(_ node: SKSpriteNode, sibling: SKSpriteNode, anchorTo: ANCHOR) -> CGPoint {
        return GetSiblingAnchor(node, sibling: sibling, margin: emptyMargin, anchorTo: anchorTo)
    }
    
    // Returns a position relative to a sibling at the same level in the node tree.
    open func GetSiblingAnchor(_ node: SKSpriteNode, sibling: SKSpriteNode, margin : Margin, anchorTo: ANCHOR) -> CGPoint {
        var x = CGFloat(0)
        var y = CGFloat(0)
        
        switch anchorTo {
        case ANCHOR.TOP_LEFT:
            x = CGFloat(sibling.position.x - (sibling.size.width / 2) - (node.size.width / 2))
            y = CGFloat(sibling.position.y + (sibling.size.height / 2) + (node.size.height / 2))
        case ANCHOR.CENTER_LEFT:
            x = CGFloat(sibling.position.x - (sibling.size.width / 2) - (node.size.width / 2))
            y = CGFloat(sibling.position.y)
        case ANCHOR.BOTTOM_LEFT:
            x = CGFloat(sibling.position.x - (sibling.size.width / 2) - (node.size.width / 2))
            y = CGFloat(sibling.position.y - (sibling.size.height / 2) - (node.size.height / 2))
        case ANCHOR.TOP_CENTER:
            x = CGFloat(sibling.position.x)
            y = CGFloat(sibling.position.y + (sibling.size.height / 2) + (node.size.height / 2))
        case ANCHOR.CENTER:
            x = CGFloat(sibling.position.x)
            y = CGFloat(sibling.position.y)
        case ANCHOR.BOTTOM_CENTER:
            x = CGFloat(sibling.position.x)
            y = CGFloat(sibling.position.y - (sibling.size.height / 2) - (node.size.height / 2))
        case ANCHOR.TOP_RIGHT:
            x = CGFloat(sibling.position.x + (sibling.size.width / 2) + (node.size.width / 2))
            y = CGFloat(sibling.position.y + (sibling.size.height / 2) + (node.size.height / 2))
        case ANCHOR.CENTER_RIGHT:
            x = CGFloat(sibling.position.x + (sibling.size.width / 2) + (node.size.width / 2))
            y = CGFloat(sibling.position.y)
        case ANCHOR.BOTTOM_RIGHT:
            x = CGFloat(sibling.position.x + (sibling.size.width / 2) + (node.size.width / 2))
            y = CGFloat(sibling.position.y - (sibling.size.height / 2) - (node.size.height / 2))
        }
        
        // Apply any margins.
        x += margin.MarginLeft * self.sceneSize.width / self.aspectRatioX * wideScreenCorrection
        x -= margin.MarginRight * self.sceneSize.width / self.aspectRatioX * wideScreenCorrection
        y += margin.MarginBottom * self.sceneSize.height / self.aspectRatioY * wideScreenCorrection
        y -= margin.MarginTop * self.sceneSize.height / self.aspectRatioY * wideScreenCorrection
        
        return CGPoint(x: x, y: y)
    }
    
    // Returns a position relative to a particular parent node based on the ANCHOR.
    open func GetParentAnchor(_ node: SKSpriteNode, parent : SKSpriteNode, anchorTo: ANCHOR) -> CGPoint {
        return GetAnchor(node, parentSize : parent.size, margin: emptyMargin, anchorTo : anchorTo)
    }
    
    // Returns a position relative to a particular parent node based on the ANCHOR and margin.
    open func GetParentAnchor(_ node: SKSpriteNode, parent: SKSpriteNode, margin: Margin, anchorTo: ANCHOR) -> CGPoint {
        return GetAnchor(node, parentSize : parent.size, margin: margin, anchorTo: anchorTo)
    }
    
    // All of the logic for obtaining a position based on a parents coordinate system (works for scene positions and
    // parent positions).
    fileprivate func GetAnchor(_ node: SKSpriteNode, parentSize: CGSize, margin : Margin, anchorTo: ANCHOR) -> CGPoint {
     
        var x = CGFloat(0)
        var y = CGFloat(0)
        
        switch anchorTo {
        case ANCHOR.TOP_LEFT:
            x = CGFloat((parentSize.width / 2 * -1) + (node.size.width / 2))
            y = CGFloat((parentSize.height / 2) - (node.size.height / 2))
        case ANCHOR.CENTER_LEFT:
            x = CGFloat((parentSize.width / 2 * -1) + (node.size.width / 2))
            y = CGFloat(0)
        case ANCHOR.BOTTOM_LEFT:
            x = CGFloat((parentSize.width / 2 * -1) + (node.size.width / 2))
            y = CGFloat((parentSize.height / 2 * -1) + (node.size.height / 2))
        case ANCHOR.TOP_CENTER:
            x = CGFloat(0)
            y = CGFloat((parentSize.height / 2) - (node.size.height / 2))
        case ANCHOR.CENTER:
            x = CGFloat(0)
            y = CGFloat(0)
        case ANCHOR.BOTTOM_CENTER:
            x = CGFloat(0)
            y = CGFloat((parentSize.height / 2 * -1) + (node.size.height / 2))
        case ANCHOR.TOP_RIGHT:
            x = CGFloat((parentSize.width / 2) - (node.size.width / 2))
            y = CGFloat((parentSize.height / 2) - (node.size.height / 2))
        case ANCHOR.CENTER_RIGHT:
            x = CGFloat((parentSize.width / 2) - (node.size.width / 2))
            y = CGFloat(0)
        case ANCHOR.BOTTOM_RIGHT:
            x = CGFloat((parentSize.width / 2) - (node.size.width / 2))
            y = CGFloat((parentSize.height / 2 * -1) + (node.size.height / 2))
        }
        
        // Apply margins (based on parent size)
        x += margin.MarginLeft * self.sceneSize.width / self.aspectRatioX * wideScreenCorrection
        x -= margin.MarginRight * self.sceneSize.width / self.aspectRatioX * wideScreenCorrection
        y += margin.MarginBottom * self.sceneSize.height / self.aspectRatioY * wideScreenCorrection
        y -= margin.MarginTop * self.sceneSize.height / self.aspectRatioY * wideScreenCorrection
        
        return CGPoint(x: x, y: y)
    }
}
