//
//  Stack.swift
//  avantindietro
//
//  Created by Alberto Taiuti on 16/11/2018.
//  Copyright © 2018 Alberto Taiuti. All rights reserved.
//

import Foundation

/// Implementation of a stack data structure
///
/// The underlying backing data structure is an array
struct Stack<Type> {
  
  private var array = [Type]()
  
  public mutating func push(_ element: Type) {
    array.append(element)
  }
  
  public mutating func pop() -> Type? {
    return array.popLast()
  }
  
  public var top: Type? {
    return array.last
  }
  
  public var count: Int {
    return array.count
  }
  
  public var isEmpty: Bool {
    return array.isEmpty
  }
}
