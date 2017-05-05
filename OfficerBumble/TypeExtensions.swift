//
//  Random.swift
//  OfficerBumble
//
//  Created by Ben Pierce on 2014-12-20.
//  Copyright (c) 2014 Benjamin Pierce. All rights reserved.
//

import Foundation
import SpriteKit

extension String
{
    static func occurances(_ string: String, toFind: String) -> Int {
        return string.components(separatedBy: toFind).count
    }
}

extension Int
{
    static func random(_ range: ClosedRange<Int> ) -> Int
    {
        let startIndex: UInt32 = UInt32(range.lowerBound)
        let endIndex: UInt32 = UInt32(range.upperBound)
        let uniform: UInt32 = UInt32(endIndex - startIndex + 1)
        
        let rand: Int = Int(startIndex + arc4random_uniform(uniform))

        return rand
    }
    
    static func GetNumericSuffix(_ num: Int) -> String {
        var result: String = ""
        let str = String(num)
        
        let lastNumber = str.characters.last!;
        
        if ( num >= 11 && num <= 19 ) {
            result = "th"
        } else {
            
            switch(lastNumber) {
            case "0":
                result = "th"
            case "1":
                result = "st"
            case "2":
                result = "nd"
            case "3":
                result = "rd"
            case "4":
                result = "th"
            case "5":
                result = "th"
            case "6":
                result = "th"
            case "7":
                result = "th"
            case "8":
                result = "th"
            case "9":
                result = "th"
            default:
                result = ""
            }
        }
        
        return result
    }
}

extension Double {
    static func random(_ min: Double = 0, max: Double) -> Double {
        let diff = max - min;
        let rand = Double(arc4random() % (UInt32(RAND_MAX) + 1))
        return ((rand / Double(RAND_MAX)) * diff) + min;
    }
}

extension CGFloat
{
    static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    static func random(_ min: CGFloat, _ max: CGFloat) -> CGFloat{
        return CGFloat.random() * (max - min) + min;
    }
}
