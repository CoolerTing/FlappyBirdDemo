//
//  GameScene.swift
//  Bird
//
//  Created by 丁强 on 2019/6/3.
//  Copyright © 2019 丁强. All rights reserved.
//

import SpriteKit
import GameplayKit

enum statusType {
    case gaming
    case over
    case beforeGame
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    lazy private var gameOverLabel : SKLabelNode = {
        let label = SKLabelNode.init(text: "Game Over")
        label.fontColor = SKColor.black
        label.fontSize = 45
        return label
    }()
    
    private var bird : SKSpriteNode?
    
    private var floor1 : SKSpriteNode?
    
    private var floor2 : SKSpriteNode?
    
    private var status : statusType = .beforeGame
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.cyan
        // Get label node from scene and store it for use later
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsWorld.contactDelegate = self
        
        bird = SKSpriteNode.init(imageNamed: "player1")
        if let b = bird {
            b.size = CGSize.init(width: 30, height: 30)
            b.position = CGPoint.init(x: UIScreen.main.bounds.size.width / 2, y: UIScreen.main.bounds.size.height / 2)
            b.physicsBody = SKPhysicsBody(texture: b.texture!, size: b.size)
            b.physicsBody?.isDynamic = false
            b.physicsBody?.allowsRotation = false
            b.physicsBody?.categoryBitMask = 0
            b.physicsBody?.contactTestBitMask = 1 | 2
            b.name = "bird"
            addChild(b)
            birdFly(bird: b)
        }
        
        floor1 = SKSpriteNode.init(imageNamed: "floor")
        if let f = floor1 {
            f.size = CGSize.init(width: UIScreen.main.bounds.size.width, height: 80)
            f.position = CGPoint.init(x: UIScreen.main.bounds.size.width / 2, y: 40)
            f.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: -UIScreen.main.bounds.size.width / 2, y: -40, width: f.size.width, height: f.size.height))
            f.physicsBody?.categoryBitMask = 1
            f.physicsBody?.contactTestBitMask = 0
            f.name = "floor"
            addChild(f)
        }
        
        floor2 = SKSpriteNode.init(imageNamed: "floor")
        if let f = floor2 {
            f.size = CGSize.init(width: UIScreen.main.bounds.size.width, height: 80)
            f.position = CGPoint.init(x: UIScreen.main.bounds.size.width / 2 + (floor1?.frame.size.width)!, y: 40)
            f.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: -UIScreen.main.bounds.size.width / 2, y: -40, width: f.size.width, height: f.size.height))
            f.physicsBody?.categoryBitMask = 1
            f.physicsBody?.contactTestBitMask = 0
            f.name = "floor"
            addChild(f)
        }
    }
    
    func gameOver() {
        isUserInteractionEnabled = false
        stopAddBarrier()
        addChild(gameOverLabel)
        gameOverLabel.position = CGPoint.init(x: UIScreen.main.bounds.size.width / 2, y: (self.view?.bounds.size.height)!)
        gameOverLabel.run(SKAction.move(by: CGVector.init(dx: 0, dy: -self.size.height / 2), duration: 0.5), completion: {
            self.isUserInteractionEnabled = true
        })
    }
    
    func gameStart() {
        bird?.physicsBody?.isDynamic = true
        bird?.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 10))
        
        let addBarrier = SKAction.run {
            self.addBarrier()
        }
        
        run(SKAction.repeatForever((SKAction.sequence([addBarrier, SKAction.wait(forDuration: 5)]))), withKey: "addBarrier")
        status = .gaming
    }
    
    func stopAddBarrier() {
        removeAction(forKey: "addBarrier")
    }
    
    func restore() {
        status = .beforeGame
        for node in self.children where node.name == "barrier" {
            node.removeFromParent()
        }
        gameOverLabel.removeFromParent()
        bird?.physicsBody?.isDynamic = false
        bird?.position = CGPoint.init(x: UIScreen.main.bounds.size.width / 2, y: UIScreen.main.bounds.size.height / 2)
        birdFly(bird: bird!)
    }
    
    func birdFly(bird: SKSpriteNode) {
        let flyArray = [SKTexture(imageNamed: "player1"),
                        SKTexture(imageNamed: "player2"),
                        SKTexture(imageNamed: "player3"),
                        SKTexture(imageNamed: "player2")]
        let flyAction = SKAction.animate(with: flyArray, timePerFrame: 0.1)
        bird.run(SKAction.repeatForever(flyAction), withKey: "fly")
    }
    
    func stopFly() {
        bird?.removeAction(forKey: "fly")
    }
    
    func addBarrier() {
        let height = self.size.height - (floor1?.size.height)!
        let gapHeight = CGFloat(arc4random_uniform(UInt32((bird?.size.height)!))) + (bird?.size.height)! * 2.5
        let topHeight = CGFloat(arc4random_uniform(UInt32(height - gapHeight)))
        let bottomHeight = height - gapHeight - topHeight
        let width = CGFloat(60)
        
        let topTexture = SKTexture.init(imageNamed: "topPipe")
        let top = SKSpriteNode.init(texture: topTexture, size: CGSize.init(width: width, height: topHeight))
        top.physicsBody = SKPhysicsBody.init(texture: topTexture, size: CGSize.init(width: width, height: topHeight))
        top.physicsBody?.isDynamic = false
        top.physicsBody?.categoryBitMask = 2
        top.position = CGPoint.init(x: UIScreen.main.bounds.width + width / 2.0, y: self.size.height - topHeight / 2.0)
        top.name = "barrier"
        addChild(top)
        
        let bottomTexture = SKTexture.init(imageNamed: "bottomPipe")
        let bottom = SKSpriteNode.init(texture: bottomTexture, size: CGSize.init(width: width, height: bottomHeight))
        bottom.physicsBody = SKPhysicsBody.init(texture: bottomTexture, size: CGSize.init(width: width, height: bottomHeight))
        bottom.physicsBody?.isDynamic = false
        bottom.physicsBody?.categoryBitMask = 2
        bottom.position = CGPoint.init(x: UIScreen.main.bounds.width + width / 2.0, y: (floor1?.size.height)! + bottomHeight / 2.0)
        bottom.name = "barrier"
        addChild(bottom)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch status {
        case .gaming:
            bird?.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 10))
        case .beforeGame:
            gameStart()
        case .over:
            restore()
        }
    }
    
    func moveFloor() {
        if let f = floor1 {
            f.position = CGPoint.init(x: f.position.x - 1, y: f.position.y)
            if f.position.x <= -UIScreen.main.bounds.size.width / 2 {
                if let f2 = floor2 {
                    f.position = CGPoint.init(x: f2.position.x + f2.frame.size.width - 1, y: f.position.y)
                }
            }
        }
        
        if let f = floor2 {
            f.position = CGPoint.init(x: f.position.x - 1, y: f.position.y)
            if f.position.x <= -UIScreen.main.bounds.size.width / 2 {
                if let f1 = floor1 {
                    f.position = CGPoint.init(x: f1.position.x + f1.frame.size.width, y: f.position.y)
                }
            }
        }
        
        for node in self.children where node.name == "barrier" {
            node.position = CGPoint.init(x: node.position.x - 1, y: node.position.y)
            if node.position.x <= -30 {
                node.removeFromParent()
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if status != .over {
            moveFloor()
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if status != .gaming {
            return
        }
        
        var bodyA : SKPhysicsBody
        var bodyB : SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            bodyA = contact.bodyA
            bodyB = contact.bodyB
        } else {
            bodyB = contact.bodyA
            bodyA = contact.bodyB
        }
        
        if bodyA.categoryBitMask == 0 && bodyB.categoryBitMask == 1 || bodyA.categoryBitMask == 0 && bodyB.categoryBitMask == 2 {
            status = .over
            stopFly()
            gameOver()
        }
    }
}
