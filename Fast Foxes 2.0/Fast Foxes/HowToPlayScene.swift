import SpriteKit

class HowToPlayScene: SKScene {
    
    override func didMove(to view: SKView) {
        self.scaleMode = .aspectFill
        self.backgroundColor = .black
        
        // Instructions label
        let instructionsLabel = SKLabelNode(text: "How to Play")
        instructionsLabel.fontSize = 64
        instructionsLabel.fontName = "HelveticaNeue-Bold"
        instructionsLabel.fontColor = .white
        instructionsLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height - 150)
        addChild(instructionsLabel)
        
        // Instructions text
        let instructionText = SKLabelNode(text: "Tilt phone to move fox left and right")
        let instructionText2 = SKLabelNode(text:"Avoid the rocks, and collect the fish!")
        let instructionText3 = SKLabelNode(text:"Small fish are worth 10 points, big fish are worth 20!")
        
        instructionText.fontSize = 32
        instructionText.fontName = "HelveticaNeue"
        instructionText.fontColor = .white
        instructionText.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 + 50)
        instructionText.horizontalAlignmentMode = .center
        instructionText.verticalAlignmentMode = .center
        
        instructionText2.fontSize = 32
        instructionText2.fontName = "HelveticaNeue"
        instructionText2.fontColor = .white
        instructionText2.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        instructionText2.horizontalAlignmentMode = .center
        instructionText2.verticalAlignmentMode = .center
        
        instructionText3.fontSize = 32
        instructionText3.fontName = "HelveticaNeue"
        instructionText3.fontColor = .white
        instructionText3.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 - 50)
        instructionText3.horizontalAlignmentMode = .center
        instructionText3.verticalAlignmentMode = .center
        
        addChild(instructionText)
        addChild(instructionText2)
        addChild(instructionText3)
        
        adjustTextSizeToFit(instructionText)
        adjustTextSizeToFit(instructionText2)
        adjustTextSizeToFit(instructionText3)
        
        // Back to Main Menu button
        let backButton = SKLabelNode(text: "Back to Main Menu")
        backButton.name = "BackButton"
        backButton.fontSize = 44
        backButton.fontName = "HelveticaNeue"
        backButton.fontColor = .white
        backButton.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 - 200)
        addChild(backButton)
    }
    
    func adjustTextSizeToFit(_ label: SKLabelNode) {
            let maxWidth = self.size.width - 40 // Add some padding
            let labelWidth = label.frame.width
            
            if labelWidth > maxWidth {
                let scaleFactor = maxWidth / labelWidth
                label.fontSize = label.fontSize * scaleFactor
            }
        }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let tappedNodes = nodes(at: location)
            
            if tappedNodes.contains(where: { $0.name == "BackButton" }) {
                // Directly initialize MainMenuScene
                let mainMenuScene = MainMenuScene(size: self.size)
                mainMenuScene.scaleMode = .aspectFill
                self.view?.presentScene(mainMenuScene, transition: .fade(withDuration: 1.0))
            }
        }
    }
}
