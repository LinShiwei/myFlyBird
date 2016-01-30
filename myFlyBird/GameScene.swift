//
//  GameScene.swift
//  myFlyBird
//
//  Created by Linsw on 16/1/27.
//  Copyright (c) 2016年 Linsw. All rights reserved.
//

import SpriteKit
struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Bird      : UInt32 = 0b1       // 1
    static let Pipe      : UInt32 = 0b10      // 2
    static let Floor    : UInt32 = 0b11
}

class GameScene: SKScene,SKPhysicsContactDelegate {

    let scrollVelocity:CGFloat = 120//120px per second
    //MARK: View
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.whiteColor()
        loadBackground()
        loadGameReadyNode()
        loadGameOverNode()
        physicsWorld.gravity = CGVectorMake(0, -2)
        physicsWorld.contactDelegate = self
        start()
    }
    //MARK: touch
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let node = self.nodeAtPoint(location)
            if let name = node.name{
                switch name {
                case SceneChildName.GameReady.rawValue :
                    self.view?.paused = false
//                    let gameReadyNode = node as! SKSpriteNode
                    node.hidden = true
                    node.parent?.hidden = true
                case SceneChildName.GameOver.rawValue,SceneChildName.GameOverNode.rawValue:
                    self.view?.paused = false
                    print("overover")
                    start()
                default :
                    let bird = childNodeWithName(SceneChildName.Bird.rawValue) as! SKSpriteNode
                    bird.physicsBody?.velocity = CGVectorMake(0, 0)
                    bird.physicsBody?.applyImpulse(CGVectorMake(0, 20))
                }
            
            }else{
                let bird = childNodeWithName(SceneChildName.Bird.rawValue) as! SKSpriteNode
                bird.physicsBody?.velocity = CGVectorMake(0, 0)
                bird.physicsBody?.applyImpulse(CGVectorMake(0, 20))

            }
        }
       
    }
    //MARK: Contact
    func didBeginContact(contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // 2
        if ((firstBody.categoryBitMask & PhysicsCategory.Bird != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Pipe != 0)) {
                
                birdDidCollideWithPipe(firstBody.node as! SKSpriteNode, pipe: secondBody.node as! SKSpriteNode)
        }
        if ((firstBody.categoryBitMask & PhysicsCategory.Bird != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Floor != 0)) {
                
                birdDidCollideWithPipe(firstBody.node as! SKSpriteNode, pipe: secondBody.node as! SKSpriteNode)
        }
        
        
        
    }
    func birdDidCollideWithPipe(bird:SKSpriteNode,pipe:SKSpriteNode) {
        print("Hit  \(pipe.name)")
//        self.view?.paused = true
//        let node = childNodeWithName(SceneChildName.GameOverNode.rawValue)
//        node!.hidden = false
                let reveal = SKTransition.fadeWithDuration(0.5)
                let gameOverScene = GameOverScene(size: size, won: false)
                self.view?.presentScene(gameOverScene, transition: reveal)
        
    }
   //MARK: Load
    func loadBird(){
        if let node = childNodeWithName(SceneChildName.Bird.rawValue) as! SKSpriteNode?{
            node.position = CGPoint(x: size.width/2,y: size.height/2)
        }else {
            let bird = SKSpriteNode(imageNamed: "bird_1")
            bird.position = CGPoint(x: size.width/2,y: size.height/2)
            bird.name = SceneChildName.Bird.rawValue
            bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.width/2) // 1
            bird.physicsBody?.dynamic = true // 2
            bird.physicsBody?.categoryBitMask = PhysicsCategory.Bird // 3
            bird.physicsBody?.contactTestBitMask = PhysicsCategory.Pipe & PhysicsCategory.Floor  // 4
            bird.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
            bird.physicsBody?.usesPreciseCollisionDetection = true

            bird.physicsBody?.mass = 0.1
            bird.physicsBody?.affectedByGravity = true
            bird.zPosition = SceneZposition.Bird.rawValue
            addChild(bird)
        
        }
    }
    func addPipe(){
        let halfGap = getGap()/2
        let yOff = random(min:-100,max:100)
        let gapCenter = size.height/2 + yOff
        let topPipe = SKSpriteNode(imageNamed: "pipe_top")
        topPipe.name = "topP"
        topPipe.anchorPoint = CGPoint(x: 0, y: 0)
        topPipe.position = CGPoint(x: size.width , y: gapCenter + halfGap)
        let topCenter = CGPoint(x: topPipe.size.width/2, y: topPipe.size.height/2)

        topPipe.physicsBody = SKPhysicsBody(rectangleOfSize: topPipe.size,center: topCenter) // 1
        topPipe.physicsBody?.dynamic = true // 2
        topPipe.physicsBody?.categoryBitMask = PhysicsCategory.Pipe // 3
        topPipe.physicsBody?.contactTestBitMask = PhysicsCategory.Bird // 4
        topPipe.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        topPipe.physicsBody?.affectedByGravity = false
        topPipe.zPosition = SceneZposition.TopPipe.rawValue

        addChild(topPipe)

        let bottomPipe = SKSpriteNode(imageNamed: "pipe_bottom")
        bottomPipe.name = "bottomP"
        bottomPipe.anchorPoint = CGPoint(x: 0, y: 1)
        bottomPipe.position = CGPoint(x: size.width , y: gapCenter - halfGap)
        let bottomCenter = CGPoint(x: bottomPipe.size.width/2, y: -bottomPipe.size.height/2)
        bottomPipe.physicsBody = SKPhysicsBody(rectangleOfSize: bottomPipe.size,center: bottomCenter)
        bottomPipe.physicsBody?.dynamic = true // 2
        bottomPipe.physicsBody?.categoryBitMask = PhysicsCategory.Pipe // 3
        bottomPipe.physicsBody?.contactTestBitMask = PhysicsCategory.Bird // 4
        bottomPipe.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        bottomPipe.physicsBody?.affectedByGravity = false
        bottomPipe.zPosition = SceneZposition.BottomPipe.rawValue
        addChild(bottomPipe)
        
        // Create the actions
        let duration = (size.width + topPipe.size.width) / scrollVelocity
        let actionMove = SKAction.moveToX(-topPipe.size.width, duration: NSTimeInterval(duration))
        let actionMoveDone = SKAction.removeFromParent()
        
        topPipe.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        bottomPipe.runAction(SKAction.sequence([actionMove, actionMoveDone]))

        
    }
    
    
    func loadBackground() {
        guard let _ = childNodeWithName("background") as! SKSpriteNode? else {
            let texture = SKTexture(image: UIImage(named: "back2")!)
            let size2 = CGSize(width: size.width*2, height: size.height)
            let node = SKSpriteNode(texture: texture, color: UIColor.whiteColor(), size: size2)
            node.name = SceneChildName.Background.rawValue
            node.zPosition = SceneZposition.Background.rawValue
            node.anchorPoint = CGPoint(x: 0, y: 0)
            node.addChild(loadFloor())
            addChild(node)
            let duration = (node.size.width / 2 ) / scrollVelocity
            let actionMove1 = SKAction.moveToX(-node.size.width/2, duration: NSTimeInterval(duration))
            let actionMove2 = SKAction.moveToX(0, duration: 0)
            node.runAction(SKAction.repeatActionForever(
                SKAction.sequence([
                    actionMove1,actionMove2])
                ))
            return
        }
    }
        func loadPipe(){
        if let node = childNodeWithName(SceneChildName.PipeLabel.rawValue) as! SKLabelNode? {
            node.text = "0"
        }else{
            let label = SKLabelNode(fontNamed: "Arial")
            label.text = "0"
            label.alpha = 0.3
            label.position = CGPointMake(size.width/2, size.height*0.4)
            label.fontColor = SKColor.whiteColor()
            label.fontSize = 500
            label.zPosition = SceneZposition.PipeLabel.rawValue
            label.horizontalAlignmentMode = .Center
            label.name = SceneChildName.PipeLabel.rawValue
            addChild(label)
            let actionLabelNumberAdd = SKAction.runBlock(){
                label.text = String(Int(label.text!)!+1)
            }
            self.view!.paused = true
            label.runAction(SKAction.repeatActionForever(
                SKAction.sequence([
                    SKAction.runBlock(addPipe),
                    actionLabelNumberAdd,
                    SKAction.waitForDuration(NSTimeInterval(2))
                    ])
                ))
        }
    }
    func loadFloor()->SKSpriteNode{

        let texture = SKTexture(image: UIImage(named: "floor")!)
        let floorSize = CGSize(width: 2*size.width, height: size.height*0.1)
        let node = SKSpriteNode(texture: texture, color: UIColor.whiteColor(), size: floorSize)
        node.name = SceneChildName.Floor.rawValue
        node.zPosition = SceneZposition.Floor.rawValue
        node.anchorPoint = CGPoint(x: 0, y: 0)
        let center = CGPoint(x: node.size.width/2, y: node.size.height/2)
        node.physicsBody = SKPhysicsBody(rectangleOfSize: node.size,center: center) // 1
        node.physicsBody?.dynamic = true // 2
        node.physicsBody?.categoryBitMask = PhysicsCategory.Floor // 3
        node.physicsBody?.contactTestBitMask = PhysicsCategory.Bird // 4
        node.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        node.physicsBody?.affectedByGravity = false
        return node
    
    }
    
    func loadGameReadyNode(){
        guard let _ = childNodeWithName(SceneChildName.GameReadyNode.rawValue) as! SKSpriteNode? else {
            let texture = SKTexture(image: UIImage(named: "taptap")!)
            let node = SKSpriteNode(texture: texture)
            node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            node.position = CGPointMake(size.width/2, size.height/2)
            node.zPosition = SceneZposition.GameReady.rawValue
            node.name = SceneChildName.GameReady.rawValue
            
            let backgroundNode = SKSpriteNode(color: UIColor(white: 0.2, alpha: 0.3), size: size)
            backgroundNode.anchorPoint = CGPoint(x: 0, y: 0)
            backgroundNode.name = SceneChildName.GameReadyNode.rawValue
            backgroundNode.zPosition = SceneZposition.TranslucentBackground.rawValue
            backgroundNode.addChild(node)
            addChild(backgroundNode)
            return
        }
        
        
    }
    func loadGameOverNode(){
        guard let _ = childNodeWithName(SceneChildName.GameOverNode.rawValue) as! SKSpriteNode? else {
            let texture = SKTexture(image: UIImage(named: "medal_plate")!)
            let node = SKSpriteNode(texture: texture)
            node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            node.position = CGPointMake(size.width/2, size.height/2)
            node.zPosition = SceneZposition.GameOver.rawValue
            node.name = SceneChildName.GameOver.rawValue
            
            let backgroundNode = SKSpriteNode(color: UIColor(white: 0.2, alpha: 0.3), size: size)
            backgroundNode.anchorPoint = CGPoint(x: 0, y: 0)
            backgroundNode.name = SceneChildName.GameOverNode.rawValue
            backgroundNode.zPosition = SceneZposition.TranslucentBackground.rawValue
            backgroundNode.addChild(node)
            addChild(backgroundNode)
            return
        }
        
    }
    //MARK: 自定义函数
    func start(){
        loadBird()
        loadPipe()
        let node = childNodeWithName(SceneChildName.GameOverNode.rawValue)
        node!.hidden = true
      
    }
    func getGap()->CGFloat{
        let bird = childNodeWithName(SceneChildName.Bird.rawValue) as! SKSpriteNode
        return bird.size.height * 12
    }
    func random()->CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    func random(min min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    /*
    func loadNumber() {
    let labelA = SKLabelNode(fontNamed: "Arial")
    //        labelA.name = SceneChildName.ScoreName.rawValue
    labelA.text = "1"
    labelA.position = CGPointMake(size.width*3/2, size.height*0.4)
    labelA.fontColor = SKColor.whiteColor()
    labelA.fontSize = 400
    labelA.zPosition = SceneZposition.Number.rawValue
    labelA.horizontalAlignmentMode = .Center
    
    addChild(labelA)
    
    let labelB = SKLabelNode(fontNamed: "Arial")
    labelB.text = "0"
    labelB.position = CGPointMake(size.width/2, size.height*0.4)
    labelB.fontColor = SKColor.whiteColor()
    labelB.fontSize = 400
    labelB.zPosition = SceneZposition.Number.rawValue
    labelB.horizontalAlignmentMode = .Center
    
    addChild(labelB)
    let duration = size.width / scrollVelocity
    let actionMove = SKAction.moveByX(-size.width, y: 0, duration: NSTimeInterval(duration))
    let actionLabelAAdd = SKAction.runBlock(){
    labelA.text = String(Int(labelA.text!)!+2)
    }
    let actionLabelBAdd = SKAction.runBlock(){
    labelB.text = String(Int(labelB.text!)!+2)
    }
    let actionReset = SKAction.moveToX(size.width*3/2, duration: 0)
    labelB.runAction(SKAction.repeatActionForever(SKAction.sequence([actionMove,actionLabelBAdd,actionReset,actionMove])))
    labelA.runAction(SKAction.repeatActionForever(SKAction.sequence([actionMove,actionMove,actionLabelAAdd,actionReset])))
    
    }
    */

}
