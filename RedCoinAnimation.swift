//
//  RedCoinAnimation.swift
//  Coin Hunter
//
//  Created by Dmitrii Poliakov on 2017-08-25.
//  Copyright © 2017 Dmitrii Poliakov. All rights reserved.
//

import Foundation
import SpriteKit

class RedCoinAnumation {
    
    func redCoinZScale(sprite: SKSpriteNode){
        sprite.run(SKAction.repeatForever(SKAction.sequence([SKAction.scale(by: 2, duration: 0.5), SKAction.scale(to: 1, duration: 1.0)])))
    }
    
    func redColorAnimation(sprite: SKSpriteNode, animationDuration: TimeInterval){
        sprite.run(SKAction.repeatForever(SKAction.sequence([SKAction.colorize(with: SKColor.red, colorBlendFactor: 1.0, duration: animationDuration), SKAction.colorize(withColorBlendFactor: 0.0, duration: animationDuration)])))
    }
}
