//
//  LiveCameraEyesView.swift
//  GooglyEyes
//
//  Created by Steven Masuch on 2018-03-09.
//  Copyright © 2018 Zanopan. All rights reserved.
//

import UIKit
import AVFoundation
import Vision
import SpriteKit
import Vision

/** @struct CameraControllerError
    @abstract Error enum to represent errors with the capture session
 */
enum CameraControllerError: Swift.Error {
  case captureSessionAlreadyRunning
  case captureSessionIsMissing
  case inputsAreInvalid
  case invalidOperation
  case noCamerasAvailable
  case unknown
}

/** @class LiveCameraEyesView
    @abstract A view that shows a live camera image with googly eyes superposed on people's eyes
 */
class LiveCameraEyesView: UIView, AVCaptureVideoDataOutputSampleBufferDelegate {
  
  var lastCameraImage: CGImage?
  var captureSession: AVCaptureSession?
  var frontCamera: AVCaptureDevice?
  var rearCamera: AVCaptureDevice?
  var outputData: AVCaptureVideoDataOutput?
  var imageView = UIImageView.init(frame: CGRect.zero)
  let context = CIContext()
  let eyesView = SKView()
  var eyesScene: GameScene?
  
  var recogCountdown = 30
  
  func startShowingCameraFeed() throws {
    // check if we've got permission
    // start the capture session
    captureSession = AVCaptureSession()
    let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
    let cameras = (discoverySession.devices.flatMap({$0}))
    guard !cameras.isEmpty else {
      throw CameraControllerError.noCamerasAvailable
    }
    
    for camera in cameras {
      if camera.position == .front {
        self.frontCamera = camera
      }
      
      if camera.position == .back {
        self.rearCamera = camera
        
        try camera.lockForConfiguration()
        camera.focusMode = .continuousAutoFocus
        camera.unlockForConfiguration()
      }
    }
    
    if let frontCamera = self.frontCamera {
      let frontCameraInput = try! AVCaptureDeviceInput(device: frontCamera)
      
      if (captureSession?.canAddInput(frontCameraInput))! {
        captureSession?.addInput(frontCameraInput)
      }
    }
  
    
    let outputData = AVCaptureVideoDataOutput()
    outputData.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)]
    let captureSessionQueue = DispatchQueue(label: "CameraSessionQueue", attributes: [])
    outputData.setSampleBufferDelegate(self, queue: captureSessionQueue)
    captureSession?.addOutput(outputData)
    guard let connection = outputData.connection(with: AVMediaType.video) else { return }
    guard connection.isVideoOrientationSupported else { return }
    connection.videoOrientation = .portrait
    
    imageView.frame = self.bounds
    self.addSubview(imageView)
    
    captureSession!.startRunning()
    
    // show the spritekit eyes on top
    eyesView.frame = self.bounds
    eyesView.allowsTransparency = true
    self.addSubview(eyesView)
    eyesScene = SKScene(fileNamed: "GameScene") as? GameScene
    if let eyesScene = eyesScene {
      // Set the scale mode to scale to fit the window
      eyesScene.scaleMode = .aspectFill
      
      // Present the scene
      eyesView.presentScene(eyesScene)
    }
    
    eyesView.ignoresSiblingOrder = true
    
    eyesView.showsFPS = true
    eyesView.showsNodeCount = true
  }
  
  
  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
    let ciImage = CIImage(cvPixelBuffer: imageBuffer)
    guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
    DispatchQueue.main.async { [unowned self] in
      self.imageView.image = UIImage(cgImage: cgImage)
      
      self.recogCountdown = self.recogCountdown - 1
      
      if self.recogCountdown == 0 {
        let faceLandmarksRequest = VNDetectFaceLandmarksRequest(completionHandler: self.handleFaceFeatures)
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: .up ,options: [:])
        do {
          try requestHandler.perform([faceLandmarksRequest])
        } catch {
          print(error)
        }
        
        self.recogCountdown = 12
      }
      
      
    }
  }
  
  func handleFaceFeatures(request: VNRequest, errror: Error?) {
    guard let observations = request.results as? [VNFaceObservation] else {
      print("oh boy, we got a weird observation here")
      return
    }
    
    for face in observations {
      let w = face.boundingBox.size.width * self.bounds.size.width
      let h = face.boundingBox.size.height * self.bounds.size.height
      let x = face.boundingBox.origin.x * self.bounds.size.width
      let y = face.boundingBox.origin.y * self.bounds.size.height
      
      if let leftEye = face.landmarks?.leftEye, let firstPoint = leftEye.normalizedPoints.first {
       
        let actualEyePointX = x + firstPoint.x * w
        let actualEyePointY = y + firstPoint.y * h
        self.eyesScene?.moveLeftEyeToPoint(CGPoint(x: actualEyePointX, y: actualEyePointY))
      }
      
      if let rightEye = face.landmarks?.rightEye, let firstPoint = rightEye.normalizedPoints.first {
        
        let actualEyePointX = x + firstPoint.x * w
        let actualEyePointY = y + firstPoint.y * h
        self.eyesScene?.moveRightEyeToPoint(CGPoint(x: actualEyePointX, y: actualEyePointY))
      }
    }
  }
  
  
  func compositeImage() {
    // get the position & size of the eyes in the image, if any
    // take the latest camera image and draw the eyes on top
    // put it into the view
  }
  
  override func draw(_ rect: CGRect) {
    // draw the last camera image we have
    
  }
  
}
