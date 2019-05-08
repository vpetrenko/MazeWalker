//
//  Enemy.swift
//  MazeWalker
//
//  Created by Top on 03/05/2019.
//  Copyright © 2019 VP. All rights reserved.
//

import Foundation
import SpriteKit

class Actor: Hashable {
    static func == (lhs: Actor, rhs: Actor) -> Bool {
        return lhs.sprite == rhs.sprite
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
    
    init() {
        sprite.size = CGSize(width: 48, height: 60)
        sprite.zPosition = 75
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(sprite)
    }
}

class Enemy: Actor {
    override init() {
        super.init()
        sprite = SKSpriteNode(imageNamed: "turtle1")
    }

    init(pos: CGPoint) {
        super.init()
        sprite.position = pos
    }
}


class Bullet: Actor {
    
    override var direction: Direction {
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

    override init() {
        super.init()
        sprite = SKSpriteNode(imageNamed: "bullet")
        sprite.zPosition = 100
    }
}
