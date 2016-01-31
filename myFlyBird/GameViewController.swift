//
//  GameViewController.swift
//  myFlyBird
//
//  Created by Linsw on 16/1/27.
//  Copyright (c) 2016年 Linsw. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    @IBOutlet weak var pauseButton: UIButton!
    var isPause = false
    @IBAction func pause(sender: UIButton) {
        let skView = view as! SKView
        if isPause {
            self.isPause = false
            skView.paused = false
            self.pauseButton.setImage(UIImage(named: "Pause"), forState: UIControlState.Normal)
        }else{
            self.isPause = true
            skView.paused = true
            self.pauseButton.setImage(UIImage(named: "Play"), forState: UIControlState.Normal)

        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        let scene = GameScene(size: view.bounds.size)
        scene.scaleMode = SKSceneScaleMode.AspectFill
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
//        skView.allowsTransparency = true
        skView.presentScene(scene)
    }




    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
