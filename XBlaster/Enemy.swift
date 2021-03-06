//
//  Enemy.swift
//  XBlaster
//
//  Created by altair21 on 15/6/5.
//  Copyright (c) 2015年 altair21. All rights reserved.
//

import SpriteKit

// The different enemies in XBlaster all share the same behaviours such as how they move using
// AISteering, their health labels and how they react to being hit. This base class immplements
// these key areas which all the enemy objects can then inherit from.
class Enemy : Entity {
    
    let healthMeterLabel = SKLabelNode(fontNamed: "Arial")
    let healthMeterText: NSString = "________"
    let scoreLabel = SKLabelNode(fontNamed: "Edit Undo Line BRK")
    let damageTakenPerHit = 10.0
    let deathEmitter:SKEmitterNode = SKEmitterNode(fileNamed: "enemyDeath.sks")!
    
    var aiSteering: AISteering!
    var playableRect: CGRect!
    var dead = false
    var score = 0
    
    // All the actions used for the enemies are static which means that each enemy uses a shared
    // action that is created only once in the loadSharedAssets() method. This reduces the number
    // of actions needed and removes the need to keep creating and destroying actions for each enemy
    struct SharedAssets {
        static var damageAction:SKAction!
        static var hitLeftAction:SKAction!
        static var hitRightAction:SKAction!
        static var moveBackAction:SKAction!
        static var scoreLabelAction:SKAction!
        static var onceToken:dispatch_once_t = 0
    }
    
    class func loadSharedAssets() {
        
        dispatch_once(&SharedAssets.onceToken, {
            
            SharedAssets.damageAction = SKAction.sequence([
                SKAction.colorizeWithColor(SKColor.redColor(), colorBlendFactor: 1.0,
                    duration: 0.0),
                SKAction.colorizeWithColorBlendFactor(0.0, duration: 1.0)
                ])
            
            SharedAssets.hitLeftAction = SKAction.sequence([
                SKAction.rotateByAngle(CGFloat(-15).degreesToRadians(), duration: 0.25),
                SKAction.rotateToAngle(CGFloat(0).degreesToRadians(), duration: 0.5)
                ])
            
            SharedAssets.hitRightAction = SKAction.sequence([
                SKAction.rotateByAngle(CGFloat(15).degreesToRadians(), duration: 0.25),
                SKAction.rotateToAngle(CGFloat(0).degreesToRadians(), duration: 0.5)
                ])
            
            SharedAssets.moveBackAction = SKAction.moveByX(0,
                y: 20, duration: 0.25)
            
            SharedAssets.scoreLabelAction = SKAction.sequence([
                SKAction.group([
                    SKAction.scaleTo(1, duration: 0),
                    SKAction.fadeOutWithDuration(0),
                    SKAction.fadeInWithDuration(0.5),
                    SKAction.moveByX(0, y: 20, duration: 0.5)
                    ]),
                SKAction.group([
                    SKAction.moveByX(0, y: 40, duration: 1),
                    SKAction.fadeOutWithDuration(1)
                    ]),
                ])
            
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(entityPosition: CGPoint, texture: SKTexture, playableRect: CGRect) {
        
        super.init(position: entityPosition, texture: texture)
        
        self.playableRect = playableRect
        
        // Setup the label that shows how much health an enemy has
        healthMeterLabel.name = "healthMeter"
        healthMeterLabel.fontSize = 20
        healthMeterLabel.fontColor = SKColor.greenColor()
        healthMeterLabel.text = healthMeterText as String
        healthMeterLabel.position = CGPointMake(0, 30)
        addChild(healthMeterLabel)
        
        scoreLabel.fontSize = 15
        scoreLabel.color = SKColorWithRGBA(128, g: 255, b: 255, a: 255)
        scoreLabel.text = String(score)
        
    }
    
    override func update(delta: NSTimeInterval) {
        
        // If the player has been marked as dead then reposition them at the top of the screen and
        // mark them a no longer being dead
        if dead {
            dead = false
            position = CGPointMake(CGFloat.random(min:playableRect.origin.x, max:playableRect.size.width),
                playableRect.size.height)
        }
        
        // If the enemy has reached is next waypoint then set the next waypoint to the players
        // current position. This causes the enemies to chase the player :]
        if aiSteering.waypointReached {
            let mainScene = scene as! GameScene
            aiSteering.updateWaypoint(mainScene.playerShip.position)
        }
        
        // Steer the enemy towards the current waypoint
        aiSteering.update(delta)
        
        // Update the health meter for the enemy
        let healthBarLength = 8.0 * health / 100
        healthMeterLabel.text = "\(healthMeterText.substringToIndex(Int(healthBarLength)))"
        healthMeterLabel.fontColor = SKColor(red: CGFloat(2 * (1 - health / 100)),
            green:CGFloat(2 * health / 100), blue:0, alpha:1)
    }
    
    func configureCollisionBody() {
        // More details on this method inside the PlayerShip class and more details on SpriteKit physics in
        // Chapter 9, "Beginner Physics"
        physicsBody = SKPhysicsBody(rectangleOfSize: frame.size)
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask = ColliderType.Enemy
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = ColliderType.Player | ColliderType.Bullet
    }
    
    override func collidedWith(body: SKPhysicsBody, contact: SKPhysicsContact) {
        
        // When an enemy gets hit we grab the point at which the enemy was hit
        let localContactPoint:CGPoint = self.scene!.convertPoint(contact.contactPoint, toNode: self)
        
        // New actions are going to be added to this enemy so remove all the current actions they have
        removeAllActions()
        
        // If the enemy was hit on the left side then run the hitLeftAction otherwise run the hitRightAction.
        // This gives a nice impression of an actual collision
        if localContactPoint.x < 0 {
            runAction(SharedAssets.hitLeftAction)
        } else {
            runAction(SharedAssets.hitRightAction)
        }
        
        // Run the damage action so that the player has a visual que that the enemy has been damaged
        runAction(SharedAssets.damageAction)
        if aiSteering.currentDirection.y < 0 {
            runAction(SharedAssets.moveBackAction)
        }
        
        // Reduce the enemies health by the defined damageTakenPerHit
        health -= damageTakenPerHit
        
        // If the enemies health is now zero or less then...
        if health <= 0 {
            // ...mark them as dead
            dead = true
            
            // Increase the score for the player
            let mainScene = scene as! GameScene
            mainScene.increaseScoreBy(score)
            
            // Reset the enemies health
            health = maxHealth
            
            scoreLabel.position = position
            if scoreLabel.parent == nil {
                mainScene.addChild(scoreLabel)
            }
            scoreLabel.removeAllActions()
            scoreLabel.runAction(SharedAssets.scoreLabelAction)
            
            deathEmitter.position = position
            if deathEmitter.parent == nil {
                mainScene.particleLayerNode.addChild(deathEmitter)
            }
            deathEmitter.resetSimulation()
            mainScene.playExplodeSound()
        }
    }
}
