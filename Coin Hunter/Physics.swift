//
//  Physics.swift
//  Coin Hunter
//
//  Created by Dmitrii Poliakov on 2017-08-24.
//  Copyright © 2017 Dmitrii Poliakov. All rights reserved.
//

import Foundation
import SpriteKit

extension GameScene{
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let objectNode = contact.bodyA.categoryBitMask == objectGroup ? contact.bodyA.node : contact.bodyB.node
        
        if score > highScore{
            highScore = score
        }
        
        UserDefaults.standard.set(highScore, forKey: "highScore")
        
        if contact.bodyA.categoryBitMask == objectGroup || contact.bodyB.categoryBitMask == objectGroup{
            
            hero.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            
            if shieldBool == false{
                shakeAndFlashAnimation(view: self.view!)
            
            if sound == true{
                run(electricGateDestroyPreload)
            }
            
            hero.physicsBody?.allowsRotation = false
            
            heroEmitterObject.removeAllChildren()
            coinObject.removeAllChildren()
            redCoinObject.removeAllChildren()
            groundObject.removeAllChildren()
            movingObject.removeAllChildren()
            shieldObject.removeAllChildren()
            shieldItemObject.removeAllChildren()
            
            stopGameobject()
            
            timerForAddingCoin.invalidate()
            timerForAddingRedCoin.invalidate()
            timerForElectricGate.invalidate()
            timerForMine.invalidate()
            timerForShieldItem.invalidate()
            
            deadHeroTexturesArray = [SKTexture(imageNamed: "Dead0.png"), SKTexture(imageNamed: "Dead1.png"), SKTexture(imageNamed: "Dead2.png"), SKTexture(imageNamed: "Dead3.png"), SKTexture(imageNamed: "Dead4.png"), SKTexture(imageNamed: "Dead5.png"), SKTexture(imageNamed: "Dead6.png")]
            let deadHeroAnimation = SKAction.animate(with: deadHeroTexturesArray, timePerFrame: 0.2)
            
            hero.run(deadHeroAnimation)
                
            showHighScore()
            
            gameOver = 1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.scene?.isPaused = true
                self.heroObject.removeAllChildren()
                self.showHighScoreText()
                
                self.gameViewControllerBridge.refreshGameButton.isHidden = false
                
                self.levelLabel.isHidden = true
                
                if self.score > self.highScore{
                    self.highScore = self.score
                }
                
                self.highScoreLabel.isHidden = false
                self.highScoreTextLabel.isHidden = false
                self.highScoreLabel.text = "\(self.highScore)"
            })
        }
            else{//removing shield
                objectNode?.removeFromParent()
                shieldObject.removeAllChildren()
                shieldBool = false
                
                if sound == true{
                    run(shieldOffPreload)
                }
            }
        }
        
        if contact.bodyA.categoryBitMask == shieldGroup || contact.bodyB.categoryBitMask == shieldGroup{
            
            let shieldNode = contact.bodyA.categoryBitMask == shieldGroup ? contact.bodyA.node : contact.bodyB.node
            
            if shieldBool == false{
                if sound == true{
                    run(pickCoinSoundPreload)
                }
                shieldNode?.removeFromParent()
                addShield()
                shieldBool = true
            }

            }
        
        if contact.bodyA.categoryBitMask == groundGroup || contact.bodyB.categoryBitMask == groundGroup{
            
            if gameOver == 0{
                
                heroEmitter.isHidden = true
            
            runningHeroTexturesArray = [SKTexture(imageNamed: "Run0.png"), SKTexture(imageNamed: "Run1.png"), SKTexture(imageNamed: "Run2.png"), SKTexture(imageNamed: "Run3.png"), SKTexture(imageNamed: "Run4.png"), SKTexture(imageNamed: "Run5.png"), SKTexture(imageNamed: "Run6.png")]
            let runningHeroAnimation = SKAction.animate(with: runningHeroTexturesArray, timePerFrame: 0.1)
            let runningHeroMoveForever = SKAction.repeatForever(runningHeroAnimation)
            
            hero.run(runningHeroMoveForever)
            }
        }
        
        if contact.bodyA.categoryBitMask == coinGroup || contact.bodyB.categoryBitMask == coinGroup{
            
            let coinNode = contact.bodyA.categoryBitMask == coinGroup ? contact.bodyA.node : contact.bodyB.node
            coinNode?.removeFromParent()
            
            if sound == true{
                run(pickCoinSoundPreload)
            }
            
            score += 1
            scoreLabel.text = "\(score)"
        }
        
        if contact.bodyA.categoryBitMask == redCoinGroup || contact.bodyB.categoryBitMask == redCoinGroup{
            let redCoinNode = contact.bodyA.categoryBitMask == redCoinGroup ? contact.bodyA.node : contact.bodyB.node
            
            if sound == true{
                run(pickCoinSoundPreload)
            }
            
            score += 2
            scoreLabel.text = "\(score)"
            
            redCoinNode?.removeFromParent()
        }
    }
}
