//
//  Level.swift
//  MazeWalker
//
//  Created by Top on 13/05/2019.
//  Copyright © 2019 VP. All rights reserved.
//

import Foundation
import SpriteKit

struct Cell: Hashable {
    var x: Int = 0
    var y: Int = 0
}

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
    
    private var level = [[LevelItem]]()
    private var items = [[ActiveItem]]()
    private var width = 0
    private var height = 0
    
    var levelWidth: Int {
        return width
    }
    
    init?() {
        generateLevel()
    }

    private func generateLevel() {
        width = 39
        height = 19
        level = Array(repeating: Array(repeating: .space, count: height), count: width)
        items = Array(repeating: Array(repeating: .none, count: height), count: width)

        var visited = Array(repeating: Array(repeating: false, count: height), count: width)
        for i in 0..<width {
            for j in 0..<height {
                if (i % 2 != 0 && j % 2 != 0 && i > 0 && j > 0 && i < width - 1 && j < height - 1) {
                    level[i][j] = .space
                } else {
                    level[i][j] = .wall
                    visited[i][j] = true
                }
            }
        }

        func allVisited() -> Bool {
            for i in 1..<width - 1 {
                for j in 1..<height - 1 {
                    if !visited[i][j] {
                        return false
                    }
                }
            }
            return true
        }
        let directs = [(-2, 0), (0, -2), (2, 0), (0, 2)]
        var visStack = [Cell]()

        let start = Cell(x: 1, y: 1)
        visited[start.x][start.y] = true
        var current = start
        repeat {
            var candidates = [Cell]()
            for d in directs {
                let chX = current.x + d.0
                let chY = current.y + d.1
                if chX >= 0 && chX < width && chY >= 0 && chY < height && !visited[chX][chY] {
                    candidates.append(Cell(x: chX, y: chY))
                }
            }
            if (candidates.count > 0) {
                visStack.append(current)
                let c = Int.random(in: 0..<candidates.count)
                let rX = (candidates[c].x + current.x) / 2
                let rY = (candidates[c].y + current.y) / 2
                level[rX][rY] = .space
                current = candidates[c]
                visited[current.x][current.y] = true
            } else {
                if !visStack.isEmpty {
                    current = visStack.popLast()!
                } else {
                    break
                }
            }
        } while (!allVisited())
        
        var y = height / 2
        while level[width - 2][y] == .wall {
            y += 1
        }
        items[width - 1][y] = .door(sprite: nil)
        level[width - 1][y] = .space
        
        func generateEmptyCell() -> Cell {
            var x = 0
            var y = 0
            repeat {
                x = Int.random(in: 1..<width - 1)
                y = Int.random(in: 1..<height - 1)
            } while (level[x][y] == .wall || items[x][y] != ActiveItem.none)
            return Cell(x: x, y: y)
        }
        
        self[generateEmptyCell()] = .key(sprite: nil)
        self[generateEmptyCell()] = .ringR(sprite: nil)
        self[generateEmptyCell()] = .ringG(sprite: nil)
        self[generateEmptyCell()] = .ringB(sprite: nil)
        self[generateEmptyCell()] = .crown(sprite: nil)
        self[generateEmptyCell()] = .crown(sprite: nil)
    }
    
    private func loadLevel() {
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
        guard x < width && y < height else { return false }
        
        return level[x][y] == .space
    }
    
    func getItem(_ x:Int, _ y: Int) -> ActiveItem {
        guard x < width && y < height else { return .none }
        return items[x][y]
    }
    
    func removeItem(_ x:Int, _ y: Int) {
        items[x][y] = .none
    }
    
    subscript(c: Cell) -> ActiveItem {
        get {
            return items[c.x][c.y]
        }
        set {
            items[c.x][c.y] = newValue
        }
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
