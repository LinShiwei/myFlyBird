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
