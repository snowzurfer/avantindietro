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
  fileprivate let commandsManager = CommandsManager()
  
  /// Reference to the undo button
  @IBOutlet weak var undoBtn: UIButton!

  // Used by the pinch gesture recognizer
  fileprivate var initialScale: simd_float3? = nil
  
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
    let pinchGesture =
      UIPinchGestureRecognizer(target: self,
                               action: #selector(handlePinch(sender:)))
    
    
    let gestureRecognizers = [
      singleTapGesture,
      pinchGesture
    ]
    
    for gesture in gestureRecognizers {
      sceneView.addGestureRecognizer(gesture)
    }
    
    // Setup gestures for the undo button
    undoBtn.addTarget(self, action: #selector(onUndoBtnTouchUpInside),
                      for: .touchUpInside)
    
    // Start with the undo button hidden
    fade(undoBtn, toAlpha: 0, withDuration: 0, andHide: true)
    
    // Register for updates from the commands manager
    commandsManager.delegate = self
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
  
  @objc fileprivate func onUndoBtnTouchUpInside(_ sender: UIButton) {
    updateQ.async(group: updateGrp) {
      self.commandsManager.undo()
    }
  }
  
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
  
  @objc fileprivate func handlePinch(sender: UIPinchGestureRecognizer) {
    let scale = simd_float3(Float(sender.scale))
    let state = sender.state
  
    updateQ.async(group: updateGrp) {
      switch state {
      case .began:
        self.initialScale = self.shipNode.simdScale
        
      case .changed:
        // Scale the ship as we go
        if let initialScale = self.initialScale {
          self.shipNode.simdScale = initialScale * scale
        }
        
      case .cancelled, .ended, .failed:
        if let initialScale = self.initialScale {
          // Only store the difference
          let diff = self.shipNode.simdScale - initialScale
          
          let scaleCmd = ScaleCommand(node: self.shipNode, scale: diff)
          self.commandsManager.pushNoExecution(scaleCmd)
        }
        
        self.initialScale = nil
        
      default:
        print("Unhandled case: \(state.rawValue)")
        self.initialScale = nil
        
      }
    }
  }
}

extension ViewController: CommandsManagerDelegate {
  
  func operationExecuted(_ manager: CommandsManager) {
    mainQ.async {
      if manager.areNoCommands {
        fade(self.undoBtn, toAlpha: 0, withDuration: 0.25, andHide: true)
      }
      else {
        fade(self.undoBtn, toAlpha: 1, withDuration: 0.25, andHide: false)
      }
    }
  }
}
