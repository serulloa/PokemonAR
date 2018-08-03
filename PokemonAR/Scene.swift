//
//  Scene.swift
//  PokemonAR
//
//  Created by Sergio Ulloa on 2/8/18.
//  Copyright © 2018 Sergio Ulloa. All rights reserved.
//

import SpriteKit
import ARKit
import GameplayKit

class Scene: SKScene {
    
    // MARK: - Properties
    let labelRemaining = SKLabelNode()
    var timer : Timer?
    var timerDisappear : Timer?
    var targetsCreated = 0
    var targetCount = 0 {
        didSet {
            labelRemaining.text = "Faltan \(targetCount)"
        }
    }
    let startTime = Date()
    let deathSound = SKAction.playSoundFileNamed("QuickDeath", waitForCompletion: false)
    var runaway : Bool = false
    let labelScore  = SKLabelNode()
    var score = 0 {
        didSet {
            labelScore.text = "Puntuación: \(score)"
        }
    }
    var bonus = false
    var timeFirstHit : Date?
    
    // MARK: - Methods
    override func didMove(to view: SKView) {
        labelRemaining.fontSize = 30
        labelRemaining.fontName = "Futura"
        labelRemaining.color = .white
        labelRemaining.position =  CGPoint(x: 0, y: view.frame.midY-50)
        addChild(labelRemaining)
        
        labelScore.fontSize = 30
        labelScore.fontName = "Futura"
        labelScore.color = .white
        labelScore.position = CGPoint(x: 0, y: view.frame.minY + 50)
        addChild(labelScore)
        
        targetCount = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { (timer) in
            self.createTarget()
        })
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        let hit = nodes(at: location)
        
        if let sprite = hit.first {
            timeFirstHit = Date()
            let scaleOut = SKAction.scale(to: 2, duration: 0.4)
            let fadeOut = SKAction.fadeOut(withDuration: 0.4)
            
            let remove = SKAction.removeFromParent()
            
            let actionGroup = SKAction.group([scaleOut, fadeOut, deathSound])
            let actionSequence = SKAction.sequence([actionGroup, remove])
            
            sprite.run(actionSequence)
            
            targetCount -= 1
            guard let timeHit = timeFirstHit else { return }
            
            if bonus && Int(Date().timeIntervalSince(timeHit)) > 5 {
                score += 500
            } else {
                score += 250
                bonus = true
            }
            
            if targetsCreated >= 25 && (targetCount == 0 || runaway) {
                gameOver()
            }
        } else {
            bonus = false
        }
    }
    
    // MARK: Custom methods
    func createTarget() {
        if targetsCreated >= 25 {
            timer?.invalidate()
            timer = nil
            return
        }
        
        targetsCreated += 1
        targetCount += 1
        
        guard let sceneView = view as? ARSKView else { return }
        
        let random = GKRandomSource.sharedRandom()
        let rotateX = simd_float4x4(SCNMatrix4MakeRotation(2.0 * Float.pi * random.nextUniform(), 1, 0, 0))
        let rotateY = simd_float4x4(SCNMatrix4MakeRotation(2.0 * Float.pi * random.nextUniform(), 0, 1, 0))
        let rotation = simd_mul(rotateX, rotateY)
        
        var translation = matrix_identity_float4x4
        translation.columns.3.z = randomFloat(min: 0.5, max: 2.0)
        
        let finalTransform = simd_mul(rotation, translation)
        
        let anchor = ARAnchor(transform: finalTransform)
        sceneView.session.add(anchor: anchor)
        
        timerDisappear = Timer.scheduledTimer(withTimeInterval: 12, repeats: true) { (timerDisappear) in
            sceneView.node(for: anchor)?.removeFromParent()
            self.runaway = true
        }
    }
    
    func gameOver() {
        labelRemaining.removeFromParent()
        
        let gameOverImage = SKSpriteNode(imageNamed: "gameover")
        addChild(gameOverImage)
        
        let timeTaken = Date().timeIntervalSince(startTime)
        
        
        let labelTimeTaken = SKLabelNode(text: "Te ha llevado: \(Int(timeTaken)) segundos")
        if targetCount > 0 {
            labelTimeTaken.text = "Se te ha escapado algún Pokémon"
        }
        labelTimeTaken.fontSize = 40
        labelTimeTaken.color = .white
        labelTimeTaken.position = CGPoint(x: +view!.frame.maxX - 50,
                                          y: -view!.frame.midY + 50)
        
        addChild(labelTimeTaken)
    }
    
    func randomFloat(min: Float, max: Float) -> Float {
        return (Float(arc4random()) / Float(UINT32_MAX)) * (max - min) + min
    }
    
}
