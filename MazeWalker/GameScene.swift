//
//  GameScene.swift
//  MazeWalker
//
//  Created by Top on 16/04/2019.
//  Copyright © 2019 VP. All rights reserved.
//

import SpriteKit
import GameplayKit

enum LevelItem {
    case wall
    case space
}

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

    private var walls = [SKSpriteNode]()
    
    private var enemies = Set<Enemy>()

    private var levelMap = """
11111111111111111111111111111111111111111
1        1          1                  11
1 1 1K1  1  1111111 1     111    1     11
1 1 1111 1  1     1 1 11    1 1111  1  11
1 1    1 11 11    1 GBR1    1       1  11
1 1  1       11   1 1111  1 1   11111  11
1 1  1 11111  11111 1     1            11
1    1   1C1   111    11  1 11111      11
1 111111   1          1   1        1   11
1     1   111B11 1  1 1 11111   1  1   D1
11111 1 1   111C 1  1 1    11   1  1   11
1       111 1G1111  1      J1   1      11
1 1111111   1 11    111111 11          11
1  1   1  1 1     1        11 11111    11
1  1C1        11111 111                11
1 1111 1111 1111111   111  1111   1    11
1      1            1                  11
11111111111111111111111111111111111111111
"""

    private var level : [[LevelItem]]
    private var items : [[ActiveItem]]
    private var width = 0
    private var height = 0

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
        var y = height - 1
        for ch in levelMap {
            switch (ch) {
            case "\n":
                x = -1
                y -= 1
            case "1":
                level[x][y] = .wall
            case "D":
                items[x][y] = .door(sprite: nil)
            case "C":
                items[x][y] = .crown(sprite: nil)
            case "R":
                items[x][y] = .ringR(sprite: nil)
            case "G":
                items[x][y] = .ringG(sprite: nil)
            case "B":
                items[x][y] = .ringB(sprite: nil)
            case "K":
                items[x][y] = .key(sprite: nil)
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

        for (x, col) in level.enumerated() {
            for (y, t) in col.enumerated() {
                var title : SKSpriteNode
                switch (t) {
                case .wall:
                    title = SKSpriteNode(imageNamed: "wall1")
                case .space:
                    title = SKSpriteNode(imageNamed: "space")
                }
                title.size = CGSize(width: GraphConsts.tileWidth, height: GraphConsts.tileHeight)
                title.position = CGPoint(x: GraphConsts.halfTileWidth + CGFloat(x * GraphConsts.tileWidth), y: GraphConsts.halfTileHeight + CGFloat(y * GraphConsts.tileHeight))
                self.addChild(title)
                self.walls.append(title)
            }
        }
        for (x, col) in items.enumerated() {
            for (y, t) in col.enumerated() {
                var item = SKSpriteNode()
                var gotItem = true
                switch (t) {
                case .crown:
                    item = SKSpriteNode(imageNamed: "crown")
                    items[x][y] = .crown(sprite: item)
                case .ringR:
                    item = SKSpriteNode(imageNamed: "ringR")
                    items[x][y] = .ringR(sprite: item)
                case .ringG:
                    item = SKSpriteNode(imageNamed: "ringG")
                    items[x][y] = .ringG(sprite: item)
                case .ringB:
                    item = SKSpriteNode(imageNamed: "ringB")
                    items[x][y] = .ringB(sprite: item)
                case .key:
                    item = SKSpriteNode(imageNamed: "key")
                    items[x][y] = .key(sprite: item)
                case .door:
                    item = SKSpriteNode(imageNamed: "door")
                    items[x][y] = .door(sprite: item)
                default:
                    gotItem = false
                }
                if gotItem {
                    item.size = CGSize(width: GraphConsts.tileWidth, height: GraphConsts.tileHeight)
                    item.position = CGPoint(x: GraphConsts.halfTileWidth + CGFloat(x * GraphConsts.tileWidth), y: GraphConsts.halfTileHeight + CGFloat(y * GraphConsts.tileHeight))
                    item.zPosition = 50
                    self.addChild(item)
                }
            }
        }
        
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
            if (Int(GraphConsts.halfTileHeight + playerSprite.position.x) % GraphConsts.tileWidth) == 0 && (newPlayerDirection == .up || newPlayerDirection == .down) {
                playerDirection = newPlayerDirection
            }
            if (Int(GraphConsts.halfTileWidth + playerSprite.position.y) % GraphConsts.tileHeight) == 0 && (newPlayerDirection == .left || newPlayerDirection == .right) {
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
            
            var playerCanGo : Bool = level[intX][intY] == .space
            
            switch (items[intX][intY]) {
            case .crown(let sprite):
                playerScore += 100
                sprite?.removeFromParent()
                items[intX][intY] = .none
                run(SKAction.playSoundFileNamed("Water 003.wav", waitForCompletion: false))
            case .ringR(let sprite):
                playerScore += 20
                sprite?.removeFromParent()
                items[intX][intY] = .none
                run(SKAction.playSoundFileNamed("Water 003.wav", waitForCompletion: false))
            case .ringG(let sprite):
                playerScore += 20
                sprite?.removeFromParent()
                items[intX][intY] = .none
                run(SKAction.playSoundFileNamed("Water 003.wav", waitForCompletion: false))
            case .ringB(let sprite):
                playerScore += 20
                sprite?.removeFromParent()
                items[intX][intY] = .none
                run(SKAction.playSoundFileNamed("Water 003.wav", waitForCompletion: false))
            case .key(let sprite):
                sprite?.removeFromParent()
                items[intX][intY] = .none
                playerHasKey = true
                setPlayerKey(playerHasKey)
                run(SKAction.playSoundFileNamed("Laser 012.wav", waitForCompletion: false))
            case .door(let sprite):
                if playerHasKey {
                    sprite?.removeFromParent()
                    items[intX][intY] = .none
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
                
                if level[intX][intY] == .space {
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
                
                if level[intX][intY] == .space {
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
