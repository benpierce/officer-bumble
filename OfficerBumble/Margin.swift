//
//  Margin.swift
//  OfficerBumble
//
//  Created by Ben Pierce on 2014-11-24.
//  Copyright (c) 2014 Benjamin Pierce. All rights reserved.
//

import Foundation
import SpriteKit

public struct Margin {
    public var MarginTop : CGFloat
    public var MarginBottom : CGFloat
    public var MarginLeft : CGFloat
    public var MarginRight : CGFloat
    
    public init(marginTop : CGFloat, marginBottom : CGFloat, marginLeft : CGFloat, marginRight : CGFloat) {
        self.MarginTop = marginTop
        self.MarginBottom = marginBottom
        self.MarginLeft = marginLeft
        self.MarginRight = marginRight
    }
}