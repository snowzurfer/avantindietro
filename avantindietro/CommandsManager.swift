//
//  CommandsManager.swift
//  avantindietro
//
//  Created by Alberto Taiuti on 16/11/2018.
//  Copyright © 2018 Alberto Taiuti. All rights reserved.
//

import Foundation

/// Informs the delegates about pushes/pops of commands
///
/// Implement this to receive notification about changes in the stack of
/// commands
protocol CommandsManagerDelegate {
  func operationExecuted(_ manager: CommandsManager)
}

/// Keeps track of the executed commands and allows undoing them
class CommandsManager {
  
  /// The stack of commands used to implement the undo/redo featur
  ///
  /// This is complemented by utility functions which add/remove commands to it
  private var commands = Stack<UndoableCommand>()
  
  /// The delegate of the commands manager
  ///
  /// Register here to receive notification of events
  var delegate: CommandsManagerDelegate? = nil
  
  /// Register that a command has executed, so that it can be later undone
  public func pushNoExecution(_ cmd: UndoableCommand) {
    commands.push(cmd)
    
    if let delegate = delegate {
      delegate.operationExecuted(self)
    }
  }
  
  /// Undo the latest command, if any
  public func undo() {
    if let cmd = commands.pop() {
      cmd.undo()
      
      if let delegate = delegate {
        delegate.operationExecuted(self)
      }
    }
  }
  
  /// Return whether there are commands in the list or not
  public var areNoCommands: Bool {
    return commands.isEmpty
  }
}
