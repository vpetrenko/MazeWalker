//
//  Enemy.swift
//  MazeWalker
//
//  Created by Top on 03/05/2019.
//  Copyright © 2019 VP. All rights reserved.
//

import Foundation
import SpriteKit

class Enemy: Hashable {
    static func == (lhs: Enemy, rhs: Enemy) -> Bool {
        return lhs.sprite == rhs.sprite
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(sprite)
    }
        
    
    var sprite = SKSpriteNode()
    
    var position: CGPoint {
        get {
            return sprite.position
        }
        set {
            sprite.position = newValue
        }
    }

    var direction: Direction = .down
    
    required init() {
        sprite = SKSpriteNode(imageNamed: "turtle1")
        sprite.size = CGSize(width: 48, height: 60)
        sprite.zPosition = 75
    }

    init(pos: CGPoint) {
        sprite.position = pos
    }
}


class Bullet: Hashable {
    
    static func == (lhs: Bullet, rhs: Bullet) -> Bool {
        return lhs.sprite == rhs.sprite
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(sprite)
    }

    var sprite = SKSpriteNode()
    
    var position: CGPoint {
        get {
            return sprite.position
        }
        set {
            sprite.position = newValue
        }
    }
    
    var direction: Direction = .down {
        didSet {
            switch(direction) {
            case .right:
                sprite.zRotation = 1.57
            case .up:
                sprite.zRotation = 3.14
            case .left:
                sprite.zRotation = 4.712
            default:
                sprite.zRotation = 0
            }
        }
    }

    required init() {
        sprite = SKSpriteNode(imageNamed: "bullet")
        sprite.size = CGSize(width: 48, height: 60)
        sprite.zPosition = 100
    }
}
