//
//  TranslateCommand.swift
//  avantindietro
//
//  Created by Alberto Taiuti on 16/11/2018.
//  Copyright © 2018 Alberto Taiuti. All rights reserved.
//

import SceneKit

/// Translate a SCNNode by an amount
class TranslateCommand: UndoableCommand {
  
  private let node: SCNNode
  private let translation: simd_float3
  
  init(node: SCNNode, translation: simd_float3) {
    self.node = node
    self.translation = translation
  }
  
  func undo() {
    node.simdPosition -= translation
  }
  
  func execute() {
    node.simdPosition += translation
  }
}
