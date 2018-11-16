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
  
  // Create a queue and group which are used to update the scene
  fileprivate let updateQ = DispatchQueue(label: "updateQ")
  fileprivate let updateGrp = DispatchGroup.init()
  
  /// A reference to the ship node which is added by default in ARKit apps
  fileprivate var shipNode = SCNNode()
  
  /// The stack of commands used to implement the undo/redo featur
  ///
  /// This is complemented by utility functions which add/remove commands to it
  private let commandsManager = CommandsManager()
  
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
    
    // Get a reference to the ship node
    updateQ.async(group: updateGrp) {
      guard let ship = scene.rootNode.childNode(withName: "shipMesh",
                                                recursively: true) else
      {
        fatalError("Couldn't find the ship node")
      }
      self.shipNode = ship
    }
    
    // Setup the gestures to recognize
    let singleTapGesture =
      UITapGestureRecognizer(target: self,
                             action: #selector(handleSingleTap(sender:)))
    
    
    let gestureRecognizers = [
      singleTapGesture
    ]
    
    for gesture in gestureRecognizers {
      sceneView.addGestureRecognizer(gesture)
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  
    // Create a session configuration
    let configuration = ARWorldTrackingConfiguration()

    // Run the view's session
    sceneView.session.run(configuration)
    
    // Make sure that the task which we setup to find the ship has completed
    updateGrp.wait()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
  
    // Pause the view's session
    sceneView.session.pause()
  }
}

// Gestures-handling extension
extension ViewController {
  
  @objc fileprivate func handleSingleTap(sender: UITapGestureRecognizer) {
    // We only care about the end state for now
    if sender.state == .ended {
      guard let senderView = sender.view as? ARSCNView else {
        return
      }
      
      let tapLocation = sender.location(in: senderView)
      
      updateQ.async(group: updateGrp) {
        let results = self.sceneView.hitTest(tapLocation,
                                             types: [
                                              .existingPlaneUsingGeometry,
                                              .existingPlaneUsingExtent,
                                              .estimatedHorizontalPlane
          ])
        
        if results.isEmpty {
          return
        }
        
        let initialPos = self.shipNode.simdWorldPosition
        
        // Move the ship to the tap location
        self.shipNode.simdWorldPosition =
          simd_make_float3(results.first!.worldTransform.columns.3)
        
        let diff = self.shipNode.simdWorldPosition - initialPos
        let translationCmd = TranslateCommand(node: self.shipNode,
                                              translation: diff)
        
        self.commandsManager.pushNoExecution(translationCmd)
      }
    }
  }
}
