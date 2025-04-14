import SpriteKit

class MainMenuScene: SKScene {
    
    override func didMove(to view: SKView) {
        self.scaleMode = .aspectFill
        self.backgroundColor = .black
        
        // Game title at the top center
        let titleLabel = SKLabelNode(text: "Fast Foxes")
        titleLabel.fontSize = 64
        titleLabel.fontName = "HelveticaNeue-Bold"
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height - 150)
        addChild(titleLabel)
        
        // Play button at center
        let playButton = SKLabelNode(text: "Play")
        playButton.name = "PlayButton"
        playButton.fontSize = 44
        playButton.fontName = "HelveticaNeue"
        playButton.fontColor = .white
        playButton.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 + 30)
        addChild(playButton)
        
        // How to Play button
        let howToPlayButton = SKLabelNode(text: "How to Play")
        howToPlayButton.name = "HowToPlayButton"
        howToPlayButton.fontSize = 44
        howToPlayButton.fontName = "HelveticaNeue"
        howToPlayButton.fontColor = .white
        howToPlayButton.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 - 40)
        addChild(howToPlayButton)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let tappedNodes = nodes(at: location)
            
            if tappedNodes.contains(where: { $0.name == "PlayButton" }) {
                if let gameScene = SKScene(fileNamed: "GameScene") {
                    gameScene.scaleMode = .aspectFill
                    self.view?.presentScene(gameScene, transition: .fade(withDuration: 1.0))
                }
            } else if tappedNodes.contains(where: { $0.name == "HowToPlayButton" }) {
                let howToPlayScene = HowToPlayScene(size: self.size) // Direct initialization
                howToPlayScene.scaleMode = .aspectFill
                self.view?.presentScene(howToPlayScene, transition: .fade(withDuration: 1.0))
            }
        }
    }
}
