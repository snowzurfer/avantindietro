//
//  Command.swift
//  avantindietro
//
//  Created by Alberto Taiuti on 16/11/2018.
//  Copyright © 2018 Alberto Taiuti. All rights reserved.
//

import Foundation

/// The base protocol to implement the Command component of the Command
/// Design Pattern. Executes only
protocol Command {
  func execute()
}

/// Extends the Command protocol to implement an undo feature
protocol UndoableCommand: Command {
  func undo()
}
