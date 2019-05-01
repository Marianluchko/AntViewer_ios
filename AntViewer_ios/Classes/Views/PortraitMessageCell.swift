//
//  PortraitMessageCell.swift
//  viewer-module
//
//  Created by Mykola Vaniurskyi on 12/7/18.
//  Copyright © 2018 Mykola Vaniurskyi. All rights reserved.
//

import UIKit

public protocol MessageSupportable {
  var avatarImageView: UIImageView! { get set }
  var nameLabel: UILabel! { get set }
  var messageLabel: UILabel! { get set }
}

public class PortraitMessageCell: UITableViewCell, MessageSupportable {
  
  @IBOutlet public weak var avatarImageView: UIImageView!
  @IBOutlet public weak var nameLabel: UILabel!
  @IBOutlet public weak var messageLabel: UILabel!
  
}
