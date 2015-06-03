//
//  Block.swift
//  Swiftris
//
//  Created by Julicia on 5/28/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

import SpriteKit

//#1 Define how many colors are available in Swiftris: six
let NumberOfColors: UInt32 = 6

//#2 Declare the enumeration - it is of type Int and implements the Printable protocol apparently :P
enum BlockColor: Int, Printable {
    
//#3 Provide the complete list of enumerable options, one for each color, beginning with blue at 0 and ending at 5 with yellow
    case Blue = 0, Orange, Purple, Red, Teal, Yellow
    
//#4 This is a computed property, spriteName. A computed property is one that behaves like a typical variable, but when accessing it, a code block is invoked to generate its value each time.
    var spriteName: String {
        switch self {
        case .Blue:
            return "blue"
        case .Orange:
            return "orange"
        case .Purple:
            return "purple"
        case .Red:
            return "red"
        case .Teal:
            return "teal"
        case .Yellow:
            return "yellow"
        }
    }
    
//#5 Below we declare another computed property, description. This property is required if we are to adhere to the Printable protocol. Without it, our code will fail to compile. It simply returns the spriteName of the color which is more than enough to describe the object.
    var description: String {
        return self.spriteName
    }
    
//#6 Declare a static function named random(). This function returns a random choice among the colors found in BlockColor.
    static func random() -> BlockColor {
        return BlockColor(rawValue:Int(arc4random_uniform(NumberOfColors)))!
    }
    
    
}

// #1 Block is declared as a class which implements both the Printable and Hashable protocols
class Block: Hashable, Printable {

// #2 Define our color property as let, meaning once we assign it, it can no longer be re-assigned. A block should not be able to change colors mid-game unless you decide to make Swiftris: Epileptic Adventures :D
    // Constants
    let color: BlockColor
    
// #3 declare a column and row. These properties represent the location of the Block on our game board
    // Properties
    var column: Int
    var row: Int
    var sprite: SKSpriteNode?
    
// #4 provide a  shortcut for recovering the file name of the sprite to be used when displaying this Block. It effectively shortened our code from block.color.spriteName to block.spriteName
    var spriteName: String {
        return color.spriteName
    }
    
    // #5 implement the hashValue calculated property, which is required in order to support the Hashable protocol
    var hashValue: Int {
        return self.column ^ self.row
    }
    
    // #6 implement description as we must do in order to comply with the Printable protocol
    var description: String {
        return "\(color): [\(column), \(row)]"
    }
    
    init(column:Int, row:Int, color:BlockColor) {
        self.column = column
        self.row = row
        self.color = color
    }
}

// #7 create a custom operator- == - when comparing one Block with another. It returns true if and only if both Blocks are in the same location and of the same color. This operator is required in order to support the Hashable protocol.
func ==(lhs: Block, rhs: Block) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row && lhs.color.rawValue == rhs.color.rawValue
}
