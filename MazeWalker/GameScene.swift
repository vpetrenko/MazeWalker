//
//  GameScene.swift
//  MazeWalker
//
//  Created by Top on 16/04/2019.
//  Copyright © 2019 VP. All rights reserved.
//

import SpriteKit
import GameplayKit

enum KeyCodes : UInt16 {
    case up = 126
    case down = 125
    case left = 123
    case right = 124
}

enum LevelItem {
    case wall
    case space
    case door
}

enum ActiveItem {
    case none
    case crown(sprite: SKSpriteNode?)
}

enum Direction {
    case left
    case right
    case up
    case down
}

class GameScene: SKScene {
    
    let tileWidth = 48
    let tileHeight = 60
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    private var rockets = [SKSpriteNode]()

    private var walls = [SKSpriteNode]()

    private var levelMap = """
D11111111111111111111111111111111111111D
1                                      1
1    1                                 1
1 1 1C                                 1
1  1C                                  1
1                                      1
1                                      1
1                                      1
1                                      1
1                                      1
1                 1                    1
1                1D1                   1
1                 1                    1
1                                      1
1                                      1
1                                      1
1                                      1
D11111111111111111111111111111111111111D
"""
   
    private var level : [[LevelItem]]
    private var items : [[ActiveItem]]
    private var width = 0
    private var height = 0

    private var px = 0
    private var py = 0
    private var playerSprite = SKSpriteNode()
    private var playerScore = 0

    private let directs: [Direction: (Double, Double)] = [
        .left: (-2.0, 0),
        .right: (2.0, 0),
        .up: (0, 2.0),
        .down: (0, -2.0),
    ]
    
    private var playerDirection: Direction
    private var newPlayerDirection: Direction

    required init?(coder aDecoder: NSCoder) {
        for ch in levelMap {
            if ch != "\n" {
                width += 1
            } else {
                break
            }
        }
        height = levelMap.reduce(0, { $1 == "\n" ? $0 + 1 : $0 } ) + 1
        
        level = Array(repeating: Array(repeating: .space, count: height), count: width)
        items = Array(repeating: Array(repeating: .none, count: height), count: width)
        var x = 0
        var y = 0
        for ch in levelMap {
            switch (ch) {
            case "\n":
                x = -1
                y += 1
            case "1":
                level[x][y] = .wall
            case "D":
                level[x][y] = .door
            case "C":
                items[x][y] = .crown(sprite: nil)
            case " ":
                level[x][y] = .space
            default:
                level[x][y] = .space
            }
            x += 1
        }
        playerDirection = .right
        newPlayerDirection = .right
        super.init(coder: aDecoder)
    }
    
    override func didMove(to view: SKView) {
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
        
        
        playerSprite = SKSpriteNode(imageNamed: "rocket")
        playerSprite.size = CGSize(width: 48, height: 60)
        playerSprite.position = CGPoint(x: 24 + 48, y: 30 + 60)
        playerSprite.zPosition = 100
        self.addChild(playerSprite)

        for (x, col) in level.enumerated() {
            for (y, t) in col.enumerated() {
                var title : SKSpriteNode
                switch (t) {
                case .wall:
                    title = SKSpriteNode(imageNamed: "brick")
                case .door:
                    title = SKSpriteNode(imageNamed: "door")
                case .space:
                    title = SKSpriteNode(imageNamed: "dirt")
                }
                title.size = CGSize(width: 48, height: 60)
                title.position = CGPoint(x: 24 + x * 48, y: 30 + y * 60)
                self.addChild(title)
                self.walls.append(title)
            }
        }
        for (x, col) in items.enumerated() {
            for (y, t) in col.enumerated() {
                var item = SKSpriteNode()
                var gotItem = false
                switch (t) {
                case .crown:
                    item = SKSpriteNode(imageNamed: "crown")
                    items[x][y] = .crown(sprite: item)
                    gotItem = true
                default:
                    gotItem = false
                }
                if gotItem {
                    item.size = CGSize(width: tileWidth, height: tileHeight)
                    item.position = CGPoint(x: 24 + x * 48, y: 30 + y * 60)
                    item.zPosition = 50
                    self.addChild(item)
                }
            }
        }
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        print("touchDown: \(pos)")
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        let rocket = SKSpriteNode(imageNamed: "rocket")
        rocket.position = pos
        self.addChild(rocket)
        self.rockets.append(rocket)
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        self.touchDown(atPoint: event.location(in: self))
    }
    
    override func mouseDragged(with event: NSEvent) {
        self.touchMoved(toPoint: event.location(in: self))
    }
    
    override func mouseUp(with event: NSEvent) {
        self.touchUp(atPoint: event.location(in: self))
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 0x31:
//            if let label = self.label {
//                label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
//            }
            for x in self.rockets {
                x.removeFromParent()
            }
            self.rockets.removeAll()
        case KeyCodes.up.rawValue:
            newPlayerDirection = .up
        case KeyCodes.down.rawValue:
            newPlayerDirection = .down
        case KeyCodes.left.rawValue:
            newPlayerDirection = .left
        case KeyCodes.right.rawValue:
            newPlayerDirection = .right
        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
    
    var lastTime = 0.0
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if newPlayerDirection != playerDirection {
            if (Int(24 + playerSprite.position.x) % tileWidth) == 0 && (newPlayerDirection == .up || newPlayerDirection == .down) {
                playerDirection = newPlayerDirection
            }
            if (Int(30 + playerSprite.position.y) % tileHeight) == 0 && (newPlayerDirection == .left || newPlayerDirection == .right) {
                playerDirection = newPlayerDirection
            }
        }
        if let label = self.label {
            label.text = "Player score: \(playerScore)"
        }

        if currentTime - lastTime > 0.001 {
            let newX = playerSprite.position.x + CGFloat(directs[playerDirection]!.0)
            let newY = playerSprite.position.y + CGFloat(directs[playerDirection]!.1)
            
            let tileX = (newX - 24) / CGFloat(tileWidth)
            let tileY = (newY - 30) / CGFloat(tileHeight)
            
            let intX = playerDirection == .right ? Int(ceil(tileX)) : Int(tileX)
            let intY = playerDirection == .up ? Int(ceil(tileY)) : Int(tileY)
            
            if level[intX][intY] == .space {
                playerSprite.position.x = newX
                playerSprite.position.y = newY
            }
            switch (items[intX][intY]) {
            case .crown(let sprite):
                playerScore += 100
                sprite?.removeFromParent()
                items[intX][intY] = .none
            default:
                break
            }
            
            lastTime = currentTime
            print(playerSprite.position)
            print(tileX, tileY)
        }
    }
}
