//
//  CameraEyesViewController.swift
//  GooglyEyes
//
//  Created by Steven Masuch on 2018-03-09.
//  Copyright © 2018 Zanopan. All rights reserved.
//



import UIKit

/// The base view controller for the app. Shows a camera image with googly eyes superimposed on it.
class CameraEyesViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    let cameraView = LiveCameraEyesView(frame: self.view.bounds)
    self.view.addSubview(cameraView)
    try! cameraView.startShowingCameraFeed()
  }
  
}

