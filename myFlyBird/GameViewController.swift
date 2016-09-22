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
    var isPause = false

    @IBOutlet weak var pauseButton: UIButton!
    @IBAction func pause(_ sender: UIButton) {
        let skView = view as! SKView
        if isPause {
            self.isPause = false
            skView.isPaused = false
            self.pauseButton.setImage(UIImage(named: "Pause"), for: UIControlState())
        }else{
            self.isPause = true
            skView.isPaused = true
            self.pauseButton.setImage(UIImage(named: "Play"), for: UIControlState())

        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        let scene = GameScene(size: view.bounds.size)
        scene.scaleMode = SKSceneScaleMode.aspectFill
        let skView = view as! SKView
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }




    override var prefersStatusBarHidden : Bool {
        return true
    }
}
