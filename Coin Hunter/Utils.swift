//
//  Utils.swift
//  Coin Hunter
//
//  Created by Dmitrii Poliakov on 2017-08-24.
//  Copyright © 2017 Dmitrii Poliakov. All rights reserved.
//

import Foundation
import CoreGraphics

func - (left: CGPoint, right: CGPoint) -> CGPoint{
    
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func + (left: CGPoint, right: CGPoint) -> CGPoint{
    
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}
