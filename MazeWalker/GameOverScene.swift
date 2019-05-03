//
//  GameOverScene.swift
//  MazeWalker
//
//  Created by Top on 03/05/2019.
//  Copyright © 2019 VP. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    init(size: CGSize, won:Bool) {
        super.init(size: size)
        
        // 1
        backgroundColor = SKColor.black
        
        // 2
        let message = won ? "You Won!" : "You Lose :["
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.run() { [weak self] in
                // 5
                guard let `self` = self else { return }
                self.run(SKAction.playSoundFileNamed(won ? "Misc 003.wav" : "Water 009.wav", waitForCompletion: false))
            }
            ]))

        
        // 3
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = message
        label.fontSize = 72
        label.fontColor = SKColor.white
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
        
        // 4
//        run(SKAction.sequence([
//            SKAction.wait(forDuration: 3.0),
//            SKAction.run() { [weak self] in
//                // 5
//                guard let `self` = self else { return }
//                let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
//                if let scene = SKScene(fileNamed: "GameScene") {
//                    scene.scaleMode = .aspectFit
//                    self.view?.presentScene(scene, transition:reveal)
//                }
//            }
//            ]))
    }
    
    // 6
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func keyDown(with event: NSEvent) {
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        if let scene = SKScene(fileNamed: "GameScene") {
            scene.scaleMode = .aspectFit
            self.view?.presentScene(scene, transition:reveal)
        }
    }
}
