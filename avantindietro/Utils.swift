//
//  Utils.swift
//  avantindietro
//
//  Created by Alberto Taiuti on 16/11/2018.
//  Copyright © 2018 Alberto Taiuti. All rights reserved.
//

import UIKit

/// Fade a UIView and hide/show it at the end
func fade(_ view: UIView, toAlpha alpha: CGFloat,
          withDuration duration: TimeInterval, andHide: Bool,
          _ callback: (() -> Void)? = nil) {
  UIView.animate(withDuration: duration, animations: {
    if !andHide {
      view.isHidden = false
    }
    
    view.alpha = alpha
  }) { (_) in
    view.isHidden = andHide
    if let cb = callback {
      cb()
    }
  }
}

/// Utility to retrieve the main queue, DispatchQueue.main
var mainQ: DispatchQueue {
  return DispatchQueue.main
}
