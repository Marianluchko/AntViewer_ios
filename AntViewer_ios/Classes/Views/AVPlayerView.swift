//
//  AVPlayerView.swift
//  
//
//  Created by Maryan Luchko on 3/13/19.
//

import UIKit
import AVFoundation

public class AVPlayerView: UIView {
  override public class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}
