//
//  ScaleCommand.swift
//  avantindietro
//
//  Created by Alberto Taiuti on 16/11/2018.
//  Copyright © 2018 Alberto Taiuti. All rights reserved.
//

import SceneKit

/// Scale a SCNNode by an amount on all axes
class ScaleCommand: UndoableCommand {
  
  private let node: SCNNode
  private let scale: simd_float3
  
  init(node: SCNNode, scale: simd_float3) {
    self.node = node
    self.scale = scale
  }
  
  func undo() {
    node.simdScale -= scale
  }
  
  func execute() {
    node.simdScale += scale
  }
}
