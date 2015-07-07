//
//  GameViewController.swift
//  Swiftris
//
//  Created by Julicia on 5/18/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

import UIKit
import SpriteKit

//GameBiewController handles user input and communicated between GameScene and a game logic class

class GameViewController: UIViewController, SwiftrisDelegate {


    var scene: GameScene! // :D
    var swiftris:Swiftris!

    override func viewDidLoad() {
        super.viewDidLoad()
    
        //Configure the view.
        let skView = view as! SKView
        skView.multipleTouchEnabled = false
        
        /*The as! operator is a forced downcast. The view object is of type SKView, but prior to downcasting, our code treated it like a basic UIView. Without downcasting, we are unable to access SKView methods and properties, such as presentScene(SKScene).*/
            
        
        //Create and configure the scene
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        
        //#1 Set a closure for the 'tick' property of 'GameScene.swift'. 
        //functions are simply named closures. We used a function named 'didTick()'
        scene.tick = didTick
        
        swiftris = Swiftris ()
        swiftris.delegate = self
        swiftris.beginGame()
        
        
        //Present the scene.
        skView.presentScene(scene)
        
        //#2 we add nextShape to the game layer at the preview location. When that animation completes, we reposition the underlying Shape object at the starting row and starting column before we ask GameScene to move it from the preview location to its starting position. Once THAT completes,, we ask Swiftris (hey girl!) for a new shape, begin ticking, and add the newly established upcoming piece to the previous area
/*        scene.addPreviewShapeToScene(swiftris.nextShape!) {
            self.swiftris.nextShape?.moveTo(StartingColumn, row: StartingRow)
            self.scene.movePreviewShape(self.swiftris.nextShape!) {
                let nextShapes = self.swiftris.newShape()
                self.scene.startTicking()
                self.scene.addPreviewShapeToScene(nextShapes.nextShape!) {}
            }
        } */
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    //#3 We dfine did Tick() here. didTick() lowers the falling shape by one row and then asks GameScene to redraw the shape at its enw location.
    func didTick() {
        swiftris.letShapeFall()
        
        //swiftris.fallingShape?.lowerShapeByOneRow()
        //scene.redrawShape(swiftris.fallingShape!, completion: {})
        
    }
    
    
    func nextShape() {
        let newShapes = swiftris.newShape()
        if let fallingShape = newShapes.fallingShape {
            self.scene.addPreviewShapeToScene(newShapes.nextShape!) {}
            self.scene.movePreviewShape(fallingShape) {
                // #2
                self.view.userInteractionEnabled = true
                self.scene.startTicking()
            }
        }
    }
    
    func gameDidBegin(swiftris: Swiftris) {
        // The following is false when restarting a new game
        if swiftris.nextShape != nil && swiftris.nextShape!.blocks[0].sprite == nil {
            scene.addPreviewShapeToScene(swiftris.nextShape!) {
                self.nextShape()
            }
        } else {
            nextShape()
        }
    }
    
    func gameDidEnd(swiftris: Swiftris) {
        view.userInteractionEnabled = false
        scene.stopTicking()
    }
    
    func gameDidLevelUp(swiftris: Swiftris) {
        
    }
    
    func gameShapeDidDrop(swiftris: Swiftris) {
        
    }
    
    func gameShapeDidLand(swiftris: Swiftris) {
        scene.stopTicking()
        nextShape()
    }
    
    // #3
    func gameShapeDidMove(swiftris: Swiftris) {
        scene.redrawShape(swiftris.fallingShape!) {}
    }
    
} //POSSIBLE DELETE THIS BRACKET.
