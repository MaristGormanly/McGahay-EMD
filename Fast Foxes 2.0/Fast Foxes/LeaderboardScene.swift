import SpriteKit

class LeaderboardScene: SKScene {
    
    override func didMove(to view: SKView) {
        self.scaleMode = .aspectFill 
        self.backgroundColor = .black
        
        // Title label
        let titleLabel = SKLabelNode(text: "Leaderboard")
        titleLabel.fontSize = 60
        titleLabel.fontName = "HelveticaNeue"
        titleLabel.position = CGPoint(x: self.frame.midX, y: self.frame.maxY - 200)
        addChild(titleLabel)
        
        // Get the top 5 scores from UserDefaults
        let topScores = getTopScores()
        
        // Display the top scores
        for (index, score) in topScores.enumerated() {
            let scoreLabel = SKLabelNode(text: "Rank \(index + 1): \(score)")
            scoreLabel.fontSize = 40
            scoreLabel.fontName = "HelveticaNeue"
            scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.maxY - CGFloat(300 + (index * 50)))
            addChild(scoreLabel)
        }
        
        // Back button at the upper-left corner
        let backButton = SKLabelNode(text: "Back")
        backButton.name = "BackButton"
        backButton.fontSize = 50
        backButton.fontName = "HelveticaNeue"
        backButton.position = CGPoint(x: self.frame.minX + 50, y: self.frame.maxY - 50)  // Positioned in the upper-left corner
        addChild(backButton)
    }
    
    // Helper function to retrieve the top scores
    func getTopScores() -> [Int] {
        // Retrieve the top scores from UserDefaults
        let savedScores = UserDefaults.standard.array(forKey: "TopScores") as? [Int] ?? []
        
        // Sort the scores in descending order and return the top 5 (or fewer if not enough scores)
        return savedScores.sorted(by: >).prefix(5).map { $0 }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let nodes = self.nodes(at: location)
            
            // If the back button is touched, go back to the main menu
            if nodes.first(where: { $0.name == "BackButton" }) != nil {
                let mainMenuScene = MainMenuScene(size: self.size)
                mainMenuScene.scaleMode = .aspectFill
                self.view?.presentScene(mainMenuScene, transition: SKTransition.fade(withDuration: 1.0))
            }
        }
    }
}
