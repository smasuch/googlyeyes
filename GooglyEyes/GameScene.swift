//
//  GameScene.swift
//  EyeExam
//
//  Created by Steven Masuch on 2018-03-09.
//  Copyright © 2018 Zanopan. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
  private var leftEye = SKShapeNode(circleOfRadius: 100.0)
  private var leftPupil = SKShapeNode(circleOfRadius: 25.0)
  
  private var rightEye = SKShapeNode(circleOfRadius: 100.0)
  private var rightPupil = SKShapeNode(circleOfRadius: 25.0)
  
    
  override func didMove(to: SKView) {
    
    func setUpEye(eye: SKShapeNode, pupil: SKShapeNode) {
      eye.fillColor = UIColor.white
      self.insertChild(eye, at: 0)
      pupil.fillColor = UIColor.black
      pupil.physicsBody = SKPhysicsBody(circleOfRadius:25.0)
      if let physics = pupil.physicsBody {
        physics.affectedByGravity = true
        physics.allowsRotation = true
        physics.isDynamic = true;
        physics.linearDamping = 0.55
        physics.angularDamping = 0.55
        physics.restitution = 0.4
        physics.density = 0.7
        physics.friction = 0.1
      }
      pupil.position = eye.position
      self.insertChild(pupil, at: 1)
      let eyeContainer = SKPhysicsBody(edgeLoopFrom:CGPath(ellipseIn: CGRect.init(origin: CGPoint(x:-50.0, y:-100.0), size: CGSize(width: 100.0, height: 100.0)), transform: nil))
      eye.physicsBody = eyeContainer
    }
    
    // set up the inital scene
    self.physicsWorld.gravity = CGVector(dx: 0, dy: -180)
    setUpEye(eye: leftEye, pupil: leftPupil)
    setUpEye(eye: rightEye, pupil: rightPupil)
    
  }
  
  func moveLeftEyeToPoint(_ point: CGPoint) {
    let moveEye = SKAction.move(to:CGPoint(x: point.x * 2.0, y: point.y * 2.0), duration: 0.25)
    leftEye.run(moveEye)
  }
  
  func moveRightEyeToPoint(_ point: CGPoint) {
    let moveEye = SKAction.move(to:CGPoint(x: point.x * 2.0, y: point.y * 2.0), duration: 0.25)
    rightEye.run(moveEye)
  }
  
  
  override func update(_ currentTime: CFTimeInterval) {
    if !(leftEye.frame.contains(leftPupil.position)){
      leftPupil.position = leftEye.position
    }
    if !(rightEye.frame.contains(rightPupil.position)){
      rightPupil.position = rightEye.position
    }
  }
}
