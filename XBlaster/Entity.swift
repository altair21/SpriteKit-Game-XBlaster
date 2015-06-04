//
//  Entity.swift
//  XBlaster
//
//  Created by altair21 on 15/6/4.
//  Copyright (c) 2015年 altair21. All rights reserved.
//

import SpriteKit

class Entity: SKSpriteNode {
    var direction = CGPointZero
    var health = 100.0
    var maxHealth = 100.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(position: CGPoint, texture: SKTexture) {
        super.init(texture: texture, color: SKColor.whiteColor(), size: texture.size())
        self.position = position
    }
    
    class func generateTexture() -> SKTexture? {
        //Overridden by subclasses
        return nil
    }
    
    func update(delta: NSTimeInterval) {
        //Overridden by subclasses
    }
}
