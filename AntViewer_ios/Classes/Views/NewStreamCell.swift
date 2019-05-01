//
//  CollectionViewCell.swift
//  controllers fot kolya
//
//  Created by Maryan Luchko on 12/17/18.
//  Copyright © 2018 Maryan Luchko. All rights reserved.
//

import UIKit

public class NewStreamCell: UICollectionViewCell {
  
  var gradientLayer: CAGradientLayer = {
    let gradient = CAGradientLayer()
    gradient.colors = [UIColor.black.withAlphaComponent(0.8).cgColor, UIColor.black.withAlphaComponent(0.1).cgColor, UIColor.black.withAlphaComponent(0.1).cgColor, UIColor.black.withAlphaComponent(0.85).cgColor]
    gradient.locations = [0, 0.3, 0.7, 1]
    return gradient
  }()
  
  @IBOutlet public weak var liveLabel: UILabel!
  @IBOutlet public weak var startTimeLabel: UILabel!
  @IBOutlet public weak var streamDurationLabel: UILabel!
  @IBOutlet public weak var viewersCountLabel: UILabel!
  @IBOutlet public weak var imagePlaceholder: UIImageView!
  @IBOutlet public weak var streamNameLabel: UILabel!
  @IBOutlet public weak var startTimeView: UIView!
  @IBOutlet public weak var streamDurationView: UIView!
  @IBOutlet weak var gradientView: UIView! {
    didSet {
      gradientView.layer.addSublayer(gradientLayer)
      gradientLayer.frame = gradientView.bounds
    }
  }
  
  override public func layoutSubviews() {
    super.layoutSubviews()
    //FIXME: Gradient updates with delay
    gradientLayer.frame = gradientView.bounds
  }
  
}
