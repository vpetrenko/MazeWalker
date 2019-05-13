//
//  Level.swift
//  MazeWalker
//
//  Created by Top on 13/05/2019.
//  Copyright © 2019 VP. All rights reserved.
//

import Foundation
import SpriteKit

class Level {
    enum LevelItem {
        case wall
        case space
    }

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
    private var width = 0
    private var height = 0
    
    private var items : [[ActiveItem]]
    
    init?() {
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
    }

    func isEmpty(_ x: Int, _ y: Int) -> Bool {
        return level[x][y] == .space
    }
    
    func getItem(_ x:Int, _ y: Int) -> ActiveItem {
        return items[x][y]
    }
    
    func removeItem(_ x:Int, _ y: Int) {
        items[x][y] = .none
    }
    
    func initSprites(in scene: SKScene) {
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
                scene.addChild(title)
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
                    scene.addChild(item)
                }
            }
        }

    }
    
}
