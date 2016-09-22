//
//  GameScene.swift
//  myFlyBird
//
//  Created by Linsw on 16/1/27.
//  Copyright (c) 2016年 Linsw. All rights reserved.
//

import SpriteKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Bird      : UInt32 = 0b1       // 1
    static let Pipe      : UInt32 = 0b10      // 2
    static let Floor     : UInt32 = 0b11
    static let Sensor    : UInt32 = 0b1000
}

class GameScene: SKScene,SKPhysicsContactDelegate {

    var gameOver = false
    let gapLocationY :CGFloat = 150
    let scrollVelocity:CGFloat = 120//120px per second
    var birdOriginPosition :CGPoint{
        return CGPoint(x: size.width*0.4,y: size.height*0.5)
    }
    
    //MARK: View
    override func didMove(to view: SKView) {
        
        backgroundColor = SKColor.black
        physicsWorld.contactDelegate = self
        start()
    }
    override func update(_ currentTime: TimeInterval) {
        if let bird = childNode(withName: SceneChildName.Bird.rawValue){
            bird.zRotation = 3.14 * bird.physicsBody!.velocity.dy * 0.0006
        }
    }
    //MARK: touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       /* Called when a touch begins */
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            let node = self.atPoint(location)
            if node.name == SceneChildName.GameReady.rawValue || node.name == SceneChildName.GameReadyNode.rawValue{
                gameOver = false
                if let gameReadyNode = childNode(withName: SceneChildName.GameReadyNode.rawValue){
                    gameReadyNode.isHidden = true
                }
                let bird = childNode(withName: SceneChildName.Bird.rawValue)
                bird?.physicsBody?.isDynamic = true
                let pipe = childNode(withName: SceneChildName.PipeLabel.rawValue) as! SKLabelNode
                pipe.run(SKAction.repeatForever(SKAction.sequence([
                    SKAction.run{
                    self.addPipe()
                    },
                    SKAction.wait(forDuration: TimeInterval(2))
                    ])
                    ), withKey: "AddPipe")
            }else{
                if gameOver {
                    start()
                }else{
                    let bird = childNode(withName: SceneChildName.Bird.rawValue) as! SKSpriteNode
                    bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 40))
                }
            }
        }
    }
    //MARK: Contact
    func didBegin(_ contact: SKPhysicsContact) {
        if gameOver {
            return
        }else{
            var firstBody: SKPhysicsBody
            var secondBody: SKPhysicsBody
            if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
                firstBody = contact.bodyA
                secondBody = contact.bodyB
            } else {
                firstBody = contact.bodyB
                secondBody = contact.bodyA
            }
            
            if (firstBody.categoryBitMask & PhysicsCategory.Bird != 0) {
                if ((secondBody.categoryBitMask & PhysicsCategory.Pipe != 0)||(secondBody.categoryBitMask & PhysicsCategory.Floor != 0)){
                    birdDidCollideWithPipe(firstBody.node as! SKSpriteNode, pipe: secondBody.node as! SKSpriteNode)
                }else{
                    if (secondBody.categoryBitMask & PhysicsCategory.Sensor != 0){
                        birdDidPassGap(firstBody.node as! SKSpriteNode, sensor: secondBody.node as! SKSpriteNode)
                    }
                }
            }
        }
    }
    func birdDidCollideWithPipe(_ bird:SKSpriteNode,pipe:SKSpriteNode) {
        gameOver = true
        refreshBestScoreAndPresentMedalPlate()
        removeAllChildrenAction()
    }
    func birdDidPassGap(_ bird:SKSpriteNode,sensor:SKSpriteNode){
        sensor.removeFromParent()
        let pipeLabel = childNode(withName: SceneChildName.PipeLabel.rawValue) as! SKLabelNode
        pipeLabel.text = String(Int(pipeLabel.text!)!+1)
    }
   //MARK: Load
    func loadBird(){
        if let node = childNode(withName: SceneChildName.Bird.rawValue) as! SKSpriteNode?{
            node.position = CGPoint(x: size.width/2,y: size.height/2)
        }else {
            let birdTexture1 = SKTexture(imageNamed: "Bird_1")
            birdTexture1.filteringMode = SKTextureFilteringMode.nearest
            let birdTexture2 = SKTexture(imageNamed: "Bird_2")
            birdTexture2.filteringMode = SKTextureFilteringMode.nearest
            let birdTexture3 = SKTexture(imageNamed: "Bird_3")
            birdTexture3.filteringMode = SKTextureFilteringMode.nearest
            let texture = [birdTexture1,birdTexture2,birdTexture3]
            let bird = SKSpriteNode(texture: birdTexture1)
            let flap = SKAction.animate(with: texture, timePerFrame: 0.2, resize: true, restore: true)
            bird.run(SKAction.repeatForever(flap), withKey: "flapForever")
            bird.position = birdOriginPosition
            bird.zPosition = SceneZposition.bird.rawValue
            bird.name = SceneChildName.Bird.rawValue
            bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.width/2) // 1
            bird.physicsBody?.isDynamic = false // 2
            bird.physicsBody?.categoryBitMask = PhysicsCategory.Bird // 3
            bird.physicsBody?.contactTestBitMask = PhysicsCategory.Pipe | PhysicsCategory.Floor | PhysicsCategory.Sensor  // 4
            bird.physicsBody?.collisionBitMask = PhysicsCategory.Pipe | PhysicsCategory.Floor // 5
            bird.physicsBody?.usesPreciseCollisionDetection = true
            bird.physicsBody?.mass = 0.1
            bird.physicsBody?.affectedByGravity = true
            addChild(bird)
        
        }
    }
    func addPipe(){
        let gap = getGap()
        let yOff = random(min:-gapLocationY,max:gapLocationY)
        let gapCenter = size.height/2 + yOff
        
        let topPipe = SKSpriteNode(imageNamed: "TopPipe")
        topPipe.name = "topP"
        topPipe.anchorPoint = CGPoint(x: 0, y: 0)
        topPipe.position = CGPoint(x: size.width , y: gapCenter + gap/2)
        let topCenter = CGPoint(x: topPipe.size.width/2, y: topPipe.size.height/2)
        topPipe.physicsBody = SKPhysicsBody(rectangleOf: topPipe.size,center: topCenter) // 1
        topPipe.physicsBody?.categoryBitMask = PhysicsCategory.Pipe // 3
        topPipe.physicsBody?.contactTestBitMask = PhysicsCategory.Bird // 4
        topPipe.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        topPipe.physicsBody?.affectedByGravity = false
        topPipe.zPosition = SceneZposition.topPipe.rawValue
        addChild(topPipe)

        let bottomPipe = SKSpriteNode(imageNamed: "BottomPipe")
        bottomPipe.name = "bottomP"
        bottomPipe.anchorPoint = CGPoint(x: 0, y: 1)
        bottomPipe.position = CGPoint(x: size.width , y: gapCenter - gap/2)
        let bottomCenter = CGPoint(x: bottomPipe.size.width/2, y: -bottomPipe.size.height/2)
        bottomPipe.physicsBody = SKPhysicsBody(rectangleOf: bottomPipe.size,center: bottomCenter)
        bottomPipe.physicsBody?.categoryBitMask = PhysicsCategory.Pipe // 3
        bottomPipe.physicsBody?.contactTestBitMask = PhysicsCategory.Bird // 4
        bottomPipe.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        bottomPipe.physicsBody?.affectedByGravity = false
        bottomPipe.zPosition = SceneZposition.bottomPipe.rawValue
        addChild(bottomPipe)
        
        let sensor = SKSpriteNode(color: UIColor(white: 0, alpha: 0), size: CGSize(width: 2, height: gap))
        sensor.name = SceneChildName.Sensor.rawValue
        sensor.position = CGPoint(x: size.width + bottomPipe.size.width, y: gapCenter)
        let sensorCenter = CGPoint(x: sensor.size.width/2, y: sensor.size.height/2)
        sensor.physicsBody = SKPhysicsBody(rectangleOf: sensor.size, center: sensorCenter)
        sensor.physicsBody?.categoryBitMask = PhysicsCategory.Sensor
        sensor.physicsBody?.contactTestBitMask = PhysicsCategory.Bird
        sensor.physicsBody?.collisionBitMask = PhysicsCategory.None
        sensor.physicsBody?.affectedByGravity = false
        sensor.zPosition = bottomPipe.zPosition
        addChild(sensor)
        
        // Create the actions
        let duration = (size.width + topPipe.size.width) / scrollVelocity
        let actionMove = SKAction.moveTo(x: -topPipe.size.width, duration: TimeInterval(duration))
        let actionMoveDone = SKAction.removeFromParent()
        let actionSensorMove = SKAction.moveTo(x: 0, duration: TimeInterval(duration))

        topPipe.run(SKAction.sequence([actionMove, actionMoveDone]))
        bottomPipe.run(SKAction.sequence([actionMove, actionMoveDone]))
        sensor.run(SKAction.sequence([actionSensorMove, actionMoveDone]))
        
    }
    func loadPipe(){
        if let node = childNode(withName: SceneChildName.PipeLabel.rawValue) as! SKLabelNode? {
            node.text = "0"
        }else{
            let label = SKLabelNode(fontNamed: "Arial")
            label.text = "0"
            label.alpha = 0.3
            label.position = CGPoint(x: size.width/2, y: size.height*0.4)
            label.fontColor = SKColor.white
            label.fontSize = 450
            label.zPosition = SceneZposition.pipeLabel.rawValue
            label.horizontalAlignmentMode = .center
            label.name = SceneChildName.PipeLabel.rawValue
            addChild(label)
        }
    }
    
    func loadBackground() {
        guard let _ = childNode(withName: "background") as! SKSpriteNode? else {
            let texture = SKTexture(image: UIImage(named: "Background2")!)
            let size2 = CGSize(width: size.width*2, height: size.height)
            let node = SKSpriteNode(texture: texture, color: UIColor.white, size: size2)
            node.zPosition = SceneZposition.background.rawValue
            node.name = SceneChildName.Background.rawValue
            node.anchorPoint = CGPoint(x: 0, y: 0)
            node.addChild(loadFloor())
            addChild(node)
            let duration = (node.size.width / 2 ) / scrollVelocity
            let actionMove1 = SKAction.moveTo(x: -node.size.width/2, duration: TimeInterval(duration))
            let actionMove2 = SKAction.moveTo(x: 0, duration: 0)
            node.run(SKAction.repeatForever(
                SKAction.sequence([
                    actionMove1,actionMove2])
                ))
            return
        }
    }
    
    func loadFloor()->SKSpriteNode{

        let texture = SKTexture(image: UIImage(named: "Floor")!)
        let floorSize = CGSize(width: 2*size.width, height: size.height*0.1)
        let node = SKSpriteNode(texture: texture, color: UIColor.white, size: floorSize)
        node.zPosition = SceneZposition.floor.rawValue
        node.name = SceneChildName.Floor.rawValue
        node.anchorPoint = CGPoint(x: 0, y: 0)
        let center = CGPoint(x: node.size.width/2, y: node.size.height/2)
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size,center: center) // 1
        node.physicsBody?.categoryBitMask = PhysicsCategory.Floor // 3
        node.physicsBody?.contactTestBitMask = PhysicsCategory.Bird // 4
        node.physicsBody?.collisionBitMask = PhysicsCategory.Bird // 5
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.isDynamic = false
        return node
    
    }
    
    func loadGameReadyNode(){
        guard let _ = childNode(withName: SceneChildName.GameReadyNode.rawValue) as! SKSpriteNode? else {
          
            let texture = SKTexture(image: UIImage(named: "Taptap")!)
            let node = SKSpriteNode(texture: texture)
            node.position = CGPoint(x: size.width/2, y: size.height/2)
            node.zPosition = SceneZposition.gameReady.rawValue
            node.name = SceneChildName.GameReady.rawValue
            
            let gameReadyLabel = SKSpriteNode(texture: SKTexture(imageNamed: "GameReady"))
            gameReadyLabel.position = CGPoint(x: size.width/2, y: size.height/2+node.size.height*0.75)
            gameReadyLabel.zPosition = node.zPosition
            gameReadyLabel.name = SceneChildName.GameReadyLabel.rawValue
            
            let backgroundNode = SKSpriteNode(color: UIColor(white: 0.2, alpha: 0.3), size: size)
            backgroundNode.anchorPoint = CGPoint(x: 0, y: 0)
            backgroundNode.zPosition = SceneZposition.translucentBackground.rawValue
            backgroundNode.name = SceneChildName.GameReadyNode.rawValue
            backgroundNode.addChild(node)
            backgroundNode.addChild(gameReadyLabel)
            addChild(backgroundNode)
            return
        }
        
        
    }
    func loadGameOverNode(){
        guard let _ = childNode(withName: SceneChildName.GameOverNode.rawValue) as! SKSpriteNode? else {
            
            let plate = SKSpriteNode(texture: SKTexture(imageNamed: "MedalPlate"))
            plate.position = CGPoint(x: size.width/2, y: size.height/2)
            plate.zPosition = SceneZposition.gameOver.rawValue
            plate.name = SceneChildName.GameOver.rawValue
            
            let medal = SKSpriteNode(texture: SKTexture(imageNamed: "MedalGold"))
            medal.position = CGPoint(x: -plate.size.width*0.2831, y: -plate.size.height*0.056)
            medal.zPosition = plate.zPosition
            medal.name = SceneChildName.Medal.rawValue
            plate.addChild(medal)
            
            let scoreLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
            scoreLabel.text = "0"
            scoreLabel.fontSize = 36/232 * plate.size.height
            scoreLabel.fontColor = UIColor(white: 0.3, alpha: 1)
            scoreLabel.horizontalAlignmentMode = .right
            scoreLabel.position = CGPoint(x: plate.size.width*180/452, y: plate.size.height*16/232)
            scoreLabel.zPosition = plate.zPosition
            scoreLabel.name = SceneChildName.ScoreLabel.rawValue
            plate.addChild(scoreLabel)
            
            let bestScoreLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
            bestScoreLabel.text = "0"
            bestScoreLabel.fontSize = 36/232 * plate.size.height
            bestScoreLabel.fontColor = UIColor(white: 0.3, alpha: 1)
            bestScoreLabel.horizontalAlignmentMode = .right
            bestScoreLabel.position = CGPoint(x: plate.size.width*180/452, y: -plate.size.height*70/232)
            bestScoreLabel.zPosition = plate.zPosition
            bestScoreLabel.name = SceneChildName.BestScoreLabel.rawValue
            plate.addChild(bestScoreLabel)
            
            let gameOverLabel = SKSpriteNode(texture: SKTexture(imageNamed: "GameOver"))
            gameOverLabel.position = CGPoint(x: size.width/2, y: size.height/2+plate.size.height*0.75)
            gameOverLabel.zPosition = plate.zPosition
            gameOverLabel.name = SceneChildName.GameOverLabel.rawValue
            
            let backgroundNode = SKSpriteNode(color: UIColor(white: 0.2, alpha: 0.3), size: size)
            backgroundNode.anchorPoint = CGPoint(x: 0, y: 0)
            backgroundNode.name = SceneChildName.GameOverNode.rawValue
            backgroundNode.zPosition = SceneZposition.translucentBackground.rawValue
            backgroundNode.addChild(plate)
            backgroundNode.addChild(gameOverLabel)
            backgroundNode.isHidden = true
            addChild(backgroundNode)
            return
        }
        
    }
    //MARK: 自定义函数
    func start(){
        removeAllChildren()
        loadBackground()
        loadGameReadyNode()
        loadGameOverNode()
        loadBird()
        loadPipe()
    }
    
    func getGap()->CGFloat{
        let label = childNode(withName: SceneChildName.PipeLabel.rawValue) as! SKLabelNode
        let score = Int(label.text!)
        let factor :CGFloat
        if score < 10 {
            factor = 6
        }else{
            if score < 100 {
                factor = 5.8
            }else{
                factor = 5.6
            }
        }
        let bird = childNode(withName: SceneChildName.Bird.rawValue) as! SKSpriteNode
        return bird.size.height * factor
    }
    func random()->CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    func removeAllChildrenAction(){
        for child in children {
            child.removeAllActions()
        }
    }
    //MARK: UserDefaults
    func refreshBestScoreAndPresentMedalPlate(){
        let scoreLabelNode = childNode(withName: SceneChildName.PipeLabel.rawValue) as! SKLabelNode
        let score = Int(scoreLabelNode.text!)
        let userDefaults = UserDefaults.standard
        var bestScore = userDefaults.integer(forKey: "BestScore")
        if score > bestScore {
            userDefaults.setValue(score, forKey: "BestScore")
            bestScore = score!
        }
        
        let node = childNode(withName: SceneChildName.GameOverNode.rawValue)
        let plate = node!.childNode(withName: SceneChildName.GameOver.rawValue)
        let scoreLabel = plate?.childNode(withName: SceneChildName.ScoreLabel.rawValue) as! SKLabelNode
        scoreLabel.text = scoreLabelNode.text
        let bestScoreLabel = plate?.childNode(withName: SceneChildName.BestScoreLabel.rawValue) as! SKLabelNode
        bestScoreLabel.text = String(bestScore)
        let medal = plate?.childNode(withName: SceneChildName.Medal.rawValue) as! SKSpriteNode
        
        if bestScore < 50 {
            medal.texture = SKTexture(imageNamed: "MedalBronze")
        }else{
            if bestScore < 100 {
                medal.texture = SKTexture(imageNamed: "MedalSilver")
            }else{
                if bestScore < 500 {
                    medal.texture = SKTexture(imageNamed: "MedalPlatinum")
                }else{
                    medal.texture = SKTexture(imageNamed: "MedalGold")
                }
            }
        }
        node!.isHidden = false
    }
}
