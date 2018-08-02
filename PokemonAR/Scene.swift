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
    var targetsCreated = 0
    var targetCount = 0 {
        didSet {
            labelRemaining.text = "Faltan \(targetCount)"
        }
    }
    
    // MARK: - Methods
    override func didMove(to view: SKView) {
        labelRemaining.fontSize = 30
        labelRemaining.fontName = "Futura"
        labelRemaining.color = .white
        labelRemaining.position =  CGPoint(x: 0, y: view.frame.midY-50)
        
        addChild(labelRemaining)
        
        targetCount = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { (timer) in
            self.createTarget()
        })
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
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
        translation.columns.3.z = -1.5
        
        let finalTransform = simd_mul(rotation, translation)
        
        let anchor = ARAnchor(transform: finalTransform)
        sceneView.session.add(anchor: anchor)
    }
}
