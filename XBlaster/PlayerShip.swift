//
//  PlayerShip.swift
//  XBlaster
//
//  Created by altair21 on 15/6/4.
//  Copyright (c) 2015年 altair21. All rights reserved.
//

import SpriteKit

class PlayerShip: Entity {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(entityPosition: CGPoint) {
        let entityTexture = PlayerShip.generateTexture()!
        super.init(position: entityPosition, texture: entityTexture)
        name = "playerShip"
    }
    
    override class func generateTexture() -> SKTexture? {
        struct SharedTexture {
            static var texture = SKTexture()
            static var onceToken: dispatch_once_t = 0
        }
        
        dispatch_once(&SharedTexture.onceToken, {
            let mainShip = SKLabelNode(fontNamed: "Arial")
            mainShip.name = "mainship"
            mainShip.fontSize = 40
            mainShip.fontColor = SKColor.whiteColor()
            mainShip.text = "▲"
            
            let wings = SKLabelNode(fontNamed: "Arial")
            wings.name = "wings"
            wings.fontSize = 40
            wings.text = "< >"
            wings.fontColor = SKColor.whiteColor()
            wings.position = CGPoint(x: 1, y: 7)
            wings.zRotation = CGFloat(180).degreesToRadians()
            mainShip.addChild(wings)
            
            let textureView = SKView()
            SharedTexture.texture = textureView.textureFromNode(mainShip)
            SharedTexture.texture.filteringMode = .Nearest
        })
        
        return SharedTexture.texture
    }
    
}
