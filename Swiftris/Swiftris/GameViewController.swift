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

class GameViewController: UIViewController, SwiftrisDelegate, UIGestureRecognizerDelegate {


    var scene: GameScene! // :D
    var swiftris:Swiftris!
    var panPointReference:CGPoint?

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
    
    
    //This function below will be called if and when a tap is recognized
    @IBAction func didTap(sender: UITapGestureRecognizer) {
        swiftris.rotateShape()
    }
    
    @IBAction func didPan(sender: UIPanGestureRecognizer) {
    
        let currentPoint = sender.translationInView(self.view)
        if let originalPoint = panPointReference {
            
            if abs(currentPoint.x - originalPoint.x) > (BlockSize * 0.9) {
                
                if sender.velocityInView(self.view).x > CGFloat(0) {
                    swiftris.moveShapeRight()
                    panPointReference = currentPoint
                } else {
                    swiftris.moveShapeLeft()
                    panPointReference = currentPoint
                }
            }
        } else if sender.state == .Began {
            panPointReference = currentPoint
        }
    
    }
    
    
    @IBAction func didSwipe(sender: UISwipeGestureRecognizer) {
    swiftris.dropShape()
    
    }
    
    // GameViewController will implement an optional delegate method found in UIGestureRecognizerDelegate which will allow each gesture recognizer to work in tandem with the others. However, at times a gesture recognizer may collide with another.
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // Occasionally when swiping down, a pan gesture may occur simultaneously with a swipe gesture. In order for these recognizers to relinquish priority, we will implement another optional delegate method at #2. The code performs several optional cast conditionals. These if conditionals attempt to cast the generic UIGestureRecognizer parameters as the specific types of recognizers we expect to be notified of. If the cast succeeds, the code block is executed.
    

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let swipeRec = gestureRecognizer as? UISwipeGestureRecognizer {
            if let panRec = otherGestureRecognizer as? UIPanGestureRecognizer {
                return true
            }
        } else if let panRec = gestureRecognizer as? UIPanGestureRecognizer {
            if let tapRec = otherGestureRecognizer as? UITapGestureRecognizer {
                return true
            }
        }
        return false
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
      //#3 we stop the ticks, redraw the shape at its new location and then let it drop. This will in turn call back to GameViewController and report that the shape has landed.
        scene.stopTicking()
        scene.redrawShape(swiftris.fallingShape!) {
            swiftris.letShapeFall()
        }
        
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
