//
//  GameScene.swift
//  Coin Hunter
//
//  Created by Dmitrii Poliakov on 2017-08-23.
//  Copyright © 2017 Dmitrii Poliakov. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //Textures
    var backgroundTexture: SKTexture!
    var flyingHeroTexture: SKTexture!
    var runningHeroTexture: SKTexture!
    var coinTexture: SKTexture!
    var redCoinTexture: SKTexture!
    var coinHeroTexture: SKTexture!
    var redCoinHeroTexture: SKTexture!
    var electricGateTexture: SKTexture!
    var deadHeroTexture: SKTexture!
    var shieldTexture: SKTexture!
    var shieldItemTexture: SKTexture!
    var mineTexture1: SKTexture!
    var mineTexture2: SKTexture!
    
    //Emmiters Node
    var heroEmitter = SKEmitterNode()
    
    //Label nodes
    var tapToPlayLabel = SKLabelNode()
    var scoreLabel = SKLabelNode()
    var highScoreLabel = SKLabelNode()
    var highScoreTextLabel = SKLabelNode()
    var levelLabel = SKLabelNode()
    
    //Sprite Nodes
    var backgroundNode = SKSpriteNode()
    var groundNode = SKSpriteNode()
    var skyNode = SKSpriteNode()
    var hero = SKSpriteNode()
    var coin = SKSpriteNode()
    var redCoin = SKSpriteNode()
    var electricGate = SKSpriteNode()
    var shield = SKSpriteNode()
    var shieldItem = SKSpriteNode()
    var mine = SKSpriteNode()
    
    
    //Sprite Objects
    var backgroundObject = SKNode()
    var groundObject = SKNode()
    var movingObject = SKNode() //all objects moving towards hero
    var heroObject = SKNode()
    var heroEmitterObject = SKNode()
    var coinObject = SKNode()
    var redCoinObject = SKNode()
    var shieldObject = SKNode()
    var shieldItemObject = SKNode()
    var labelObject = SKNode()
    
    //Bit masks
    var heroGroup: UInt32 = 0x1 << 1
    var groundGroup: UInt32 = 0x1 << 2
    var coinGroup: UInt32 = 0x1 << 3
    var redCoinGroup: UInt32 = 0x1 << 4
    var objectGroup: UInt32 = 0x1 << 5
    var shieldGroup: UInt32 = 0x1 << 6
    
    //Texture Arrays for Animation
    var flyingHeroTexturesArray = [SKTexture]()
    var runningHeroTexturesArray = [SKTexture]()
    var coinTexturesArray  = [SKTexture]()
    var electricGateTexturesArray = [SKTexture]()
    var deadHeroTexturesArray = [SKTexture]()
    
    //Timers for coins appearance
    var timerForAddingCoin = Timer()
    var timerForAddingRedCoin = Timer()
    var timerForElectricGate = Timer()
    var timerForShield = Timer()
    var timerForShieldItem = Timer()
    var timerForMine = Timer()
    
    //Sounds
    var pickCoinSoundPreload = SKAction()
    var electricGateCreatePreload = SKAction()
    var electricGateDestroyPreload = SKAction()
    var shieldOnPreload = SKAction()
    var shieldOffPreload = SKAction()
    
    //Flags
    var sound = true
    var shieldBool = false
    
    
    //Move electric gate along Y axis
    var moveElectricGateY = SKAction()
    
    //Red coin animation
    var animations = RedCoinAnumation()
    
    //Other variables
    var gameViewControllerBridge: GameViewController!
    var score = 0
    var highScore = 0
    var gameOver = 0
    
    override func didMove(to view: SKView) {
        
        backgroundTexture = SKTexture(imageNamed: "bg01.png")
        flyingHeroTexture = SKTexture(imageNamed: "Fly0.png")
        runningHeroTexture = SKTexture(imageNamed: "Run0.png")
        heroEmitter = SKEmitterNode(fileNamed: "EngineFlames.sks")!
        coinTexture = SKTexture(imageNamed: "coin.jpg")
        redCoinTexture = SKTexture(imageNamed: "coin.jpg")
        coinHeroTexture = SKTexture(imageNamed: "Coin0.png")
        redCoinHeroTexture = SKTexture(imageNamed: "Coin0.png")
        electricGateTexture = SKTexture(imageNamed: "ElectricGate01.png")
        shieldTexture = SKTexture(imageNamed: "shield.png")
        shieldItemTexture = SKTexture(imageNamed: "shieldItem.png")
        mineTexture1 = SKTexture(imageNamed: "mine1.png")
        mineTexture2 = SKTexture(imageNamed: "mine2.png")
        
        self.physicsWorld.contactDelegate = self
        
        createObjects()
        
        if UserDefaults.standard.object(forKey: "highScore") != nil{
            
            highScore = UserDefaults.standard.object(forKey: "highScore") as! Int
            highScoreLabel.text = "\(highScore)"
        }
        
        if gameOver == 0{
            createGame()
        }
        
        pickCoinSoundPreload = SKAction.playSoundFileNamed("pickCoin.mp3", waitForCompletion: false)
        electricGateCreatePreload = SKAction.playSoundFileNamed("electricCreate.wav", waitForCompletion: false)
        electricGateDestroyPreload = SKAction.playSoundFileNamed("electricDead.mp3", waitForCompletion: false)
        shieldOnPreload = SKAction.playSoundFileNamed("shieldOn.mp3", waitForCompletion: false)
        shieldOffPreload = SKAction.playSoundFileNamed("shieldOff", waitForCompletion: false)
        
    }
    
    func createObjects(){ //Creation of Sprite Objects
        self.addChild(backgroundObject)
        self.addChild(heroObject)
        self.addChild(groundObject)
        self.addChild(movingObject)
        self.addChild(heroEmitterObject)
        self.addChild(coinObject)
        self.addChild(redCoinObject)
        self.addChild(shieldObject)
        self.addChild(shieldItemObject)
        self.addChild(labelObject)
    }
    
    func createGame(){ //Creation of game objects
        
        createBackground()
        createLowerBorderForNodes()
        createUpperBorderForNodes()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2){
        self.createHero()
        self.createEngineFlames()
        self.timerFunc()
        self.addElectricGate()
        }
        
        tapToPlay()
        showScore()
        showLevel()
        highScoreTextLabel.isHidden = true
        
        gameViewControllerBridge.refreshGameButton.isHidden = true
        
        if labelObject.children.count != 0{
            labelObject.removeAllChildren()
        }
    }
    
    func createBackground(){
        
        backgroundTexture = SKTexture(imageNamed: "bg01.png") // for game reload
        
        let backgroundMove = SKAction.moveBy(x: -backgroundTexture.size().width, y: 0, duration: 3) //"-" to move from right to left
        let backgroundReplacement = SKAction.moveBy(x: backgroundTexture.size().width, y: 0, duration: 0) //0 to make sure there is no gap between backgrounds
        let backgroundMoveForever = SKAction.repeatForever(SKAction.sequence([backgroundMove, backgroundReplacement])) // ensure backgrounds change constantly
        
        for i in 0..<3{  //move from background to background
            backgroundNode = SKSpriteNode(texture: backgroundTexture)
            backgroundNode.position = CGPoint(x: size.width/4 + backgroundTexture.size().width * CGFloat(i), y: size.height/2)
            backgroundNode.size.height = frame.height
            backgroundNode.run(backgroundMoveForever)
            backgroundNode.zPosition = -1
            
            backgroundObject.addChild(backgroundNode)
        }
    }
    
    func createLowerBorderForNodes(){
        
        groundNode = SKSpriteNode()
        groundNode.position = CGPoint.zero
        
        groundNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: self.frame.height/4 + self.frame.height/8))
        groundNode.physicsBody?.isDynamic = false
        groundNode.physicsBody?.categoryBitMask = groundGroup
        groundNode.zPosition = 1
        
        groundObject.addChild(groundNode)
    }
    
    func createUpperBorderForNodes(){
        
        skyNode = SKSpriteNode()
        skyNode.position = CGPoint(x: 0, y: self.frame.maxY)
        skyNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.size.width + 100, height: self.frame.size.height/4 - 20))
        skyNode.physicsBody?.isDynamic = false
        skyNode.zPosition = 1
        
        movingObject.addChild(skyNode)
    }
    
    func addHero(heroNode: SKSpriteNode, at position: CGPoint){
        
        hero = SKSpriteNode(texture: flyingHeroTexture)
        
        //Hero animation
        flyingHeroTexturesArray = [SKTexture(imageNamed: "Fly0.png"), SKTexture(imageNamed: "Fly1.png"), SKTexture(imageNamed: "Fly2.png"), SKTexture(imageNamed: "Fly3.png"), SKTexture(imageNamed: "Fly4.png")]
        let flyingHeroAnimation = SKAction.animate(with: flyingHeroTexturesArray, timePerFrame: 0.1)
        let flyingHeroMoveForever = SKAction.repeatForever(flyingHeroAnimation)
        hero.run(flyingHeroMoveForever)
        
        hero.position = position
        hero.size.height = 84
        hero.size.width = 120
        
        hero.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: hero.size.width - 40, height: hero.size.height - 30))
        
        hero.physicsBody?.categoryBitMask = heroGroup
        hero.physicsBody?.contactTestBitMask = groundGroup | coinGroup | redCoinGroup | objectGroup | shieldGroup//action/contact with ground (background)
        hero.physicsBody?.collisionBitMask = groundGroup
        
        hero.physicsBody?.isDynamic = true
        hero.physicsBody?.allowsRotation = false
        hero.zPosition = 1
        
        heroObject.addChild(hero)
    }
    
    func createHero(){
        addHero(heroNode: hero, at: CGPoint(x: self.size.width/4, y: flyingHeroTexture.size().height + 400))
    }
    
    func createEngineFlames(){
        
        heroEmitter = SKEmitterNode(fileNamed: "EngineFlames")!
        heroEmitterObject.zPosition = 1
        heroEmitterObject.addChild(heroEmitter)
    }
    
    @objc func addCoin(){
        
        coin = SKSpriteNode(texture: coinTexture)
        coinTexturesArray = [SKTexture(imageNamed: "Coin0.png"), SKTexture(imageNamed: "Coin1.png"), SKTexture(imageNamed: "Coin2.png"), SKTexture(imageNamed: "Coin3.png")]
        let coinAnimation = SKAction.animate(with: coinTexturesArray, timePerFrame: 0.1)
        let coinMoveForever = SKAction.repeatForever(coinAnimation)
        coin.run(coinMoveForever)
        
        let movement = arc4random() % UInt32(self.frame.size.height/2)
        let pipeOffset = CGFloat(movement) - self.frame.size.height/4
        coin.size.width = 40
        coin.size.height = 40
        
        coin.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: coin.size.width - 20, height: coin.size.height - 20))
        coin.physicsBody?.restitution = 0
        coin.position = CGPoint(x: self.size.width + 50, y: coinTexture.size().height + 90 + pipeOffset)
        
        let moveCoin = SKAction.moveBy(x: -self.frame.size.width * 2, y: 0, duration: 5)
        let coinRemove = SKAction.removeFromParent()
        let coinMoveBgForever = SKAction.repeatForever(SKAction.sequence([moveCoin, coinRemove]))
        
        coin.run(coinMoveBgForever)
        
        coin.physicsBody?.isDynamic = false
        coin.physicsBody?.categoryBitMask = coinGroup
        coin.zPosition = 1
        coinObject.addChild(coin)
    }
    
    @objc func addRedCoin(){
        
        redCoin = SKSpriteNode(texture: redCoinTexture)
        coinTexturesArray = [SKTexture(imageNamed: "Coin0.png"), SKTexture(imageNamed: "Coin1.png"), SKTexture(imageNamed: "Coin2.png"), SKTexture(imageNamed: "Coin3.png")]
        let redCoinAnimation = SKAction.animate(with: coinTexturesArray, timePerFrame: 0.1)
        let redCoinMoveForever = SKAction.repeatForever(redCoinAnimation)
        redCoin.run(redCoinMoveForever)
        
        let movement = arc4random() % UInt32(self.frame.size.height/2)
        let pipeOffset = CGFloat(movement) - self.frame.size.height/4
        redCoin.size.width = 40
        redCoin.size.height = 40
        
        redCoin.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: redCoin.size.width - 10,  height: redCoin.size.height - 10))
        redCoin.physicsBody?.restitution = 0
        redCoin.position = CGPoint(x: self.size.width + 50, y: redCoinTexture.size().height + 90 + pipeOffset)
        
        let moveCoin = SKAction.moveBy(x: -self.frame.size.width * 2, y: 0, duration: 5)
        let coinRemove = SKAction.removeFromParent()
        let coinMoveBgForever = SKAction.repeatForever(SKAction.sequence([moveCoin, coinRemove]))
        
        redCoin.run(coinMoveBgForever)
        
        animations.redCoinZScale(sprite: redCoin)
        animations.redColorAnimation(sprite: redCoin, animationDuration: 0.5)
        redCoin.setScale(1.3)
        redCoin.physicsBody?.isDynamic = false
        redCoin.physicsBody?.categoryBitMask = redCoinGroup
        redCoin.zPosition = 1
        redCoinObject.addChild(redCoin)
    }
    
    @objc func addElectricGate(){
        
        if sound == true{
            run(electricGateCreatePreload)
        }
        
        electricGate = SKSpriteNode(texture: electricGateTexture)
        electricGateTexturesArray = [SKTexture(imageNamed: "ElectricGate01.png"), SKTexture(imageNamed: "ElectricGate02.png"), SKTexture(imageNamed: "ElectricGate03.png"), SKTexture(imageNamed: "ElectricGate04.png")]
        let electricGateAnimation = SKAction.animate(with: electricGateTexturesArray, timePerFrame: 0.1)
        let electricGateMoveForever = SKAction.repeatForever(electricGateAnimation)
        electricGate.run(electricGateMoveForever)
        
        let randomPosition = arc4random() % 2
        let movement = arc4random() % UInt32(self.frame.size.height/5)
        let pipeOffset = self.frame.size.height/4 + 30 - CGFloat(movement)
        if randomPosition == 0{
            electricGate.position = CGPoint(x: self.size.width + 50, y: electricGateTexture.size().height/2 + 90 + pipeOffset)
            electricGate.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: electricGate.size.width - 40, height: electricGate.size.height - 20))
        }
        else{
            electricGate.position = CGPoint(x: self.size.width + 50, y: self.frame.size.height - electricGateTexture.size().height/2 - 90 - pipeOffset)
            electricGate.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: electricGate.size.width - 40, height: electricGate.size.height - 20))
        }
        
        electricGate.run(SKAction.repeatForever(SKAction.sequence([SKAction.run({
            self.electricGate.run(SKAction.rotate(byAngle: CGFloat(Double.pi * 2), duration: 0.5))
        }), SKAction.wait(forDuration: 20)])))
        
        let moveTowardsHeroAction = SKAction.moveBy(x: -self.frame.width - 300, y: 0, duration: 6)
        electricGate.run(moveTowardsHeroAction)
        
        var scaleValue: CGFloat = 0.3
        
        let scaleRandom = arc4random() % UInt32(5)
        switch scaleRandom{
        case 0:
            scaleValue = 1.0
        case 1:
            scaleValue = 0.9
        case 2:
            scaleValue = 0.6
        case 3:
            scaleValue = 0.8
        case 4:
            scaleValue = 0.7
        default:
            scaleValue = 0.3
        }
        
        electricGate.setScale(scaleValue)
        
        let randomMovement = arc4random() % 9
        switch randomMovement{
        case 0:
            moveElectricGateY = SKAction.moveTo(y: self.frame.height/2 + 220, duration: 4)
        case 1:
            moveElectricGateY = SKAction.moveTo(y: self.frame.height/2 - 220, duration: 5)
        case 2:
            moveElectricGateY = SKAction.moveTo(y: self.frame.height/2 - 150, duration: 4)
        case 3:
            moveElectricGateY = SKAction.moveTo(y: self.frame.height/2 + 150, duration: 5)
        case 4:
            moveElectricGateY = SKAction.moveTo(y: self.frame.height/2 + 50, duration: 4)
        case 5:
            moveElectricGateY = SKAction.moveTo(y: self.frame.height/2 - 50, duration: 5)
        default:
            moveElectricGateY = SKAction.moveTo(y: self.frame.height/2, duration: 4)
        }
        
        electricGate.run(moveElectricGateY)
        
        electricGate.physicsBody?.restitution = 0
        electricGate.physicsBody?.isDynamic = false
        electricGate.physicsBody?.categoryBitMask = objectGroup
        electricGate.zPosition = 1
        movingObject.addChild(electricGate)
    }
    
    @objc func addMine(){
        
        mine = SKSpriteNode(texture: mineTexture1)
        let minesRandom = arc4random() % UInt32(2)
        
        if minesRandom == 0{
            mine = SKSpriteNode(texture: mineTexture1)
        }
        else{
            mine = SKSpriteNode(texture: mineTexture2)
        }
        
        mine.size.width = 70
        mine.size.height = 62
        mine.position = CGPoint(x: self.frame.size.width + 150, y: self.frame.size.height / 4 - self.frame.size.height/24)
        let moveMineX = SKAction.moveTo(x: self.frame.size.width / 4, duration: 4)
        mine.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: mine.size.width - 40, height: mine.size.height - 30))
        mine.physicsBody?.categoryBitMask = objectGroup
        mine.physicsBody?.isDynamic = false
        
        let removeAction = SKAction.removeFromParent()
        let mineMoveForever = SKAction.repeatForever(SKAction.sequence([moveMineX, removeAction]))
        
        mineRotationAnimation(sprite: mine, animDuration: 0.2)
        mine.run(mineMoveForever)
        mine.zPosition = 1
        movingObject.addChild(mine)
        
    }
    
    func mineRotationAnimation(sprite: SKSpriteNode, animDuration: TimeInterval){
        
        sprite.run(SKAction.repeatForever(SKAction.sequence([SKAction.rotate(toAngle: CGFloat(Double.pi/2), duration: animDuration), SKAction.rotate(toAngle: CGFloat(-Double.pi), duration: animDuration), SKAction.rotate(toAngle: CGFloat(Double.pi/2), duration: animDuration), SKAction.rotate(toAngle: CGFloat(-Double.pi), duration: animDuration)])))
    }
    
    func addShield(){
        
        shield = SKSpriteNode(texture: shieldTexture)
        
        if sound == true{
            run(shieldOnPreload)
        }
        
        shield.zPosition = 1
        shieldObject.addChild(shield)
    }
    
    @objc func addShieldItem(){
        
        shieldItem = SKSpriteNode(texture: shieldItemTexture)
        
        let movement = arc4random() % UInt32(self.frame.size.height/2)
        let pipeOffset = CGFloat(movement) - self.frame.size.height/4
        
        shieldItem.position = CGPoint(x: self.size.width + 50, y: shieldItemTexture.size().height + self.size.height/2 + pipeOffset)
        
        shieldItem.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: shieldItem.size.width - 20, height: shieldItem.size.height - 20))
        shieldItem.physicsBody?.restitution = 0
        
        let shieldMove = SKAction.moveBy(x: -self.size.width * 2, y: 0, duration: 5)
        let removeAction = SKAction.removeFromParent()
        let shieldMoveBgForever = SKAction.repeatForever(SKAction.sequence([shieldMove, removeAction]))
        
        shieldItem.run(shieldMoveBgForever)
        
        animations.redCoinZScale(sprite: shieldItem)
        shieldItem.setScale(1.1)
        
        shieldItem.physicsBody?.isDynamic = false
        shieldItem.physicsBody?.categoryBitMask = shieldGroup
        shieldItem.zPosition = 1
        shieldItemObject.addChild(shieldItem)
    }
    
    func tapToPlay(){
        
        tapToPlayLabel.text = "Tap to Fly!"
        tapToPlayLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        tapToPlayLabel.fontSize = 50
        tapToPlayLabel.fontColor = UIColor.white
        tapToPlayLabel.fontName = "Chalkduster"
        tapToPlayLabel.zPosition = 1
        self.addChild(tapToPlayLabel)
    }
    
    func showScore(){
        
        scoreLabel.fontName = "Chalkduster"
        scoreLabel.text = "0"
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.maxY - 200)
        scoreLabel.fontSize = 60
        scoreLabel.color = UIColor.white
        scoreLabel.zPosition = 1
        self.addChild(scoreLabel)
    }
    
    func showHighScore(){
        
        highScoreLabel = SKLabelNode()
        highScoreLabel.position = CGPoint(x: self.frame.maxX - 100, y: self.frame.maxY - 210)
        highScoreLabel.fontSize = 50
        highScoreLabel.fontName = "Chalkduster"
        highScoreLabel.fontColor = UIColor.white
        highScoreLabel.isHidden = true
        highScoreLabel.zPosition = 1
        labelObject.addChild(highScoreLabel)
    }
    
    func showHighScoreText(){
        
        //highScoreTextLabel = SKLabelNode()
        highScoreTextLabel.position = CGPoint(x: self.frame.maxX - 100, y: self.frame.maxY - 150)
        highScoreTextLabel.fontSize = 30
        highScoreTextLabel.fontName = "Chalkduster"
        highScoreTextLabel.fontColor = UIColor.white
        highScoreTextLabel.text = "High Score"
        highScoreTextLabel.zPosition = 1
        labelObject.addChild(highScoreTextLabel)
    }
    
    func showLevel(){
        
        levelLabel.position = CGPoint(x: self.frame.maxX - 60, y: self.frame.maxY - 140)
        levelLabel.fontSize = 30
        levelLabel.fontName = "Chalkduster"
        levelLabel.fontColor = UIColor.white
        levelLabel.text = "Level 1"
        levelLabel.zPosition = 1
        self.addChild(levelLabel)
    }
    
    func timerFunc(){
        
        timerForAddingCoin.invalidate()
        timerForAddingRedCoin.invalidate()
        timerForElectricGate.invalidate()
        timerForMine.invalidate()
        timerForShieldItem.invalidate()
        
        timerForAddingCoin = Timer.scheduledTimer(timeInterval: 2.64, target: self, selector: #selector(GameScene.addCoin), userInfo: nil, repeats: true)
        timerForAddingRedCoin = Timer.scheduledTimer(timeInterval: 8.246, target: self, selector: #selector(GameScene.addRedCoin), userInfo: nil, repeats: true)
        timerForElectricGate = Timer.scheduledTimer(timeInterval: 5.234, target: self, selector: #selector(GameScene.addElectricGate), userInfo: nil, repeats: true)
        timerForMine = Timer.scheduledTimer(timeInterval: 4.45, target: self, selector: #selector(GameScene.addMine), userInfo: nil, repeats: true)
        timerForShieldItem = Timer.scheduledTimer(timeInterval: 20.246, target: self, selector: #selector(GameScene.addShieldItem), userInfo: nil, repeats: true)
    }
    
    func stopGameobject(){
        
        coinObject.speed = 0
        movingObject.speed = 0
        redCoinObject.speed = 0
        heroObject.speed = 0
    }
    
    func reloadGame(){
        
        coinObject.removeAllChildren()
        redCoinObject.removeAllChildren()
        movingObject.removeAllChildren()
        heroObject.removeAllChildren()
        
        levelLabel.text = "Level 1"
        gameOver = 0
        
        scene?.isPaused = false
        
        coinObject.speed = 1
        redCoinObject.speed = 1
        heroObject.speed = 1
        movingObject.speed = 1
        self.speed = 1
        
        if labelObject.children.count != 0{
            labelObject.removeAllChildren()
        }
        
        createBackground()
        createLowerBorderForNodes()
        createUpperBorderForNodes()
        createHero()
        createEngineFlames()
        
        score = 0
        scoreLabel.text = "0"
        levelLabel.isHidden = false
        highScoreTextLabel.isHidden = true
        
        showHighScore()
        
        timerForAddingCoin.invalidate()
        timerForAddingRedCoin.invalidate()
        timerForElectricGate.invalidate()
        timerForMine.invalidate()
        timerForShieldItem.invalidate()
        
        timerFunc()
        
    }

    func shakeAndFlashAnimation(view: SKView){
        
        //White flash
        
        let aView = UIView(frame: view.frame)
        aView.backgroundColor = UIColor.white
        view.addSubview(aView)
        
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
            aView.alpha = 0.0
        }) {
            (done) in
            aView.removeFromSuperview()
        }
        
        //Shake animation
        
        let shake = CAKeyframeAnimation(keyPath: "transform")
        shake.values = [
            NSValue(caTransform3D: CATransform3DMakeTranslation(-15, 5, 5)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(15, 5, 5))
    ]
        shake.autoreverses = true
        shake.repeatCount = 2
        shake.duration = 7/100
        
        view.layer.add(shake, forKey: nil)
    }

    override func didFinishUpdate() {
        
        heroEmitter.position = hero.position - CGPoint(x: 30, y: 5)
        shield.position = hero.position + CGPoint(x: 0, y: 0)
    }
}
