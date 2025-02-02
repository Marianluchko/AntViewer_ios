//
//  AntWidget.swift
//  viewer-module
//
//  Created by Mykola Vaniurskyi on 12/16/18.
//  Copyright © 2018 Mykola Vaniurskyi. All rights reserved.
//

import UIKit
import AntViewerExt

public class AntWidget: UIView {
  
  private let kCONTENT_XIB_NAME = "AntWidget"
  
  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var streamNameLabel: UILabel!
  @IBOutlet weak var viewersCountLabel: UILabel!
  @IBOutlet weak var newStreamLabel: UILabel!
  
  @IBOutlet weak var antButton: UIButton! {
    didSet {
      antButton.layer.cornerRadius = antButton.bounds.height/2
      antButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
      antButton.layer.shadowOffset = CGSize(width: -3, height: 2)
      antButton.layer.shadowOpacity = 0.7
      
    }
  }
  
  private var tongueWidth: CGFloat {
    return 274
  }
  
  @IBOutlet weak var tongueView: UIView!
  @IBOutlet weak var tongueViewWidth: NSLayoutConstraint!
  
  private var shownStream: AntViewerExt.Stream? {
    didSet {
      streamNameLabel.text = shownStream?.title
      if let count = shownStream?.viewersCount {
        viewersCountLabel.text = "\(count) Viewers"
      }
      
      if shownStream != nil {
        tongueView.transform = CGAffineTransform(translationX: tongueWidth, y: 0)
        tongueViewWidth.constant = tongueWidth
        self.tongueView.isHidden = false
        self.increaseWidgetFrame()
        UIView.animate(withDuration: 0.3, animations: {
          self.tongueView.transform = CGAffineTransform(translationX: 0, y: 0)
          self.tongueView.frame.size.width = self.tongueWidth
          self.tongueView.isHidden = false
          self.tongueView.layoutIfNeeded()
        })
      } else {
        
        UIView.animate(withDuration: 0.3, animations: {
          self.tongueView.transform = CGAffineTransform(translationX: self.tongueWidth, y: 0)
          self.tongueView.frame.size.width = 0
        }) { (value) in
          self.increaseWidgetFrame(false)
          self.tongueViewWidth.constant = 0
          self.tongueView.isHidden = true
          self.tongueView.transform = CGAffineTransform(translationX: 0, y: 0)
        }
      }
    }
  }
  
  private var dataSource: DataSource? {
    didSet {
      dataSource?.startUpdateingStreams()
    }
  }
  
  private var shownIds: [Int] {
    set {
      UserDefaults.standard.set(newValue, forKey: "shownIds")
    }
    get {
      return UserDefaults.standard.array(forKey: "shownIds") as? [Int] ?? []
    }
  }
  
  private var watchedVods: [Int] {
    set {
      UserDefaults.standard.set(newValue, forKey: "viewedVods")
    }
    get {
      return UserDefaults.standard.array(forKey: "viewedVods") as? [Int] ?? []
    }
  }
  
  private var initialFrame: CGRect = .zero
  
  var superViewRect: CGRect {
    return superview?.bounds ?? UIScreen.main.bounds
  }
  
  @objc
  public var rightMargin: Int {
    get {
      let rightMargin = superViewRect.width - (initialFrame.origin.x + initialFrame.width)
      return Int(rightMargin)
    }
    set {
      let newX = superViewRect.width - (CGFloat(newValue) + initialFrame.width)
      initialFrame.origin.x = newX
      frame.origin.x = initialFrame.origin.x - tongueViewWidth.constant
    }
  }
  
  @objc
  public var bottomMargin: Int {
    get {
      let bottomMargin = superViewRect.height - (initialFrame.origin.y + initialFrame.height)
      return Int(bottomMargin)
    }
    set {
      let newY = superViewRect.height - (CGFloat(newValue) + initialFrame.height)
      initialFrame.origin.y = newY
      frame.origin.y = initialFrame.origin.y
    }
  }
  
  @objc
  public var isLightMode = false {
    didSet {
      updateColours()
    }
  }
  
  @objc
  public var onViewerAppear: ((NSDictionary) -> Void)?
  
  @objc
  public var onViewerDisappear: ((NSDictionary) -> Void)?
  
  public
  convenience init() {
    let space: CGFloat = 20
    let height: CGFloat = 75
    let rect = UIScreen.main.bounds
    let newX = rect.width - space - height
    let newY = rect.height - space - height
    self.init(frame: CGRect(x: newX, y: newY, width: height, height: height))

  }
  
  private override init(frame: CGRect) {
    initialFrame = frame
    super.init(frame: frame)
    commonInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initialFrame = frame
    commonInit()
  }
  
  private func commonInit() {
    Bundle(for: type(of: self)).loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
    contentView.fixInView(self)
    backgroundColor = .clear
    dataSource = DataSource.shared
    NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: NSNotification.Name(rawValue: "StreamsUpdated"), object: nil)
    NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "ViewerWillDisappear"), object: nil, queue: nil) { [weak self] (notification) in
      self?.onViewerDisappear?([:])
    }
    antButton.setImage(UIImage.image("Burger")?.withRenderingMode(.alwaysTemplate), for: .normal)
    updateColours()
    
    shownStream = nil
    let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
    rightSwipeGesture.direction = .right
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapButton(_:)))
    tongueView.addGestureRecognizer(rightSwipeGesture)
    tongueView.addGestureRecognizer(tapGesture)
    watchedVods = []
    shownIds = []
    AppAuth.shared.auth()
  }
  
  private func updateColours() {
    antButton.tintColor = isLightMode ? .black : .white
    antButton.backgroundColor = isLightMode ? .white : UIColor.color("a_backgroundDarkGrey")
    tongueView.backgroundColor = isLightMode ? .white : UIColor.color("a_dark")
    streamNameLabel.textColor = isLightMode ? .black : .white
    viewersCountLabel.textColor = isLightMode ? .black : .white
    newStreamLabel.textColor = isLightMode ? .black : .white
  }
  
  //FIXME: Rename
  private func increaseWidgetFrame(_ value: Bool = true) {
    if value {
      var newFrame = initialFrame
      newFrame.size.width += tongueWidth
      newFrame.origin.x -= tongueWidth
      self.frame = newFrame
    } else {
      self.frame = initialFrame
    }
    
  }
  
  override public func layoutSubviews() {
    super.layoutSubviews()
    if frame.size == .zero {
      frame = initialFrame
    }
    antButton.layer.cornerRadius = antButton.bounds.height/2
  }

  @objc
  @IBAction private func didTapButton(_ sender: Any?) {
    guard let vc = findViewController() else {return}
    onViewerAppear?([:])
    if let stream = shownStream {
      let playerVC = PlayerController(nibName: "PlayerController", bundle: Bundle(for: type(of: self)))
      playerVC.videoContent = stream
      playerVC.shouldNotify = true
      vc.present(playerVC, animated: true, completion: nil)
      return
    }
    vc.present(NavigationController(rootViewController: StreamListController(nibName: "StreamListController", bundle: Bundle(for: type(of: self)))), animated: true, completion: nil)

  }

  @objc
  func handleNotification(_ notification: NSNotification) {
    
    guard self.window != nil,
      let streams = dataSource?.streams,
    shownStream == nil else {
      updateAntButton(forLive: dataSource?.streams.isEmpty == false)
      return
    }
    
    let ids = streams.map{$0.id}
    
    for streamId in ids {
      if !shownIds.contains(streamId) {
        shownStream = dataSource?.streams.first(where: {$0.id == streamId})
        shownIds.append(streamId)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
          self?.shownStream = nil
        }
        break
      }
    }
    
    updateAntButton(forLive: !ids.isEmpty)
    
  }
  
  private func updateAntButton(forLive: Bool = false) {
    if forLive {
      antButton.addBadge(shape: .rect, text: "Live")
      antButton.setImage(UIImage.image("Burger"), for: .normal)
      return
    }
    guard let newVodsCount = dataSource?.videos.filter({!watchedVods.contains($0.id)}).count else {return}
    if newVodsCount > 0 {
      antButton.addBadge(shape: .circle, text: "\(newVodsCount)")
      antButton.setImage(UIImage.image("Burger"), for: .normal)
    } else {
      antButton.setImage(UIImage.image("Burger")?.withRenderingMode(.alwaysTemplate), for: .normal)
      antButton.tintColor = isLightMode ? .black : .white
      antButton.removeBadge()
    }
  }
  
  @objc
  func handleSwipeGesture(_ sender: UISwipeGestureRecognizer) {
    shownStream = nil
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
}

