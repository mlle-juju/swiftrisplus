//
//  Shape.swift
//  Swiftris
//
//  Created by Julicia on 5/28/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

import SpriteKit

let NumOrientations: UInt32 = 4

enum Orientation: Int, Printable {
    case Zero = 0, Ninety, OneEighty, TwoSeventy
    
    var description: String {
        switch self {
        case .Zero:
            return "0"
        case .Ninety:
            return "90"
        case .OneEighty:
            return "180"
        case .TwoSeventy:
            return "270"
        }
    }
    
    static func random() -> Orientation {
        return Orientation(rawValue:Int(arc4random_uniform(NumOrientations)))!
    }
    
    // #1
    static func rotate(orientation:Orientation, clockwise: Bool) -> Orientation {
        var rotated = orientation.rawValue + (clockwise ? 1 : -1)
        if rotated > Orientation.TwoSeventy.rawValue {
            rotated = Orientation.Zero.rawValue
        } else if rotated < 0 {
            rotated = Orientation.TwoSeventy.rawValue
        }
        return Orientation(rawValue:rotated)!
    }
}

    //The number of total shape varieties
    let NumShapeTypes: UInt32 = 7
    
    //Shape indexes
    let FirstBlockIdx: Int = 0
    let SecondBlockIdx: Int = 1
    let ThirdBlockIdx: Int = 2
    let FourthBlockIdx: Int = 3

    
    class Shape: Hashable, Printable {
        //The color of the shape
        let color:BlockColor
        
        //The blocks comprising the shape
        var blocks = Array<Block>()
        
        //current orientation of the shape
        var orientation: Orientation
        
        //the column and row representing the shape's anchor point
        var column, row:Int

        //required overides
        //#1 - Introduce Swift tools
        //subclasses must override this property
        //blockRowColumnPositions defines a computed Dictionary. A dictionary is defined with square braces – […] – and maps one type of object to another
        var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>] {
            return [:]
        }
        
        //#2
        //Subclasses must override this property
        var bottomBlocksForOrientations: [Orientation: Array<Block>] {
            return [:]
        }
        
        //#3 Here, we write a complete computed property which is designed to return the bottom blocks of the shape at its current orientation. This will be useful later when our blocks get physical and start contacting walls and each other.
        var bottomBlocks:Array<Block> {
            if let bottomblocks = bottomBlocksForOrientations[orientation] {
                return bottomBlocks
                
            }
            return []
            
        }
        
      //Hashable
            var hashValue:Int {
                //#4  iterate through our entire blocks array. We exclusively-or each block's hashValue together to create a single hashValue for the Shape they comprise.
                return reduce(blocks, 0) { $0.hashValue ^ $1.hashValue }
            }
            
            //Printable
            var description:String {
                return "\(color) block facing \(orientation): \(blocks[FirstBlockIdx]), \(blocks[SecondBlockIdx]), \(blocks[ThirdBlockIdx]), \(blocks[FourthBlockIdx])"

            }
        
            init(column:Int, row:Int, color: BlockColor, orientation:Orientation) {
                self.color = color
                self.column = column
                self.row = row
                self.orientation = orientation
                initializeBlocks()
                
            }
            
            // #5 - write a convenience initializer. convenience initializer must call down to a standard initializer or otherwise your class will fail to compile.
            convenience init(column:Int, row:Int) {
                self.init(column:column, row:row, color:BlockColor.random(), orientation:Orientation.random())
            }
            
        
        
        
        
            // #1
            final func initializeBlocks() {
                // #2
                if let blockRowColumnTranslations = blockRowColumnPositions[orientation] {
                    for i in 0..<blockRowColumnTranslations.count {
                        let blockRow = row + blockRowColumnTranslations[i].rowDiff
                        let blockColumn = column + blockRowColumnTranslations[i].columnDiff
                        let newBlock = Block(column: blockColumn, row: blockRow, color: color)
                        blocks.append(newBlock)
                    }
                }
            }
        
        }
        
        func ==(lhs: Shape, rhs: Shape) -> Bool {
        return lhs.row == rhs.row && lhs.column == rhs.column
        }
        



    



        