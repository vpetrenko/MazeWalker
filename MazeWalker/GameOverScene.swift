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
    var playerScore = 0
    var playerTags = 0.0
    var playerWon = false
    
    init(size: CGSize, won:Bool, score:Int, tags:Double) {
        super.init(size: size)
        
        playerScore = score
        playerTags = tags
        playerWon = won
        backgroundColor = SKColor.black
        
        let message = (won ? "You Won!" : "You Lose :[")
            + "  Score: \(score). Press any key to continue."
        
        if won {
            run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 0.5), SKAction.run() { [weak self] in
                guard let self = self else { return }
                    if let emitter = SKEmitterNode(fileNamed: "SparkParticles") {
                        let sx = Int.random(in: 100..<Int(size.width) - 100)
                        let sy = Int.random(in: 100..<Int(size.height) - 100)
                        emitter.position = CGPoint(x: sx, y: sy)
                        self.addChild(emitter)
                    }
                }])))
        }
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.run() { [weak self] in
                guard let self = self else { return }
                self.run(SKAction.playSoundFileNamed(won ? "Misc 003.wav" : "Water 009.wav", waitForCompletion: false))
            }
            ]))

        
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = message
        label.fontSize = 60
        label.fontColor = SKColor.white
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func keyDown(with event: NSEvent) {
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        if let scene = SKScene(fileNamed: "GameScene") {
            scene.scaleMode = .aspectFit
            if let scene = scene as? GameScene {
                if playerWon {
                    scene.playerScore = playerScore
                    scene.playerTags = playerTags
                } else {
                    scene.playerScore = 0
                    scene.playerTags = 50
                }
            }
            self.view?.presentScene(scene, transition:reveal)
        }
    }
}
