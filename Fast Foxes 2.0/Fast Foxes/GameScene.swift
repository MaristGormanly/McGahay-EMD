import SpriteKit
import CoreMotion
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player: SKSpriteNode!
    var platforms: [SKSpriteNode] = []
    var tokens: [SKSpriteNode] = []
    var lanePositions: [CGFloat] = []
    var currentLane = 1
    let motionManager = CMMotionManager()
    var xAcceleration: CGFloat = 0.0
    var speedForward: CGFloat = 300.0
    let laneChangeThreshold: CGFloat = 0.25
    var laneCooldown = false
    var lastPlatformY: CGFloat = 0

    var scoreLabel: SKLabelNode!
    var score = 0
    var highestY: CGFloat = 0

    let playerCategory: UInt32 = 0x1 << 0
    let platformCategory: UInt32 = 0x1 << 1
    let tokenCategory: UInt32 = 0x1 << 2

    var isGameActive = true
    var gameOverLabel: SKLabelNode!

    var playAgainButton: SKLabelNode!
    var mainMenuButton: SKLabelNode!
    
    var audioPlayer: AVAudioPlayer?

    // MARK: Life Cycle
    
    override func didMove(to view: SKView) {
        isUserInteractionEnabled = true
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        setupCamera()
        setupLanes()
        setupPlayer()
        setupScoreLabel()
        spawnInitialPlatforms()
        spawnInitialTokens()
        
        self.backgroundColor = UIColor(red: 34/255, green: 139/255, blue: 34/255, alpha: 1.0)


        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { data, error in
            if let accelerometerData = data {
                self.xAcceleration = CGFloat(accelerometerData.acceleration.x)
            }
        }

        player.physicsBody?.contactTestBitMask = 0
        run(.wait(forDuration: 1.0)) {
            self.player.physicsBody?.contactTestBitMask = self.platformCategory | self.tokenCategory
        }
    }

    // MARK: Setup Methods
    func setupCamera() {
        if camera == nil {
            let cam = SKCameraNode()
            camera = cam
            addChild(cam)
        }
    }

    func setupLanes() {
        let screenWidth = size.width
        lanePositions = [
            screenWidth * 0.25,
            screenWidth * 0.5,
            screenWidth * 0.75
        ]
    }

    func setupPlayer() {
        player = SKSpriteNode(imageNamed: "fox")
        player.size = CGSize(width: 150, height: 150)
        player.position = CGPoint(x: lanePositions[currentLane], y: 100)
        player.zPosition = 1

        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.velocity = CGVector(dx: 0, dy: speedForward)
        player.physicsBody?.categoryBitMask = playerCategory
        player.physicsBody?.contactTestBitMask = platformCategory | tokenCategory
        player.physicsBody?.collisionBitMask = 0

        addChild(player)
        highestY = player.position.y
    }

    func setupScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.fontSize = 32
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: 0, y: size.height / 2 - 80)
        scoreLabel.zPosition = 100
        camera?.addChild(scoreLabel)
        updateScoreLabel()
    }
    
    // MARK: Spawning Methods
    func spawnInitialPlatforms() {
        lastPlatformY = 600
        for _ in 0..<6 {
            spawnPlatformsRow(atY: lastPlatformY)
            lastPlatformY += 500
        }
    }

    func spawnInitialTokens() {
        lastPlatformY = 600
        for _ in 0..<6 {
            spawnTokensRow(atY: lastPlatformY)
            lastPlatformY += 500
        }
    }

    func spawnPlatformsRow(atY y: CGFloat) {
        let lanes = lanePositions.shuffled()
        for i in 0..<Int.random(in: 1...2) {
            let platform = SKSpriteNode(imageNamed: "rock")
            platform.size = CGSize(width: 150, height: 150)
            platform.position = CGPoint(x: lanes[i], y: y)
            platform.zPosition = -1

            platform.physicsBody = SKPhysicsBody(rectangleOf: platform.size)
            platform.physicsBody?.isDynamic = false
            platform.physicsBody?.categoryBitMask = platformCategory
            platform.physicsBody?.contactTestBitMask = playerCategory
            platform.physicsBody?.collisionBitMask = 0

            addChild(platform)
            platforms.append(platform)
        }
    }

    func spawnTokensRow(atY y: CGFloat) {
        let lanes = lanePositions.shuffled()
        for i in 0..<Int.random(in: 1...2) {
            let laneX = lanes[i]

            // Only spawn if there's no platform in this lane at this y
            if platforms.first(where: { $0.position.x == laneX && abs($0.position.y - y) < 50 }) == nil {

                // 10% chance to spawn a big fish
                let isBigFish = Int.random(in: 0..<10) == 0

                let tokenImage = isBigFish ? "big_fish" : "fish"
                let tokenSize = isBigFish ? CGSize(width: 140, height: 80) : CGSize(width: 100, height: 56)
                let token = SKSpriteNode(imageNamed: tokenImage)
                token.size = tokenSize
                token.position = CGPoint(x: laneX, y: y)
                token.zPosition = 0

                token.physicsBody = SKPhysicsBody(rectangleOf: token.size)
                token.physicsBody?.isDynamic = false
                token.physicsBody?.categoryBitMask = tokenCategory
                token.physicsBody?.contactTestBitMask = playerCategory
                token.physicsBody?.collisionBitMask = 0

                token.name = isBigFish ? "big_fish" : "fish"

                addChild(token)
                tokens.append(token)
            }
        }
    }
    // MARK: Game Update methods
    override func update(_ currentTime: TimeInterval) {
        guard isGameActive else { return }

        player.position.y += 3
        camera?.position = CGPoint(x: size.width / 2, y: player.position.y)

//        let newScore = Int(player.position.y / 100)
//        if newScore > score {
//            score = newScore
//            updateScoreLabel()
//        }

        handleLaneChange()
        recyclePlatforms()
    }

    func handleLaneChange() {
        guard !laneCooldown else { return }

        if xAcceleration < -laneChangeThreshold && currentLane > 0 {
            currentLane -= 1
            moveToLane(currentLane)
        } else if xAcceleration > laneChangeThreshold && currentLane < lanePositions.count - 1 {
            currentLane += 1
            moveToLane(currentLane)
        }
    }

    func moveToLane(_ lane: Int) {
        let action = SKAction.moveTo(x: lanePositions[lane], duration: 0.2)
        action.timingMode = .easeInEaseOut
        player.run(action)
        laneCooldown = true
        run(.wait(forDuration: 0.3)) {
            self.laneCooldown = false
        }
    }

    func recyclePlatforms() {
        for platform in platforms where platform.position.y + 100 < player.position.y - size.height / 2 {
            platform.removeFromParent()
            if let index = platforms.firstIndex(of: platform) {
                platforms.remove(at: index)
                spawnPlatformsRow(atY: lastPlatformY)
                lastPlatformY += 500
            }
        }

        for token in tokens where token.position.y + 40 < player.position.y - size.height / 2 {
            token.removeFromParent()
            if let index = tokens.firstIndex(of: token) {
                tokens.remove(at: index)
                spawnTokensRow(atY: lastPlatformY)
                lastPlatformY += 500
            }
        }
    }

    
    // MARK: Token Cellection Methods
    
    func didBegin(_ contact: SKPhysicsContact) {
        if isGameActive {
            if (contact.bodyA.categoryBitMask == playerCategory && contact.bodyB.categoryBitMask == platformCategory) ||
               (contact.bodyB.categoryBitMask == playerCategory && contact.bodyA.categoryBitMask == platformCategory) {
                triggerGameOver()
            } else if (contact.bodyA.categoryBitMask == playerCategory && contact.bodyB.categoryBitMask == tokenCategory) ||
                      (contact.bodyB.categoryBitMask == playerCategory && contact.bodyA.categoryBitMask == tokenCategory) {
                collectToken(contact)
            }
        }
    }

    func collectToken(_ contact: SKPhysicsContact) {
        let token = contact.bodyA.categoryBitMask == tokenCategory ? contact.bodyA.node : contact.bodyB.node
        if let tokenNode = token {
            tokenNode.removeFromParent()

            if tokenNode.name == "big_fish" {
                score += 30
                playSound(named: "big_fish_sound.mp3")  // big fish sound
            } else {
                score += 10
                playSound(named: "fish_sound.mp3")  // regular fish sound
            }
            updateScoreLabel()
        }
    }

    // MARK: Sound & Score Methods
    func playSound(named name: String) {
        let path = Bundle.main.path(forResource: name, ofType: nil)
        guard let url = URL(string: path ?? "") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error)")
        }
    }
    
    func updateScoreLabel() {
        scoreLabel.text = "Score: \(score)"
    }

    // MARK: Game Over Handling
    func triggerGameOver() {
        playSound(named: "gameover.mp3")  // game over sound
        isGameActive = false
        player.removeAllActions()
        player.physicsBody?.velocity = .zero

        gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.fontName = "AvenirNext-Bold"
        gameOverLabel.fontSize = 48
        gameOverLabel.fontColor = .red
        gameOverLabel.zPosition = 100
        gameOverLabel.position = CGPoint(x: size.width / 2, y: player.position.y + 160)
        addChild(gameOverLabel)

        playAgainButton = SKLabelNode(text: "Play Again")
        playAgainButton.fontName = "AvenirNext-Bold"
        playAgainButton.fontSize = 36
        playAgainButton.fontColor = .green
        playAgainButton.position = CGPoint(x: size.width / 2, y: player.position.y + 80)
        playAgainButton.zPosition = 100
        addChild(playAgainButton)

        mainMenuButton = SKLabelNode(text: "Main Menu")
        mainMenuButton.fontName = "AvenirNext-Bold"
        mainMenuButton.fontSize = 36
        mainMenuButton.fontColor = .blue
        mainMenuButton.position = CGPoint(x: size.width / 2, y: player.position.y + 20)
        mainMenuButton.zPosition = 100
        addChild(mainMenuButton)
    }

    // MARK: Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isGameActive {
            for touch in touches {
                let location = touch.location(in: self)

                if playAgainButton.contains(location) {
                    restartGame()
                } else if mainMenuButton.contains(location) {
                    goToMainMenu()
                }
            }
        }
    }
    
    // MARK: - Restart & Main Menu methods
    func restartGame() {
        score = 0
        highestY = 0
        updateScoreLabel()

        platforms.forEach { $0.removeFromParent() }
        tokens.forEach { $0.removeFromParent() }
        platforms.removeAll()
        tokens.removeAll()

        player.position = CGPoint(x: lanePositions[currentLane], y: 100)
        player.physicsBody?.velocity = CGVector(dx: 0, dy: speedForward)

        camera?.position = CGPoint(x: size.width / 2, y: player.position.y)

        lastPlatformY = 600
        for _ in 0..<6 {
            spawnPlatformsRow(atY: lastPlatformY)
            spawnTokensRow(atY: lastPlatformY)
            lastPlatformY += 500
        }

        playAgainButton.removeFromParent()
        mainMenuButton.removeFromParent()
        gameOverLabel.removeFromParent() // <-- this line removes the lingering label

        isGameActive = true
    }


    func goToMainMenu() {
        let mainMenu = MainMenuScene(size: self.size)
        view?.presentScene(mainMenu, transition: .flipHorizontal(withDuration: 0.5))
    }
}
