//
//  GameScene.swift
//  MazeWalker
//
//  Created by Top on 16/04/2019.
//  Copyright © 2019 VP. All rights reserved.
//

import SpriteKit
import GameplayKit

enum ActiveItem {
    case none
    case crown(sprite: SKSpriteNode?)
    case ringR(sprite: SKSpriteNode?)
    case ringG(sprite: SKSpriteNode?)
    case ringB(sprite: SKSpriteNode?)
    case key(sprite: SKSpriteNode?)
    case door(sprite: SKSpriteNode?)
}

enum GraphConsts {
    static let tileWidth = 48
    static let tileHeight = 60
    static let halfTileWidth: CGFloat = CGFloat(tileWidth) / 2.0
    static let halfTileHeight: CGFloat = CGFloat(tileHeight) / 2.0
}

class GameScene: SKScene {
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    private var rockets = [SKSpriteNode]()

    private var enemies = Set<Enemy>()

    private let level: Level

    private var px = 0
    private var py = 0
    private var playerSprite = SKSpriteNode()
    var playerScore = 0
    var playerTags = 50.0
    private var playerHasKey = false
    private var walkFrames = [SKTexture]()

    private var bullets = Set<Bullet>()

    private let directs: [Direction: (Double, Double)] = [
        .left: (-2.0, 0),
        .right: (2.0, 0),
        .up: (0, 2.0),
        .down: (0, -2.0),
    ]
    
    private var playerDirection: Direction
    private var newPlayerDirection: Direction

    required init?(coder aDecoder: NSCoder) {
        if let level = Level() {
            self.level = level
        } else {
            return nil
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
            label.zPosition = 200
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
        
        
        playerSprite = SKSpriteNode(imageNamed: "man1")
        playerSprite.size = CGSize(width: GraphConsts.tileWidth, height: GraphConsts.tileHeight)
        playerSprite.position = CGPoint(x: GraphConsts.halfTileWidth + CGFloat(GraphConsts.tileWidth), y: GraphConsts.halfTileHeight + CGFloat(GraphConsts.tileHeight))
        playerSprite.zPosition = 100
        self.addChild(playerSprite)

        level.initSprites(in: self)
        
        setPlayerKey(playerHasKey)
        let backgroundMusic = SKAudioNode(fileNamed: "ByTheWall.mp3")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
    }
    
    func setPlayerKey(_ key: Bool) {
        walkFrames.removeAll()
        if (key) {
            let wf1 = SKTexture(imageNamed: "man1key")
            walkFrames.append(wf1)
            let wf2 = SKTexture(imageNamed: "man2key")
            walkFrames.append(wf2)
        } else {
            let wf1 = SKTexture(imageNamed: "man1")
            walkFrames.append(wf1)
            let wf2 = SKTexture(imageNamed: "man2")
            walkFrames.append(wf2)
        }
    }
    
    func generateEnemy() {
        let enemy = Enemy()
        let x = Int.random(in: 1..<39)
        let y = Int.random(in: 1..<17)
        enemy.position = CGPoint(x: GraphConsts.halfTileWidth + CGFloat(x * GraphConsts.tileWidth), y: GraphConsts.halfTileHeight + CGFloat(y * GraphConsts.tileHeight))
        enemies.insert(enemy)
        self.addChild(enemy.sprite)
    }
    
    override func keyDown(with event: NSEvent) {
        switch Int(event.keyCode) {
        case 0x31:
//            playerHasKey = !playerHasKey
//            setPlayerKey(playerHasKey)
            break
            
        case KeyCodes.up:
            newPlayerDirection = .up
        case KeyCodes.down:
            newPlayerDirection = .down
        case KeyCodes.left:
            newPlayerDirection = .left
        case KeyCodes.right:
            newPlayerDirection = .right
        case KeyCodes.fireUp:
            fire(.up)
        case KeyCodes.fireDown:
            fire(.down)
        case KeyCodes.fireLeft:
            fire(.left)
        case KeyCodes.fireRight:
            fire(.right)
        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
    
    var lastTime = 0.0
    
    func fire(_ dir: Direction) {
        guard bullets.count < 3 else { return }
        let bullet = Bullet()
        bullet.direction = dir
        bullet.position = playerSprite.position
        bullets.insert(bullet)
        self.addChild(bullet.sprite)
        run(SKAction.playSoundFileNamed("Launch 001.wav", waitForCompletion: false))
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if newPlayerDirection != playerDirection {
            if (Int(GraphConsts.halfTileWidth + playerSprite.position.x) % GraphConsts.tileWidth) == 0 && (newPlayerDirection == .up || newPlayerDirection == .down) {
                playerDirection = newPlayerDirection
            }
            if (Int(GraphConsts.halfTileHeight + playerSprite.position.y) % GraphConsts.tileHeight) == 0 && (newPlayerDirection == .left || newPlayerDirection == .right) {
                playerDirection = newPlayerDirection
            }
            switch(playerDirection) {
            case .left:
                playerSprite.xScale = -1;
            default:
                playerSprite.xScale = 1;
            }
        }
        if let label = self.label {
            label.text = "Score: \(playerScore)    Tags: \(Int(playerTags))"
        }
        
        if playerTags < 1 {
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOverScene = GameOverScene(size: self.size, won: false, score: playerScore, tags: playerTags)
            view?.presentScene(gameOverScene, transition: reveal)
        }
        
        if currentTime - lastTime > 0.001 {
            let newX = playerSprite.position.x + CGFloat(directs[playerDirection]!.0)
            let newY = playerSprite.position.y + CGFloat(directs[playerDirection]!.1)
            
            let tileX = (newX - GraphConsts.halfTileWidth) / CGFloat(GraphConsts.tileWidth)
            let tileY = (newY - GraphConsts.halfTileHeight) / CGFloat(GraphConsts.tileHeight)

            let intX = playerDirection == .right ? Int(ceil(tileX)) : Int(tileX)
            let intY = playerDirection == .up ? Int(ceil(tileY)) : Int(tileY)
            
            var playerCanGo = level.isEmpty(intX, intY)
            
            switch (level.getItem(intX, intY)) {
            case .crown(let sprite):
                playerScore += 100
                sprite?.removeFromParent()
                level.removeItem(intX, intY)
                run(SKAction.playSoundFileNamed("Water 003.wav", waitForCompletion: false))
            case .ringR(let sprite):
                playerScore += 20
                sprite?.removeFromParent()
                level.removeItem(intX, intY)
                run(SKAction.playSoundFileNamed("Water 003.wav", waitForCompletion: false))
            case .ringG(let sprite):
                playerScore += 20
                sprite?.removeFromParent()
                level.removeItem(intX, intY)
                run(SKAction.playSoundFileNamed("Water 003.wav", waitForCompletion: false))
            case .ringB(let sprite):
                playerScore += 20
                sprite?.removeFromParent()
                level.removeItem(intX, intY)
                run(SKAction.playSoundFileNamed("Water 003.wav", waitForCompletion: false))
            case .key(let sprite):
                sprite?.removeFromParent()
                level.removeItem(intX, intY)
                playerHasKey = true
                setPlayerKey(playerHasKey)
                run(SKAction.playSoundFileNamed("Laser 012.wav", waitForCompletion: false))
            case .door(let sprite):
                if playerHasKey {
                    sprite?.removeFromParent()
                    level.removeItem(intX, intY)
                    playerHasKey = false
                    setPlayerKey(playerHasKey)
                    run(SKAction.playSoundFileNamed("Laser 012.wav", waitForCompletion: false))
                } else {
                    playerCanGo = false
                }
            default:
                break
            }
            if playerCanGo {
                playerSprite.position.x = newX
                playerSprite.position.y = newY
                if intX >= 39 {
                    let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                    let gameOverScene = GameOverScene(size: self.size, won: true, score: playerScore, tags: playerTags)
                    view?.presentScene(gameOverScene, transition: reveal)
                }
            }
            playerSprite.texture = self.walkFrames[Int(newX * 0.05) % 2]


            
            for e in enemies {
                let newX = e.position.x + CGFloat(directs[e.direction]!.0)
                let newY = e.position.y + CGFloat(directs[e.direction]!.1)

                let playerRect = CGRect(x: playerSprite.position.x - GraphConsts.halfTileWidth, y: playerSprite.position.y - GraphConsts.halfTileHeight, width: CGFloat(GraphConsts.tileWidth), height: CGFloat(GraphConsts.tileHeight))
                let enemRect = CGRect(x: newX - GraphConsts.halfTileWidth, y: newY - GraphConsts.halfTileHeight, width: CGFloat(GraphConsts.tileWidth), height: CGFloat(GraphConsts.tileHeight))
                if enemRect.intersects(playerRect) {
                    playerTags -= 0.3
                    run(SKAction.playSoundFileNamed("Rattle 007.wav", waitForCompletion: false))
                }
                
                let tileX = (newX - GraphConsts.halfTileWidth) / CGFloat(GraphConsts.tileWidth)
                let tileY = (newY - GraphConsts.halfTileHeight) / CGFloat(GraphConsts.tileHeight)
                
                let intX = e.direction == .right ? Int(ceil(tileX)) : Int(tileX)
                let intY = e.direction == .up ? Int(ceil(tileY)) : Int(tileY)
                
                if level.isEmpty(intX, intY) {
                    e.position.x = newX
                    e.position.y = newY
                }

                var newDir = e.direction
                switch(Int.random(in: 0..<108)) {
                case 0:
                    newDir = .up
                case 1:
                    newDir = .down
                case 2:
                    newDir = .right
                case 3:
                    newDir = .left
                default:
                    break
                }
                
                if (Int(GraphConsts.halfTileWidth + e.position.x) % GraphConsts.tileWidth) == 0 && (newDir == .up || newDir == .down) {
                    e.direction = newDir
                }
                if (Int(GraphConsts.halfTileHeight + e.position.y) % GraphConsts.tileHeight) == 0 && (newDir == .left || newDir == .right) {
                    e.direction = newDir
                }
            }

            var deadBullets = [Bullet]()
            
            for e in bullets {
                let newX = e.position.x + 2 * CGFloat(directs[e.direction]!.0)
                let newY = e.position.y + 2 * CGFloat(directs[e.direction]!.1)
                
                let tileX = (newX - GraphConsts.halfTileWidth) / CGFloat(GraphConsts.tileWidth)
                let tileY = (newY - GraphConsts.halfTileHeight) / CGFloat(GraphConsts.tileHeight)
                
                let intX = e.direction == .right ? Int(ceil(tileX)) : Int(tileX)
                let intY = e.direction == .up ? Int(ceil(tileY)) : Int(tileY)
            
                var deadEnemies = [Enemy]()
                for enem in enemies {
                    var enemPos = enem.position
                    enemPos.x -= GraphConsts.halfTileWidth
                    enemPos.y -= GraphConsts.halfTileHeight
                    let enemRect = CGRect(origin: enemPos, size: CGSize(width: GraphConsts.tileWidth, height: GraphConsts.tileHeight))
                    if (enemRect.contains(e.position)) {
                        deadBullets.append(e)
                        deadEnemies.append(enem)
                        enem.sprite.removeFromParent()
                        enemies.remove(enem)
                        run(SKAction.playSoundFileNamed("Shot 003.wav", waitForCompletion: false))
                        playerScore += 5
                    }
                }
                
                if level.isEmpty(intX, intY) {
                    e.position.x = newX
                    e.position.y = newY
                } else {
                    deadBullets.append(e)
                }
            }
            
            for e in deadBullets {
                e.sprite.removeFromParent()
                bullets.remove(e)
            }
            
            if Int.random(in: 0..<30) == 0 && enemies.count < 25 {
                generateEnemy()
            }

            lastTime = currentTime
//            print(playerSprite.position)
//            print(tileX, tileY)
        }
    }
}
