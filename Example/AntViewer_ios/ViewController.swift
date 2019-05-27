//
//  ViewController.swift
//  AntViewer_ios
//
//  Created by Mykola Vaniurskyi on 04/17/2019.
//  Copyright (c) 2019 Mykola Vaniurskyi. All rights reserved.
//

import UIKit
import AntViewer_ios

class ViewController: UIViewController {
  
  var widget: AntWidget! {
    didSet {
      view.addSubview(widget)
      widget.bottomMargin = 100
      widget.rightMargin = 40
    }
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return [.portrait]
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    widget = AntWidget()
  }
  
  @IBAction func upPressed(_ sender: UIButton) {
    print(widget.bottomMargin)
    widget.bottomMargin += 1
    print(widget.bottomMargin)
  }
  
  @IBAction func downPressed(_ sender: UIButton) {
    print(widget.bottomMargin)
    widget.bottomMargin -= 1
    print(widget.bottomMargin)
  }
  
  @IBAction func leftPressed(_ sender: UIButton) {
    print(widget.rightMargin)
    widget.rightMargin += 1
    print(widget.rightMargin)
  }
  
  @IBAction func rightPressed(_ sender: UIButton) {
    print(widget.rightMargin)
    widget.rightMargin -= 1
    print(widget.rightMargin)
  }
  
  
  
}

