/*
===============================================================================
Dynamically creates an SKLabelNode for each line of text.
===============================================================================
*/

import Foundation
import SpriteKit

open class MultiLineTextLabel {
    
    // Constructor Variables
    fileprivate let text: String                    // Label text
    fileprivate let name: String                    // Name of the text label
    fileprivate let parent: SKSpriteNode            // Text label's parent node
    fileprivate var width = CGFloat(0)              // Maximum width of the label
    fileprivate var font_width = CGFloat(0)         // The width of the font
    fileprivate var font_height = CGFloat(0)        // The height of the font
    fileprivate var top_padding = CGFloat(0)        // How much padding to leave at the top of the label
    fileprivate var bottom_padding = CGFloat(0)     // How much padding to leave at the bottom of the label
    
    // Calculated in Constructor
    fileprivate var characters_per_line = 0         // How many characters fit on a single line?
    fileprivate var labels: [SKLabelNode] = []      // Array of labels that will be displayed on top of each other.
    fileprivate var height = CGFloat(0)             // The dynamically calculated height of all labels + padding.
    
    public init(text: String, name: String, parent: SKSpriteNode, width: CGFloat, font_width: CGFloat, font_height: CGFloat, top_padding: CGFloat, bottom_padding: CGFloat) {
        self.text = text
        self.name = name
        self.parent = parent
        self.width = width
        self.font_width = font_width
        self.font_height = font_height
        self.top_padding = top_padding
        self.bottom_padding = bottom_padding
        
        self.characters_per_line = Int(width / (font_width / 1.8))  // The 1.8 is kind of a hack to get width to work.
        //self.characters_per_line = Int(width / (font_width ))
        
        Setup(text, name: name, parent: parent)
    }
    
    open func GetWidth() -> CGFloat {
        return self.width
    }
    
    open func GetHeight() -> CGFloat {
        return self.height
    }
    
    /*
    ===============================================================================
    Called when we're ready to show the all of the labels.
    ===============================================================================
    */
    open func Show() {
        let x : CGFloat = 0
        var y : CGFloat = 0
        var currentLine : Int = 0
        
        for label in labels {
            y = (self.parent.size.height / 2.0) - self.top_padding - (font_height) - (CGFloat(currentLine) * font_height)
            
            label.position = CGPoint(x: x, y: y)
            
            self.parent.addChild(label)
            
            currentLine = currentLine + 1
        }
    }
    
    // Do all of the heavy lifting to dynamically populate the labels array.
    fileprivate func Setup(_ text : String, name : String, parent : SKSpriteNode) {
        let separators = CharacterSet.whitespacesAndNewlines
        let words = text.components(separatedBy: separators)
        var currentLineString = ""
        
        // Loop through each word.
        for word in words {
            
            // If we're about to go over the line width.
            if ( currentLineString.characters.count + word.characters.count + 1 > self.characters_per_line ) {
                AddLabel(parent, text: currentLineString, name: name)
                currentLineString = ""
            }
            
            currentLineString = currentLineString + word + " "
        }
        
        // If we still have a line ready.
        if ( currentLineString.characters.count > 0 ) {
            AddLabel(parent, text: currentLineString, name: name)
        }
        
        // Figure out the total height of everything.
        for _ in labels {
           self.height = self.height + self.font_height
        }
        self.height = self.height + self.top_padding + self.bottom_padding
    }
    
    // Create a label and add it to the labels array.
    fileprivate func AddLabel(_ parent: SKSpriteNode, text: String, name: String) {
        let label = SKLabelNode()
        label.text = text
        label.zPosition = ZPOSITION.popup_UI.rawValue
        label.name = name
        label.horizontalAlignmentMode = .center
        label.fontSize = self.font_width
        label.fontName = "Arial"
        
        labels.append(label)
    }
}
