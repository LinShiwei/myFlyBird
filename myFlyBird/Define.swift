//
//  Define.swift
//  myFlyBird
//
//  Created by Linsw on 16/1/27.
//  Copyright © 2016年 Linsw. All rights reserved.
//

import Foundation
import CoreGraphics

enum SceneChildName : String {
    case Bird = "bird"
    case TopPipe = "topPipe"
    case BottomPipe = "bottomPipe"
    case Background = "background"
    case Floor = "floor"
    case PipeLabel = "pipeLabel"
    case GameReady = "ready"
    case GameReadyNode = "readyNode"
    case GameOver = "gameOver"
    case GameOverNode = "gameOverNode"
    case ScoreLabel = "scoreLabel"
    case BestScoreLabel = "bestScoreLabel"

}
enum SceneZposition: CGFloat {
    case Background = 0
    
    case PipeLabel
    case TopPipe = 30
    case BottomPipe = 35
    case Floor
    case Bird = 40
    case TranslucentBackground
    
    case GameOver
    case GameReady
}