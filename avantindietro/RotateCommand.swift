//
//  RotateCommand.swift
//  avantindietro
//
//  Created by Alberto Taiuti on 16/11/2018.
//  Copyright © 2018 Alberto Taiuti. All rights reserved.
//

import SceneKit

/// Rotate a SCNNode by a quaternion
class RotateCommand: UndoableCommand {
  
  private let node: SCNNode
  private let rotation: simd_quatf
  
  init(node: SCNNode, rotation: simd_quatf) {
    self.node = node
    self.rotation = rotation
  }
  
  func undo() {
    node.simdOrientation *= rotation.inverse
  }
  
  func execute() {
    node.simdOrientation *= rotation
  }
}
