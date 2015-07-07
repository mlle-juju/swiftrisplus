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
            if let bottomblocksVariable = bottomBlocksForOrientations[orientation] {
                return bottomblocksVariable
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
        
        final func rotateBlocks(orientation: Orientation) {
            if let blockRowColumnTranslation:Array<(columnDiff: Int, rowDiff: Int)> = blockRowColumnPositions[orientation] {
                
                //#1 introduce the enumerate operator, which allows us to iterate through an array object by defining the index cariable idx and the contents at that index.
                for (idx, diff) in enumerate(blockRowColumnTranslation) {
                    blocks[idx].column = column + diff.columnDiff
                    blocks[idx].row = row + diff.rowDiff
                }
            }
        }
        
        final func rotateClockwise() {
            let newOrientation = Orientation.rotate(orientation, clockwise: true)
            rotateBlocks(newOrientation)
            orientation = newOrientation
        }
        
        final func rotateCounterClockwise() {
            let newOrientation = Orientation.rotate(orientation, clockwise: false)
            rotateBlocks(newOrientation)
            orientation = newOrientation
        }
        
        
        final func lowerShapeByOneRow() {
            shiftBy(0, rows:1)
        }
        
        final func raiseShapeByOneRow() {
            shiftBy(0, rows:-1)
        }
        
        final func shiftRightByOneColumn() {
            shiftBy(1, rows:0)
        }
        
        final func shiftLeftByOneColumn() {
            shiftBy(-1, rows:0)
        }
        
        //#2 this method --> shiftBy(columns: Int, rows: Int) will adjust each row and column
        final func shiftBy(columns: Int, rows: Int) {
            self.column += columns
            self.row += rows
            for block in blocks {
                block.column += columns
                block.row += rows
            }
        }
        
        
        //#3 "we provide an absolute approach to position modification by setting the column and row properties before rotating the blocks to their current orientation which causes an accurate realignment of all blocks relative to the new row and column properties."
        final func moveTo(column: Int, row:Int) {
            self.column = column
            self.row = row
            rotateBlocks(orientation)
        }
        
        final class func random(startingColumn:Int, startingRow:Int) -> Shape {
            switch Int(arc4random_uniform(NumShapeTypes)) {
        
        // #4 we create a method to generate a random Tetromino shape. Subclasses naturally inherit initializers from their parent class
                
            case 0:
                return SquareShape(column:startingColumn, row:startingRow)
            case 1:
                return LineShape(column:startingColumn, row:startingRow)
            case 3:
                return LShape(column:startingColumn, row:startingRow)
            case 4:
                return JShape(column:startingColumn, row:startingRow)
            case 5:
                return SShape(column:startingColumn, row:startingRow)
            default:
                return ZShape(column:startingColumn, row:startingRow)
            }
        }
        
        
        }
        
        func ==(lhs: Shape, rhs: Shape) -> Bool {
        return lhs.row == rhs.row && lhs.column == rhs.column
        }
        



    



        