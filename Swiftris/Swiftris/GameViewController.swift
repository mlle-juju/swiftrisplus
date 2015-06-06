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

class GameViewController: UIViewController {

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    var scene: GameScene! // :D

    override func viewDidLoad() {
        super.viewDidLoad()
    
        //Configure the view.
        let skView = view as! SKView
        skView.multipleTouchEnabled = false
        
        /*The as! operator is a forced downcast. The view object is of type SKView, but prior to downcasting, our code treated it like a basic UIView. Without downcasting, we are unable to access SKView methods and properties, such as presentScene(SKScene).*/
            
        
        //Create and configure the scene
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        
        //Present the scene.
        skView.presentScene(scene)
        
     
    
    }
}
