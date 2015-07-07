//
//  GameScene.swift
//  Swiftris
//
//  Created by Julicia on 5/18/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

import SpriteKit

//GameScene is responsible for displaying everything for Switris: rendering the tetrominos on screen, the background, and the gameboard, playing sounds, keeping track of time


//#1 define the point size of each block sprite - which in this case is 20.0 X 20.0. The point size of each block sprite is the lower of the available resolution options for each block image. I also declare a layer position which will give an offset from the edge of the screen.
let BlockSize:CGFloat = 20.0

//#1 continued... We define a new constant, TickLengthLevelOne. This variable will represent the slowest speed at which our shapes will travel. It is set to 600 milliseconds, so at every 6/10ths of a second our shape will descend by one row
let TickLengthLevelOne = NSTimeInterval(600)

class GameScene: SKScene {

//#2 We defined a few variables below
   let gameLayer = SKNode()
    let shapeLayer = SKNode()
    let LayerPosition = CGPoint(x: 6, y: -6)
    
    
    var tick:(() -> ())? //tick is what's known as a closure in Swift. A closure is essentially a block of code that performs a function, and Swift refers to functions as closures
    var tickLengthMillis = TickLengthLevelOne
    var lastTick:NSDate?
    
  var textureCache = Dictionary<String, SKTexture>()
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */

//#3 Put our new member variables to work
    if lastTick == nil {
    return
    
    }
    
    var timePassed = lastTick!.timeIntervalSinceNow * -1000.0 //The ! is required if the object in question is an optional type.
    if timePassed > tickLengthMillis {
    lastTick = NSDate()
    tick?()
    
    }
    }
        //#4 We provide accessor methods to let external classes stop and start the ticking process, something we'll make use of later in order to keep pieces from falling at key moments
        func startTicking() {
            lastTick = NSDate()
        }
        
        func stopTicking() {
            lastTick = nil
        }
    //pointForColumn(Int, Int) is GameScene's most important function. This function returns the preceise coordinate on the screen for where a block sprite belongs base don its row and column position. Each sprite is anchored at its center, so we find the centercoordinate (in the bath below) before placing it in the shapeLAyer object
    func pointForColumn(column: Int, row: Int) -> CGPoint {
        let x: CGFloat = LayerPosition.x + (CGFloat(column) * BlockSize) + (BlockSize / 2)
        let y: CGFloat = LayerPosition.y - ((CGFloat(row) * BlockSize) + (BlockSize / 2))
        return CGPointMake(x, y)
    }
    
    func addPreviewShapeToScene(shape:Shape, completion:() -> ()) {
        for (idx, block) in enumerate(shape.blocks) {
            
            // create a method that will add share for the first time to the scene as a preview shape :) We use a dictionary to store copies of re-usable SKTexture objects since each shape will require multiple copies of the same image
            var texture = textureCache[block.spriteName]
            if texture == nil {
                texture = SKTexture(imageNamed: block.spriteName)
                textureCache[block.spriteName] = texture
            }
            let sprite = SKSpriteNode(texture: texture)
            
            
            // Use the pointForColumn(Int, Int) method to place each block's sprite in the proper location. We start it at row - 2, so that the preview piece animates smoothly into place from a higher location
            sprite.position = pointForColumn(block.column, row: block.row - 2)
            shapeLayer.addChild(sprite)
            block.sprite = sprite
            
            //Animation
            sprite.alpha = 0
            
            //Introduce SKAction objects, which are responsible for visually manipulating SKNode objects. Each block will fade and move into place as it appears as part of the next piece. It will move two rows down and fade from complete transparency to 70% opacity. This small design choice lets the player ignore the preview piece easily if they so choose since it will be duller than the active moving piece
            let moveAction = SKAction.moveTo(pointForColumn(block.column, row: block.row), duration: NSTimeInterval(0.2))
            moveAction.timingMode = .EaseOut
            let fadeInAction = SKAction.fadeAlphaTo(0.7, duration: 0.4)
            fadeInAction.timingMode = .EaseOut
            sprite.runAction(SKAction.group([moveAction, fadeInAction]))
            
        }
        
        runAction(SKAction.waitForDuration(0.4), completion: completion)
        
    }
    
    
    func movePreviewShape(shape:Shape, completion:() -> ()) {
        for (idx, block) in enumerate(shape.blocks) {
            let sprite = block.sprite!
            let moveTo = pointForColumn(block.column, row:block.row)
            let moveToAction:SKAction = SKAction.moveTo(moveTo, duration: 0.2)
            moveToAction.timingMode = .EaseOut
            sprite.runAction(
                SKAction.group([moveToAction, SKAction.fadeAlphaTo(1.0, duration: 0.2)]), completion:nil)
        }
        runAction(SKAction.waitForDuration(0.2), completion: completion)
    }
    
    func redrawShape(shape:Shape, completion:() -> ()) {
        for (idx, block) in enumerate(shape.blocks) {
            let sprite = block.sprite!
            let moveTo = pointForColumn(block.column, row:block.row)
            let moveToAction:SKAction = SKAction.moveTo(moveTo, duration: 0.05)
            moveToAction.timingMode = .EaseOut
            sprite.runAction(moveToAction, completion: nil)
        }
        runAction(SKAction.waitForDuration(0.05), completion: completion)
    }
    

    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoder not supported")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0, y: 1.0)
        
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 0, y:0)
        background.anchorPoint = CGPoint(x: 0, y: 1.0)
        addChild(background)

        addChild(gameLayer)
        
        let gameBoardTexture = SKTexture(imageNamed: "gameboard")
        let gameBoard = SKSpriteNode(texture: gameBoardTexture, size: CGSizeMake(BlockSize * CGFloat(NumColumns), BlockSize * CGFloat(NumRows)))
        gameBoard.anchorPoint = CGPoint(x:0, y:1.0)
        gameBoard.position = LayerPosition
        
        shapeLayer.position = LayerPosition
        shapeLayer.addChild(gameBoard)
        gameLayer.addChild(shapeLayer)
        
    }

}

