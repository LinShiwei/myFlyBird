//
//  GameOverScene.swift
//  myFlyBird
//
//  Created by Linsw on 16/1/27.
//  Copyright © 2016年 Linsw. All rights reserved.
//

import UIKit
import SpriteKit
class GameOverScene: SKScene {
    init(size: CGSize, won:Bool) {
        
        super.init(size: size)
        // 1
        backgroundColor = SKColor(white: 1, alpha: 0)       // 2
        let message = won ? "You Won!" : "You Lose :["
        
        // 3
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.blackColor()
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
        
        // 4
        runAction(SKAction.sequence([
            SKAction.waitForDuration(1.0),
            SKAction.runBlock() {
                // 5
                let reveal = SKTransition.fadeWithDuration(0.5)
                let scene = GameScene(size: size)
                self.view!.presentScene(scene, transition:reveal)
            }
            ]))
        
    }
    
    // 6
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
