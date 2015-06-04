//
//  GameScene.swift
//  XBlaster
//
//  Created by altair21 on 15/6/4.
//  Copyright (c) 2015年 altair21. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    override func didMoveToView(view: SKView) {
        let myLabel = SKLabelNode(fontNamed: "Edit Undo Line BRK")
        myLabel.text = "Hello, World!"
        myLabel.fontSize = 40
        myLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        self.addChild(myLabel)
    }
    
}
