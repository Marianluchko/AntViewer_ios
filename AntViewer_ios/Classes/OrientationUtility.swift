//
//  OrientationUtility.swift
//  viewer-module
//
//  Created by Mykola Vaniurskyi on 12/6/18.
//  Copyright © 2018 Mykola Vaniurskyi. All rights reserved.
//

import UIKit

struct OrientationUtility {
  
  static var currentOrientatin: UIInterfaceOrientationMask {
    switch UIApplication.shared.statusBarOrientation {
    case .portrait:
      return .portrait
    case .portraitUpsideDown:
      return .portraitUpsideDown
    case .landscapeLeft:
      return .landscapeLeft
    case .landscapeRight:
      return .landscapeRight
    default:
      return UIInterfaceOrientationMask.allButUpsideDown
    }
  }
  
  static var isPortrait: Bool {
    return OrientationUtility.currentOrientatin == .portrait
  }
  
  static var isLandscape: Bool {
    return OrientationUtility.currentOrientatin == .landscapeLeft || OrientationUtility.currentOrientatin == .landscapeRight
  }
  
  static func rotateToOrientation(_ orientation: UIInterfaceOrientation) {
    UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
  }
  
}
