//
//  ViewController.swift
//  avantindietro
//
//  Created by Alberto Taiuti on 16/11/2018.
//  Copyright © 2018 Alberto Taiuti. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

  @IBOutlet var sceneView: ARSCNView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  
    // Set the view's delegate
    sceneView.delegate = self
  
    // Show statistics such as fps and timing information
    sceneView.showsStatistics = true
  
    // Create a new scene
    let scene = SCNScene(named: "art.scnassets/ship.scn")!
  
    // Set the scene to the view
    sceneView.scene = scene
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  
    // Create a session configuration
    let configuration = ARWorldTrackingConfiguration()

    // Run the view's session
    sceneView.session.run(configuration)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
  
    // Pause the view's session
    sceneView.session.pause()
  }
}
