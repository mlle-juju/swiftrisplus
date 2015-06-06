//
//  GameScene.swift
//  Swiftris
//
//  Created by Julicia on 5/18/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

import SpriteKit

//GameScene is responsible for displaying everything for Switris: rendering the tetrominos on screen, the background, and the gameboard, playing sounds, keeping track of time

//#1 We define a new constant, TickLengthLevelOne. This variable will represent the slowest speed at which our shapes will travel. It is set to 600 milliseconds, so at every 6/10ths of a second our shape will descend by one row
let TickLengthLevelOne = NSTimeInterval(600)

class GameScene: SKScene {

//#2 We defined a few variables below
    var tick:(() -> ())? //tick is what's known as a closure in Swift. A closure is essentially a block of code that performs a function, and Swift refers to functions as closures
    var tickLengthMillis = TickLengthLevelOne
    var lastTick:NSDate?
    
  
    
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
        
    }

}

