//
//  Touches.swift
//  Coin Hunter
//
//  Created by Dmitrii Poliakov on 2017-08-24.
//  Copyright © 2017 Dmitrii Poliakov. All rights reserved.
//

import Foundation
import SpriteKit

extension GameScene{
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        heroEmitter.isHidden = false
        
        if gameOver == 0{
            
            if tapToPlayLabel.isHidden == false{
            tapToPlayLabel.isHidden = true
        }
            
            if gameOver == 0{
                
        hero.physicsBody?.velocity = CGVector.zero
        hero.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 180))
        
        flyingHeroTexturesArray = [SKTexture(imageNamed: "Fly0.png"), SKTexture(imageNamed: "Fly1.png"), SKTexture(imageNamed: "Fly2.png"), SKTexture(imageNamed: "Fly3.png"), SKTexture(imageNamed: "Fly4.png")]
        let flyingHeroAnimation = SKAction.animate(with: flyingHeroTexturesArray, timePerFrame: 0.1)
        let flyingHeroMoveForever = SKAction.repeatForever(flyingHeroAnimation)
        hero.run(flyingHeroMoveForever)
            }
        }
    }
}
