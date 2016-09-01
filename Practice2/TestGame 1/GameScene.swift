//
//  GameScene.swift
//  TestGame 1
//
//  Created by Marcus Paze on 8/17/16.
//  Copyright (c) 2016 Marcus Paze. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Monster   : UInt32 = 0b1       // 1
    static let Projectile: UInt32 = 0b10      // 2
}

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    let player = SKSpriteNode(imageNamed:"player")
    var monstersDestroyed = 0
    let kScoreHudName = "scoreHud"
    let kHealthHudName = "healthHud"
    var score: Int = 0
    var health: Int = 5
    
    func setupHud() {
        // 1
        let scoreLabel = SKLabelNode(fontNamed: "Courier")
        scoreLabel.name = kScoreHudName
        scoreLabel.fontSize = 25
        
        // 2
        scoreLabel.fontColor = SKColor.blackColor()
        scoreLabel.text = String(format: "Score: %04u", 0)
        
        // 3
        scoreLabel.position = CGPoint(
            x: frame.size.width / 4,
            y: size.height - (40 + scoreLabel.frame.size.height/2)
        )
        addChild(scoreLabel)
        
        // 4
        let healthLabel = SKLabelNode(fontNamed: "Courier")
        healthLabel.name = kHealthHudName
        healthLabel.fontSize = 25
        
        // 5
        healthLabel.fontColor = SKColor.redColor()
        healthLabel.text = String(format: "Health: %u", 5)
        
        // 6
        healthLabel.position = CGPoint(
            x: frame.size.width / 4,
            y: size.height - (80 + healthLabel.frame.size.height/2)
        )
        addChild(healthLabel)
    }
    
    func setupDPad(){
        let upButtonTexture = SKTexture(imageNamed: "UpButton")
        let upButtonPressedTexture = SKTexture(imageNamed: "UpButtonSelect")
        let upButton = FTButtonNode(normalTexture:upButtonTexture, selectedTexture:upButtonPressedTexture, disabledTexture:upButtonPressedTexture)
        upButton.alpha*=0.5
        //upButton.setButtonLabel("Up",font: "Helvetica",fontSize: 40)
        upButton.position = CGPointMake(self.frame.size.width/8, self.frame.size.height/4)
        addChild(upButton)
        
        let downButtonTexture = SKTexture(imageNamed: "DownButton")
        let downButtonPressedTexture = SKTexture(imageNamed: "DownButtonSelect")
        let downButton = FTButtonNode(normalTexture:downButtonTexture, selectedTexture:downButtonPressedTexture, disabledTexture:downButtonPressedTexture)
        downButton.alpha*=0.5
        //downButton.setButtonLabel("Down",font: "Helvetica",fontSize: 40)
        downButton.position = CGPointMake(self.frame.size.width/8, self.frame.size.height/16)
        addChild(downButton)
        
        let leftButtonTexture = SKTexture(imageNamed: "LeftButton")
        let leftButtonPressedTexture = SKTexture(imageNamed: "LeftButtonSelect")
        let leftButton = FTButtonNode(normalTexture:leftButtonTexture, selectedTexture:leftButtonPressedTexture, disabledTexture:leftButtonPressedTexture)
        leftButton.alpha*=0.5
        //leftButton.setButtonLabel("Left",font: "Helvetica",fontSize: 40)
        leftButton.position = CGPointMake(self.frame.size.width/12-10, (upButton.position.y+downButton.position.y)/2)
        addChild(leftButton)
        
        let rightButtonTexture = SKTexture(imageNamed: "RightButton")
        let rightButtonPressedTexture = SKTexture(imageNamed: "RightButtonSelect")
        let rightButton = FTButtonNode(normalTexture:rightButtonTexture, selectedTexture:rightButtonPressedTexture, disabledTexture:rightButtonPressedTexture)
        rightButton.alpha*=0.5
        //rightButton.setButtonLabel("Right",font: "Helvetica",fontSize: 40)
        rightButton.position = CGPointMake(self.frame.size.width/6+10, (upButton.position.y+downButton.position.y)/2)
        addChild(rightButton)
        
        
        //Set Up button actions
        upButton.setButtonAction(self, triggerEvent: .TouchUpInside, action: #selector(doNothing))
        upButton.setButtonAction(self, triggerEvent: .TouchDown, action: #selector(moveUp))
        upButton.setButtonAction(self, triggerEvent: .TouchUp, action: #selector(doNothing))
        //Set Down button actions
        downButton.setButtonAction(self, triggerEvent: .TouchUpInside, action: #selector(doNothing))
        downButton.setButtonAction(self, triggerEvent: .TouchDown, action: #selector(moveDown))
        downButton.setButtonAction(self, triggerEvent: .TouchUp, action: #selector(doNothing))
        //Set Left button actions
        leftButton.setButtonAction(self, triggerEvent: .TouchUpInside, action: #selector(doNothing))
        leftButton.setButtonAction(self, triggerEvent: .TouchDown, action: #selector(moveLeft))
        leftButton.setButtonAction(self, triggerEvent: .TouchUp, action: #selector(doNothing))
        //Set Right button actions
        rightButton.setButtonAction(self, triggerEvent: .TouchUpInside, action: #selector(doNothing))
        rightButton.setButtonAction(self, triggerEvent: .TouchDown, action: #selector(moveRight))
        rightButton.setButtonAction(self, triggerEvent: .TouchUp, action: #selector(doNothing))
    }
    
    func adjustScoreBy(points: Int) {
        score += points
        
        if let score = childNodeWithName(kScoreHudName) as? SKLabelNode {
            score.text = String(format: "Score: %04u", self.score)
        }
    }
    
    func adjustHealthBy(healthAdjustment: Int) {
        // 1
        health = max(health + healthAdjustment, 0)
        
        if let health = childNodeWithName(kHealthHudName) as? SKLabelNode {
            health.text = String(format: "Health: %u", self.health)
        }
    }
    func moveUp(){
        if self.player.position.y<=self.frame.height-self.player.size.height/2{
        self.player.position.y+=10
        }
        print("Player Up")
    }
    func moveDown(){
        if self.player.position.y>=self.player.size.height/2{
            self.player.position.y-=10
        }
        print("Player Down")
    }
    func moveLeft(){
        if self.player.position.x>=self.player.size.width/2{
            self.player.position.x-=10
        }
        print("Player Left")
    }
    func moveRight(){
        if self.player.position.x<=self.frame.width-self.player.size.width/2{
            self.player.position.x+=10
        }
        print("Player Right")
    }
    func doNothing(){
        print("Do Nothing")
    }
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        backgroundColor=SKColor.grayColor()
        
        player.position=CGPoint(x: size.width/10, y: size.height/2)
        addChild(player)
        setupHud()
        setupDPad()
        
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(addMonster),
                SKAction.waitForDuration(1.0)
            ])
        ))
        let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
        
    }
    
    func random() -> CGFloat{
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min min: CGFloat, max: CGFloat) -> CGFloat{
        return random() * (max - min) + min
    }
    
    func addMonster(){
        let monster = SKSpriteNode(imageNamed: "monster")
        
        let actualY = random(min: monster.size.height/2, max: size.height - monster.size.height/2)
        
        monster.position = CGPoint(x: size.width + monster.size.width , y: actualY)
        
        addChild(monster)
        
        monster.physicsBody = SKPhysicsBody(rectangleOfSize: monster.size) // 1
        monster.physicsBody?.dynamic = true // 2
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster // 3
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile // 4
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        let actionMove = SKAction.moveTo(CGPoint(x: -monster.size.width/2, y: actualY) , duration: NSTimeInterval(actualDuration))
        
        let actionMoveDone = SKAction.removeFromParent()
        
        //monster.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        let loseAction = SKAction.runBlock() {
            self.adjustHealthBy(-1)
            print("Monster offscreen")
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let gameOverScene = GameOverScene(size: self.size, won: false, score: self.score)
            if self.health==0{
                self.view?.presentScene(gameOverScene, transition: reveal)
            }
        }
        monster.runAction(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
    }
    
    /*override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            sprite.runAction(SKAction.repeatActionForever(action))
            
            self.addChild(sprite)
        }
    }*/
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        runAction(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))

        // 1 - Choose one of the touches to work with
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.locationInNode(self)
        
        // 2 - Set up initial location of projectile
        let projectile = SKSpriteNode(imageNamed: "projectile")
        projectile.position = player.position
        
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.dynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        // 3 - Determine offset of location to projectile
        let offset = touchLocation - projectile.position
        
        // 4 - Bail out if you are shooting down or backwards
        //if (offset.x < 0) { return }
        
        // 5 - OK to add now - you've double checked position
        addChild(projectile)
        
        // 6 - Get the direction of where to shoot
        let direction = offset.normalized()
        
        // 7 - Make it shoot far enough to be guaranteed off screen
        let shootAmount = direction * 1000
        
        // 8 - Add the shoot amount to the current position
        let realDest = shootAmount + projectile.position
        
        // 9 - Create the actions
        let actionMove = SKAction.moveTo(realDest, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    func projectileDidCollideWithMonster(monster:SKSpriteNode, projectile:SKSpriteNode ) {
        print("Hit")
        monster.removeFromParent()
        monstersDestroyed += 1
        adjustScoreBy(100)
        /*if (monstersDestroyed > 30) {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let gameOverScene = GameOverScene(size: self.size, won: true, score: self.score)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }*/
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        // 1
        var monsterBody: SKPhysicsBody
        var projectileBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            monsterBody = contact.bodyA
            projectileBody = contact.bodyB
        } else {
            monsterBody = contact.bodyB
            projectileBody = contact.bodyA
        }
        
        // 2
        if ((monsterBody.categoryBitMask & PhysicsCategory.Monster != 0) &&
            (projectileBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
            projectileDidCollideWithMonster(monsterBody.node as! SKSpriteNode, projectile: projectileBody.node as! SKSpriteNode)
            //crashes when double kill
        }
        
    }

   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
