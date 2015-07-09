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

    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    
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
        //when the game begins, we reset the score and level labels as well as the speed at which the ticks occur, beginning with TickLengthLevelOne
        
            levelLabel.text = "\(swiftris.level)"
            scoreLabel.text = "\(swiftris.score)"
            scene.tickLengthMillis = TickLengthLevelOne
        
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
        
        //after the game ends, we'll play the GAME OVER sound. then we destrooooy the remaining blocks on screen before starting a brand new game w/o delay.
        //       scene.playSound("gameover.mp3")
        scene.animateCollapsingLines(swiftris.removeAllBlocks(), fallenBlocks: Array<Array<Block>>()) {
            swiftris.beginGame()
        }
        
        
    }
    
    func gameDidLevelUp(swiftris: Swiftris) {
        //whoop whoop! you're onto the next level
        //each time the player levels up, we decrease the tick interval. at first, each level decreases by 100 milliseconds, but as it progresses it will go even faster, ultimately topping off at 50 milliseconds between ticks.
        //we play a congratulatory level-up sound as a reward (lol...)
        levelLabel.text = "\(swiftris.level)"
        if scene.tickLengthMillis >= 100 {
            scene.tickLengthMillis -= 100
            
        } else if scene.tickLengthMillis > 50 {
            scene.tickLengthMillis -= 50
        }
        //       scene.playSound("levelup.mp3")
        
        
    }
    
    func gameShapeDidDrop(swiftris: Swiftris) {
      //#3 we stop the ticks, redraw the shape at its new location and then let it drop. This will in turn call back to GameViewController and report that the shape has landed.
        scene.stopTicking()
        scene.redrawShape(swiftris.fallingShape!) {
            swiftris.letShapeFall()
        }
        //        scene.playSound("drop.mp3")
        
    }
    
    func gameShapeDidLand(swiftris: Swiftris) {
        scene.stopTicking()
        //nextShape()
        self.view.userInteractionEnabled = false
        
        
        //invoke 'removeCompletedLines' to recover the two arrays from Swiftris. if any lines have been removed at all, we update the score label to represent the newest score and then animate the blocks with our explosive new animation function
        let removedLines = swiftris.removeCompletedLines()
        if removedLines.linesRemoved.count > 0 {
            self.scoreLabel.text = "\(swiftris.score)"
            scene.animateCollapsingLines(removedLines.linesRemoved, fallenBlocks:removedLines.fallenBlocks) {
                
         //we perform a recursive call here. a recursive function invokes itself. in the Swiftris game's case, after the blocks have fallen to their new location, they may have formed brand new lines. SO after the first set of lines are removed, we invoke gameShapeDidLand(Swiftris) again in order to detect any such new lines. if none are found, the next shape is brought in
                self.gameShapeDidLand(swiftris)
        }
            //            scene.playSound("bomb.mp3")
        } else {
            nextShape()
        }
        
    }
    
    // #3
    func gameShapeDidMove(swiftris: Swiftris) {
        scene.redrawShape(swiftris.fallingShape!) {}
    }
  
    
    
}
