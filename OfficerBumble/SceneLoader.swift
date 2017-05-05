//
//  SceneLoader.swift
//  OfficerBumble
//
//  Created by Ben Pierce on 2014-11-24.
//  Copyright (c) 2014 Benjamin Pierce. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

// Loads a scene definition from XML
open class SceneLoader : NSObject, XMLParserDelegate {

    // Needed for positioning
    var display : Display!
    let emptyMargin = Margin(marginTop : 0, marginBottom : 0, marginLeft : 0, marginRight : 0)
    
    // Hierarchy tracking
    var parentStack : Stack<SKSpriteNode>     // Tracks the parent of each level.
    var siblingStack : Stack<SKSpriteNode>    // Tracks the last sibling of each level.
    var isClosed : Bool = true

    // Hierarchy tracking data.
    var scene : SKScene?
    var world : SKSpriteNode?
    var hud : SKSpriteNode?
    var currentElement : String = ""
    var currentParent : SKSpriteNode? = nil
    var currentSibling : SKSpriteNode? = nil
    var current : SKSpriteNode? = nil
    
    // Scene specific variables
    var name : String = ""
    var textureAtlas : String = ""
    var tag : String = ""
    var tagOn : String = ""
    var height : CGFloat = 0.0
    var width : CGFloat = 0.0
    var anchor : String = ""
    var ignoreaspect : String = ""
    var marginbottom : String = ""
    var margintop : String = ""
    var marginleft : String = ""
    var marginright : String = ""
    var zposition : String = ""
    var type : String = ""
    var hudElement : String = ""
    var loadInverse : String = ""
    
    // Scene specific text variables for those that are numeric.
    var heightStr : String = ""
    var widthStr : String = ""
    
    public override init() {
        parentStack = Stack<SKSpriteNode>()
        siblingStack = Stack<SKSpriteNode>()
        isClosed = true
        
        super.init()
    }
    
    open func Initialize(_ _display : Display, _scene : SKScene, resourceName : String) {
        let filepath = Bundle.main.path(forResource: resourceName, ofType: "xml")
        var content = ""
        
        do {
            content = try String(contentsOfFile:filepath!, encoding:String.Encoding.utf8)
        } catch {
            print("error loading file " + resourceName)
        }
            
        let data = prepareXMLData(content)

        // Setup the scene.
        self.scene = _scene
        self.scene!.name = resourceName

        // Every scene has a world for scrolling.
        world = SKSpriteNode()
        world!.name = "World"
        scene!.addChild(world!)
        
        // Every scene also has a HUD for non-scrolling.
        hud = SKSpriteNode()
        hud!.size = CGSize(width: _scene.size.width, height: _scene.size.height)
        hud!.name = "HUD"
        scene!.addChild(hud!)
        
        display = _display
        isClosed = true
        
        let parser = XMLParser(data: data) as XMLParser
        parser.delegate = self
        _ = parser.parse()
        
        ResizeWorld()
    }
    
    fileprivate func ResizeWorld() {
        var minX = CGFloat.greatestFiniteMagnitude, maxX = CGFloat.leastNormalMagnitude
        var minY = CGFloat.greatestFiniteMagnitude, maxY = CGFloat.leastNormalMagnitude
        
        // Loop through every child node of the world and determine the maximum size we need it to be.
        for node in world!.children {
            if ( node.position.x - node.frame.size.width / 2 < minX ) {
                minX = node.position.x - node.frame.size.width / 2
            }
            if ( node.position.x + node.frame.size.width / 2 > maxX ) {
                maxX = node.position.x + node.frame.size.width / 2
            }
            if ( node.position.y - node.frame.size.height / 2 < minY ) {
                minY = node.position.y - node.frame.size.height / 2
            }
            if ( node.position.y + node.frame.size.height / 2 > maxY ) {
                maxY = node.position.y + node.frame.size.height / 2
            }
        }
        
        world!.size = CGSize(width: maxX - minX, height: maxY - minY)
    }
    
    open func parserDidStartDocument(_ parser : XMLParser) {
        //println("Starting parse document")
    }
    
    open func parserDidEndDocument(_ parser: XMLParser) {
        //println("End parse document")
    }
    
    fileprivate func GetTextureAtlas(_ name: String) -> SKTextureAtlas {
        var atlas : SKTextureAtlas?

        switch(name) {
        case "criminal1":
            atlas = textureManager.taCriminal1
        case "criminal2":
            atlas = textureManager.taCriminal2
        case "bumble1":
            atlas = textureManager.taBumble1
        case "bumble2":
            atlas = textureManager.taBumble2
        case "tools":
            atlas = textureManager.taTools
        case "tools2":
            atlas = textureManager.taTools2
        case "tornado":
            atlas = textureManager.taTornado
        case "levelcommon":
            atlas = textureManager.taLevelCommon
        case "shoppingmall":
            atlas = textureManager.taShoppingMall
        case "bank":
            atlas = textureManager.taBank
        case "museum":
            atlas = textureManager.taMuseum
        case "casino":
            atlas = textureManager.taCasino
        default:
            atlas = SKTextureAtlas(named: name)
        }
        
        return atlas!
    }
    
    open func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        if(elementName == "SceneItem") {
            // Determine if we're in a nested element.
            if(!isClosed) {
                // Create the current node.
                CreateNode()
                
                // Push the current parent node to the parent stack for future use.
                parentStack.push(currentParent)
                currentParent = current
                
                // Push the current sibling to the sibling stack for future use.
                siblingStack.push(current)
                currentSibling = nil
            }
            
            isClosed = false    // Starting a new element, so not closed anymore.
            ResetProperties()   // Always reset the properties.
        } else {
            // We're probably on a property.
            currentElement = elementName
        }
    }
    
    // Creates a node based on all of the data that has been collected about that node so far.
    fileprivate func CreateNode() {
        var node : SKSpriteNode!    // initialize to nil
        var atlas : SKTextureAtlas?
        var placeInHUD : Bool = false
        
        // Get texture atlas if one exists for this node.
        if ( textureAtlas != "" ) {
            atlas = GetTextureAtlas(textureAtlas)   // Avoid overhead of reloading them.
        }
        
        // Height and width %'s are always based on the entire screen, not necessarily the parent.
        height = getPercentage(heightStr)
        width = getPercentage(widthStr)
        
        // If this is a full screen item and we're in 4:3 resolution, we need to make sure we use the right one.
        if ( height == 1 && width == 1 && display.Is43() ) {
            tag = tag + "43"
        }
        
        switch(type) {
            case "TREADMILL":
                node = Treadmill()
            case "BUMBLE":
                node = Bumble(display: display!)
            case "CRIMINAL":
                node = Criminal(display: display!)
            case "ESCALATOR":
                node = Escalator()
            case "ROBOTHROWER2000":
                node = Robothrower2000(display: display!)
            case "BUTTON":
                if ( atlas != nil ) {
                    let button = GameButton(texture: atlas!.textureNamed(tag), texturePressed: atlas!.textureNamed(tagOn))
                                        
                    node = button
                }
                // Button better have a texture atlas!
            case "EXIT":
                if ( atlas != nil ) {
                    node = Exit(texture: atlas!.textureNamed(tag))
                }
            default:
                if ( atlas != nil ) {
                    node = SKSpriteNode(texture: atlas!.textureNamed(tag))
                } else {
                    node = SKSpriteNode(imageNamed: tag)
                }
        }
        
        node.name = name
        
        // Setup margin
        var fmargintop = CGFloat(0)
        var fmarginbottom = CGFloat(0)
        var fmarginleft = CGFloat(0)
        var fmarginright = CGFloat(0)
        
        if(margintop != "") {
            fmargintop = getPercentage(margintop)
        }
        if(marginbottom != "") {
            fmarginbottom = getPercentage(marginbottom)
        }
        if(marginleft != "") {
            fmarginleft = getPercentage(marginleft)
        }
        if(marginright != "") {
            fmarginright = getPercentage(marginright)
        }

        let margin = Margin(marginTop : fmargintop, marginBottom : fmarginbottom, marginLeft : fmarginleft, marginRight : fmarginright)
        
        if (ignoreaspect.uppercased() == "TRUE") {
            node.size = display.GetSizeByPercentageOfScene(width, heightPercent: height, considerAspectRatio : false)
        } else {
            node.size = display.GetSizeByPercentageOfScene(width, heightPercent: height, considerAspectRatio : true)
        }
        
        if ( hudElement.uppercased() == "TRUE" ) {
            placeInHUD = true
        }
        
        // Set the position
        if (anchor.hasPrefix("SIBLING")) {
            // We're dealing with sibling related positioning, so we can base our position on that.
            let anchorString = anchor.substring(from: anchor.index(anchor.startIndex, offsetBy: 8))
            let anchorEnum = Display.ANCHOR(rawValue: anchorString)
            
            node.position = display.GetSiblingAnchor(node, sibling : currentSibling!, margin : margin, anchorTo : anchorEnum! )
        } else {
            // We're either dealing with scene or parent level positioning.
            let anchorEnum = Display.ANCHOR(rawValue: anchor)
            
            if(currentParent == nil) {
                node.position = display.GetSceneAnchor(node, margin : margin, anchorTo : anchorEnum!)
            } else {
                node.position = display.GetParentAnchor(node, parent : currentParent!, margin : margin, anchorTo : anchorEnum!)
            }
        }
        
        if (zposition != "") {
            node.zPosition = ZPOSITION.GetByName(zposition).rawValue
        } else {
            node.zPosition = ZPOSITION.normal.rawValue
        }
        
        // If escalator, we need to initialize it after the size has been set.
        if ( type == "ESCALATOR" ) {
            let escalator = node as! Escalator
            escalator.Initialize()
        }
        
        // If exit, we need to initialize it after the size has been set.
        if ( type == "EXIT" ) {
            let exit = node as! Exit
            exit.Initialize()
        }
        
        if ( loadInverse.uppercased() == "TRUE" ) {
            node.xScale = -1
        }
        
        // Either add to the parent or to the scene directly.
        if ( placeInHUD ) {
            hud!.addChild(node)
        } else if(currentParent != nil) {
            currentParent!.addChild(node)
        } else {
            world!.addChild(node)
        }
        
        current = node
    }
    
    fileprivate func ResetProperties() {
        name = ""
        textureAtlas = ""
        tag = ""
        tagOn = ""
        height = CGFloat(0)
        width = CGFloat(0)
        heightStr = ""
        widthStr = ""
        anchor = ""
        ignoreaspect = ""
        margintop = ""
        marginbottom = ""
        marginleft = ""
        marginright = ""
        zposition = ""
        type = ""
        hudElement = ""
        loadInverse = ""
    }
    
    open func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?,
                     qualifiedName qName: String?){
        
        if(elementName == "SceneItem") {
            if(isClosed) {
                // Now restore the stack.
                currentParent = parentStack.pop()
                currentSibling = siblingStack.pop()
            } else {
                // We're closing a sub-node so we need to save it.
                CreateNode()
                
                currentSibling = current    // Set the sibling as the current element.
                isClosed = true   // Mark as processed
            }
        }
    }
    
    open func parser(_ parser: XMLParser, foundCharacters characters: String){
        
        let formatted = characters.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        // Reads one character at a time :S
        if (currentElement == "name") {
            name = name + formatted
        } else if (currentElement == "texture") {
            textureAtlas = textureAtlas + formatted
        } else if (currentElement == "tag") {
            tag = tag + formatted
        } else if (currentElement == "tag-on") {
            tagOn = tagOn + formatted
        }else if (currentElement == "height") {
            heightStr = heightStr + formatted
        } else if (currentElement == "width") {
            widthStr = widthStr + formatted
        } else if (currentElement == "anchor") {
            anchor = anchor + formatted
        } else if (currentElement == "ignoreaspect") {
            ignoreaspect = ignoreaspect + formatted
        } else if (currentElement == "margin-top") {
            margintop = margintop + formatted
        } else if (currentElement == "margin-bottom") {
            marginbottom = marginbottom + formatted
        } else if (currentElement == "margin-left") {
            marginleft = marginleft + formatted
        } else if (currentElement == "margin-right") {
            marginright = marginright + formatted
        } else if (currentElement == "zposition") {
            zposition = zposition + formatted
        } else if (currentElement == "type") {
            type = type + formatted
        } else if (currentElement == "hud-element") {
            hudElement = hudElement + formatted
        } else if (currentElement == "loadinverse") {
            loadInverse = loadInverse + formatted
        }
    }
    
    fileprivate func prepareXMLData(_ data : String) -> Data {
        return data.data(using: String.Encoding.utf8)!
    }
    
    fileprivate func getPercentage(_ data : String) -> CGFloat {
        let myNewString = Array(data.characters).reduce("") { $0 + (String($1) == "%" ? "" : String($1)) }
        let numberFromString = (myNewString as NSString).doubleValue
        
        let divided = numberFromString / 100.0
        return CGFloat(divided)
    }
    
    fileprivate func ConvertToCGFloat(_ data : String) -> CGFloat {
        let numberFromString = (data as NSString).doubleValue
        return CGFloat(numberFromString)
    }
    
    open func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error)
    {
        print("failure error: %@", parseError)
    }
}
