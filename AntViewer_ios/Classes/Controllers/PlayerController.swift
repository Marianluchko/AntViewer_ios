//
//  PlayerController.swift
//  viewer-module
//
//  Created by Mykola Vaniurskyi on 12/5/18.
//  Copyright © 2018 Mykola Vaniurskyi. All rights reserved.
//

import UIKit
import AVKit
import AntViewerExt

private let maxTextLength = 250

class PlayerController: UIViewController {
  
  private var player :AVPlayer?
  private var playerItem: AVPlayerItem?
  
  @IBOutlet weak var landscapeStreamInfoLeading: NSLayoutConstraint!
  @IBOutlet weak var portraitMessageBottomSpace: NSLayoutConstraint!
  @IBOutlet weak var portraitMessageHeight: NSLayoutConstraint!
  @IBOutlet weak var landscapeMessageBottomSpace: NSLayoutConstraint! //4
  @IBOutlet weak var landscapeMessageHeight: NSLayoutConstraint! //40
  @IBOutlet weak var landscapeMessageContainerHeight: NSLayoutConstraint!
  @IBOutlet weak var landscapeMessageWidth: NSLayoutConstraint!
  @IBOutlet weak var landscapeMessageTrailing: NSLayoutConstraint!
  @IBOutlet weak var landscapeMessageLeading: NSLayoutConstraint!
  @IBOutlet weak var landscapeChatLeading: NSLayoutConstraint!
  @IBOutlet weak var landscapePollViewLeading: NSLayoutConstraint!
  @IBOutlet weak var landscapePollBannerLeading: NSLayoutConstraint!
  @IBOutlet weak var liveLabelWidth: NSLayoutConstraint! {
    didSet {
      liveLabelWidth.constant = videoContent is Vod ? 0 : 36
    }
  }
  
  @IBOutlet var pollNameLabels: [UILabel]!
  @IBOutlet weak var portraitTextView: IQTextView!
  @IBOutlet weak var landscapeTextView: IQTextView!
  @IBOutlet weak var portraitTableView: UITableView!
  @IBOutlet weak var landscapeTableView: UITableView!
  @IBOutlet weak var portraitSendButton: UIButton!
  @IBOutlet weak var landscapeSendButton: UIButton!
  @IBOutlet weak var videoContainerView: AVPlayerView!
  @IBOutlet weak var videoControlsView: UIView!
  @IBOutlet weak var playButton: UIButton!
  @IBOutlet weak var pollContainerView: UIView!
  @IBOutlet weak var infoPortraitView: UIView!
  @IBOutlet weak var landscapeCollapsedPollLabel: UILabel!
  @IBOutlet weak var landscapeStreamInfoStackView: UIStackView!
  @IBOutlet weak var durationView: UIView! {
    didSet {
      durationView.isHidden = videoContent is AntViewerExt.Stream
    }
  }
  
  @IBOutlet weak var durationLabel: UILabel! {
    didSet {
      if let video = videoContent as? Vod {
        durationLabel.text = video.duration
      }
    }
  }
  
  @IBOutlet weak var broadcasterProfileImage: UIImageView! {
    didSet {
      broadcasterProfileImage.load(url: URL(string: videoContent.broadcasterPicUrl), placeholder: UIImage.image("avaPic"))
    }
  }
  @IBOutlet weak var startLabel: UILabel!
  @IBOutlet weak var newPollView: UIView! {
    didSet {
      let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openPollButtonPressed(_:)))
      newPollView.addGestureRecognizer(tapGesture)
    }
  }
  
  @IBOutlet weak var landscapePollView: UIView! {
    didSet {
      let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openPollButtonPressed(_:)))
      landscapePollView.addGestureRecognizer(tapGesture)
    }
  }
  
  @IBOutlet weak var collapsedPollButton: UIButton! {
    didSet {
      collapsedPollButton.addTarget(self, action: #selector(openPollButtonPressed(_:)), for: .touchUpInside)
    }
  }
  
  @IBOutlet weak var landscapeCollapsedPollView: UIView! {
    didSet {
      let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openPollButtonPressed(_:)))
      landscapeCollapsedPollView.addGestureRecognizer(tapGesture)
    }
  }
  
  @IBOutlet weak var viewersCountLabel: UILabel! {
    didSet {
      viewersCountLabel.text = "\(videoContent.viewersCount) \(videoContent is Vod ? "viewes" : "Viewers")"
    }
  }
  
  @IBOutlet weak var portraitStreamNameLabel: UILabel! {
    didSet {
      portraitStreamNameLabel.text = videoContent.title
    }
  }
  
  @IBOutlet weak var landscapeStreamNameLabel: UILabel! {
    didSet {
      landscapeStreamNameLabel.text = videoContent.title
    }
  }
  
  @IBOutlet weak var landscapeCreatorNameLabel: UILabel! {
    didSet {
      landscapeCreatorNameLabel.text = videoContent.creatorName
    }
  }
  
  @IBOutlet weak var creatorNameLabel: UILabel! {
    didSet {
      creatorNameLabel.text = videoContent.creatorName.isEmpty ? videoContent.creatorNickname : videoContent.creatorName
    }
  }
  
  @IBOutlet weak var portraitSeekSlider: UISlider! {
    didSet {
      if let video = videoContent as? Vod {
        portraitSeekSlider.isHidden = false
        portraitSeekSlider.maximumValue = Float(video.duration.duration())
        let image = UIImage.image("thumb")
        portraitSeekSlider.setThumbImage(image, for: .normal)
        portraitSeekSlider.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
      }
    }
  }
  
  @IBOutlet weak var landscapeSeekSlider: UISlider! {
    didSet {
      if let video = videoContent as? Vod {
        landscapeSeekSlider.isHidden = false
        landscapeSeekSlider.maximumValue = Float(video.duration.duration())
        let image = UIImage.image("thumb")
        landscapeSeekSlider.setThumbImage(image, for: .normal)
        landscapeSeekSlider.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
      }
    }
  }
  
  @IBOutlet weak var seekLabel: UILabel! {
    didSet {
      seekLabel.isHidden = videoContent is AntViewerExt.Stream
    }
  }
  
  fileprivate var currentOrientation: UIInterfaceOrientationMask! {
    didSet {
      if currentOrientation != oldValue {
        if videoContent is Vod {
          seekTo = nil
        }
        adjustHeightForTextView(landscapeTextView)
        if OrientationUtility.isLandscape {
          let leftInset = view.safeAreaInsets.left
          if leftInset > 0 {
            landscapeStreamInfoLeading.constant = OrientationUtility.currentOrientatin == .landscapeLeft ? 18 : 30 + 10
            view.layoutIfNeeded()
            landscapeMessageTrailing.constant = OrientationUtility.currentOrientatin == .landscapeLeft ? 30 : 0
          }
          landscapePollViewLeading.constant = landscapeStreamInfoStackView.frame.origin.x
          landscapePollBannerLeading.constant = landscapeStreamInfoStackView.frame.origin.x
          landscapeMessageLeading.constant = chatFieldLeading
          currentTableView.frame.origin = CGPoint(x: chatFieldLeading >= 0 ? 0 : -self.currentTableView.frame.width, y: 0)
          if landscapeChatLeading.constant > 0 {
            landscapeChatLeading.constant = landscapeStreamInfoStackView.frame.origin.x
          }
          
        }
        
        updateContentInsetForTableView(currentTableView)
        view.layoutIfNeeded()
      }
    }
  }
  
  fileprivate var pollManager: PollManager?
  
  fileprivate var activePoll: Poll? {
    didSet {
      NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "PollUpdated"), object: nil, userInfo: ["poll" : activePoll ?? 0])
      guard let poll = activePoll else {
        collapsedPollButton.alpha = 0
        UIView.transition(with: collapsedPollButton, duration: 0.3, options: .transitionFlipFromTop, animations: {
          self.closeButtonPressed()
          self.newPollView.isHidden = true
          self.newPollView.alpha = 0
          self.collapsedPollButton.isHidden = true
          self.landscapePollView.isHidden = true
          self.landscapeCollapsedPollView.isHidden = true
        }, completion: nil)
        self.updateContentInsetForTableView(self.portraitTableView)
        return
      }
      pollNameLabels.forEach {$0.text = poll.pollQuestion}
      
      
      poll.onUpdate = { [weak self] in
        guard let _ = self?.activePoll else { return }
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "PollUpdated"), object: nil, userInfo: ["poll" : self?.activePoll ?? 0])
        self?.shouldShowBigPollMessage = self?.activePoll?.answeredByUser == false

        if self?.activePoll?.answeredByUser == true {
          let count = self?.activePoll?.answersCount.reduce(0, +) ?? 0
          self?.landscapeCollapsedPollLabel.text = "\(count)"
        } else {
          self?.landscapeCollapsedPollLabel.text = "New poll!"
        }
      }
    }
  }
  
  fileprivate var shouldShowBigPollMessage = true {
    didSet {
      let shouldHideBigPoll = !shouldShowBigPollMessage || isKeyboardShown
      self.newPollView.isHidden = shouldHideBigPoll
      self.newPollView.alpha = shouldHideBigPoll ? 0 : 1
      self.collapsedPollButton.alpha = shouldHideBigPoll ? 1 : 0
      self.collapsedPollButton.isHidden = !shouldHideBigPoll
      self.landscapePollView.isHidden = !self.shouldShowBigPollMessage || !self.pollContainerView.isHidden
      self.landscapeCollapsedPollView.isHidden = self.shouldShowBigPollMessage || !self.pollContainerView.isHidden || isKeyboardShown
      self.view.layoutIfNeeded()
      self.updateContentInsetForTableView(self.portraitTableView)
    }
  }
  
  fileprivate var isKeyboardShown = false {
    didSet {
      guard activePoll != nil else {return}
      let oldValue = self.shouldShowBigPollMessage
      self.shouldShowBigPollMessage = oldValue
    }
  }
  
  private var chatGradientLayer: CAGradientLayer = {
    let gradient = CAGradientLayer()
    gradient.colors = [UIColor.clear.withAlphaComponent(0).cgColor, UIColor.clear.withAlphaComponent(0.7).cgColor, UIColor.clear.withAlphaComponent(1).cgColor, UIColor.clear.withAlphaComponent(1).cgColor]
    gradient.locations = [0, 0.15, 0.5, 1]
    return gradient
  }()
  
  private var viewedVods: [Int] {
    set {
      UserDefaults.standard.set(newValue, forKey: "viewedVods")
    }
    get {
      return UserDefaults.standard.array(forKey: "viewedVods") as? [Int] ?? []
    }
  }
  
  private var isChatEnabled = false {
    didSet {
      portraitSendButton.isEnabled = isChatEnabled
      portraitTextView.isEditable = isChatEnabled
      portraitTextView.placeholder = isChatEnabled ? "Say something" : "Chat not available"
      landscapeSendButton.isEnabled = isChatEnabled
      landscapeTextView.isEditable = isChatEnabled
      landscapeTextView.placeholder = isChatEnabled ? "Say something" : "Chat not available"
      landscapeTextView.superview?.isHidden = !isChatEnabled
      if !isChatEnabled {
        portraitTextView.text = ""
        landscapeTextView.text = ""
      }
    }
  }
  
  private var chat: Chat? {
    didSet {
      chat?.onAdd = { [weak self] message in
        self?.videoContent is Vod ? self?.vodMessages?.append(message) : self?.insertMessage(message)
      }
      chat?.onRemove = { [weak self] message in
        self?.removeMessage(message)
      }
      chat?.onStateChange = { [weak self] isActive in
        if !(self?.videoContent is Vod) {
        self?.isChatEnabled = isActive
        } else {
          self?.isChatEnabled = false
        }
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
        if self?.messagesDataSource.isEmpty == false {
          let lastIndexPath = IndexPath(row: self!.messagesDataSource.count - 1, section: 0)
          if lastIndexPath.row >= 0 {
            self?.currentTableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: false)
          }
        }
      }
    }
  }
  
  var videoContent: VideoContent!
  var shouldNotify = false
  
  fileprivate var messagesDataSource = [Message]()
  fileprivate var pollController: PollController?
  fileprivate var playerTimeObserver: Any?
  fileprivate var currentTableView: UITableView {
    return OrientationUtility.isPortrait ? portraitTableView : landscapeTableView
  }
  
  fileprivate var isControlsEnabled = false
  fileprivate var controlsDebouncer = Debouncer(delay: 3)
  
  //MARK: For vods
  fileprivate var vodMessages: [Message]? = []
  
  fileprivate var chatFieldLeading: CGFloat! {
    didSet {
      landscapeMessageLeading.constant = chatFieldLeading
    }
    
  }
  
  fileprivate var seekTo: Int? {
    didSet {
      if seekTo == nil, let time = oldValue {
        player?.seek(to: CMTime(seconds: Double(time), preferredTimescale: 1))
//        let _time = Int(videoContent.date.timeIntervalSince1970) + time
//        if let filteredMessages = vodMessages?.filter({$0.timestamp < _time}) {
//          messagesDataSource = filteredMessages
//        }
        handleVODsChat(forTime: time)
//        portraitTableView.reloadData()
//        landscapeTableView.reloadData()
        if messagesDataSource.count > 0 {
          currentTableView.scrollToRow(at: IndexPath(row: messagesDataSource.count - 1, section: 0), at: .bottom, animated: true)
        }
        
        controlsDebouncer.call { [weak self] in
          if self?.player?.isPlaying == true {
            if OrientationUtility.isLandscape && self?.seekTo != nil {
              return
            }
            self?.videoControlsView.isHidden = true
          }
        }
      }
    }
  }
  
  override var preferredStatusBarStyle : UIStatusBarStyle {
    return .lightContent
  }
  
  override var prefersStatusBarHidden: Bool {
    let bottomInset = view.safeAreaInsets.bottom
    return bottomInset == 0
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    OrientationUtility.rotateToOrientation(OrientationUtility.isPortrait ? .portrait : .landscapeRight)
    currentOrientation = OrientationUtility.currentOrientatin
    setupChatTableView(portraitTableView)
    setupChatTableView(landscapeTableView)
    chatFieldLeading = landscapeStreamInfoStackView.frame.origin.x
    try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
    
    isChatEnabled = false
    
    if videoContent is Vod {
      if !viewedVods.contains(videoContent.id) {
        viewedVods.append(videoContent.id)
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "StreamsUpdated"), object: nil)
      }
      landscapeMessageContainerHeight.priority = UILayoutPriority(rawValue: 999)
      landscapeSendButton.superview?.isHidden = true
//      videoEmuMessages = ChatEmulation.chatEmulationVideoArray[videoContent.id - 1]
    } else {
      pollManager = PollManager(streamId: videoContent.streamId)
      pollManager?.observePolls(completion: { [weak self] (poll) in
        self?.activePoll = poll
      })
    }
    self.chat = Chat(streamID: videoContent.streamId)
    
    
    var token: NSObjectProtocol?
    token = NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { [weak self] (notification) in
      guard let `self` = self else {
        NotificationCenter.default.removeObserver(token!)
        return
      }
      self.currentOrientation = OrientationUtility.currentOrientatin
      
    }
    
    var streamToken: NSObjectProtocol?
    streamToken = NotificationCenter.default.addObserver(forName: NSNotification.Name.init(rawValue: "StreamsUpdated"), object: nil, queue: .main) { [weak self](notification) in
      guard let `self` = self else {
        NotificationCenter.default.removeObserver(streamToken!)
        return
      }
      if let stream = DataSource.shared.streams.first(where: {$0.id == self.videoContent.id}) {
        self.viewersCountLabel.text = "\(stream.viewersCount) Viewers"
      }
      
    }
    startPlayer()
    adjustHeightForTextView(portraitTextView)
    adjustHeightForTextView(landscapeTextView)
    
  }
  
  @objc
  func handleTouches(sender: UITapGestureRecognizer) {
    let point = sender.location(in: view)
    let isTouchOnTableView = portraitTableView.frame.contains(point)
    let isTouchOnInfoView = infoPortraitView.frame.contains(point)
    if isTouchOnTableView || isTouchOnInfoView {
      view.endEditing(true)
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setNeedsStatusBarAppearanceUpdate()
    landscapeTableView.superview?.addObserver(self, forKeyPath: #keyPath(UIView.bounds), options: .new, context: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    UIApplication.shared.isIdleTimerDisabled = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    landscapeTableView.superview?.removeObserver(self, forKeyPath: #keyPath(UIView.bounds))
    player?.currentItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
    if let playerTimeObserver = playerTimeObserver {
      player?.removeTimeObserver(playerTimeObserver)
    }
    
    view.endEditing(true)
    UIApplication.shared.isIdleTimerDisabled = false
    
  }
  
  deinit {
    pollManager?.removeFirObserver()
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    if size.width > size.height {
      self.landscapeTableView.reloadData()
      var lastIndexPath = IndexPath(row: self.messagesDataSource.count - 1, section: 0)
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        lastIndexPath = IndexPath(row: self.messagesDataSource.count - 1, section: 0)
        if lastIndexPath.row >= 0 {
          
          self.landscapeTableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: false)
          
        }
      }
      
    } else {
      self.portraitTableView.reloadData()
    }
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if (keyPath == #keyPath(UIView.bounds)) {
      if let tableViewContainerBounds = landscapeTableView.superview?.bounds {
        chatGradientLayer.frame = tableViewContainerBounds
      }
      return
    }
    
    if let currentPlayer = player ,
      let playerObject = object as? AVPlayerItem,
      playerObject == currentPlayer.currentItem,
      keyPath == #keyPath(AVPlayerItem.status) {
      print("LOL: \(currentPlayer.rate)")
      if currentPlayer.currentItem?.status == .readyToPlay {
        print("AZAZA: \(keyPath)")
        if !isControlsEnabled {
          print("BLABLA: \(keyPath)")
          currentPlayer.play()
          isControlsEnabled = true
        }
      }
      return
    }
    print("KEK: \(keyPath)")
    super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
  }
 
  private func handleVODsChat(forTime time: Int) {
    let currentTime = Int(videoContent.date.timeIntervalSince1970) + time
    guard let vodMessages = self.vodMessages else { return }
    let filteredArr = vodMessages.filter({$0.timestamp <= currentTime })
    let dif = filteredArr.count - messagesDataSource.count
    guard dif != 0 else { return }
    var difArr: [Message]
    difArr =  dif > 0 ?
      filteredArr.filter { mes in !messagesDataSource.contains(where: { $0.key == mes.key })} :
      messagesDataSource.filter { mes in !filteredArr.contains(where: { $0.key == mes.key })}

    difArr.forEach { (message) in
      dif > 0 ? self.insertMessage(message) : self.removeMessage(message)
    }
    
  }
  
  private func startPlayer(){
    playerItem =  AVPlayerItem(url: URL(string: videoContent.url)!)
    player = AVPlayer(playerItem: playerItem)
    player?.allowsExternalPlayback = true
    player?.rate = 1.0
    //TODO: AirPlay
    print("DURATION: \(playerItem?.asset.duration)")
    let castedLayer = videoContainerView.layer as! AVPlayerLayer
    castedLayer.player = player
    playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.new, .initial], context: nil)
    
    playerTimeObserver = player?.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: .main, using: { [weak self] (time) in
      guard self?.player?.currentItem?.status == .readyToPlay,
        let isPlaybackBufferFull = self?.player?.currentItem?.isPlaybackBufferFull,
        let isPlaybackLikelyToKeepUp = self?.player?.currentItem?.isPlaybackLikelyToKeepUp else { return }
      if isPlaybackBufferFull || isPlaybackLikelyToKeepUp {
        self?.videoContainerView.removeActivityIndicator()
      } else {
        self?.videoContainerView.showActivityIndicator()
      }
      if self?.videoContent is Vod {
        
        let printArr = self?.vodMessages?.map({ (message) -> (Int, Int) in
          var messageTime = 0
          var seekTime = 0
          messageTime = message.timestamp
          seekTime = Int(self?.videoContent.date.timeIntervalSince1970 ?? 0) + Int(time.seconds)
          return (messageTime, seekTime)
        })
        
        printArr?.forEach({ print($0) })
        self?.handleVODsChat(forTime: Int(time.seconds))
//        if let message = self?.vodMessages?.first(where: {$0.timestamp >= Int(self?.videoContent.date.timeIntervalSince1970 ?? 0) + Int(time.seconds)}) {
//          if !self!.messagesDataSource.contains(where: {$0.text == message.text}) {
//            self?.insertMessage(message)
//          }
//        }
        
        self?.seekLabel.text = Int(time.seconds).durationString
        if self?.seekTo == nil {
          self?.portraitSeekSlider.value = Float(time.seconds)
          self?.landscapeSeekSlider.value = Float(time.seconds)
        }
      }
    })
    if videoContent is Vod {
      NotificationCenter.default.addObserver(self, selector: #selector(onVideoEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
    }
    videoContainerView.showActivityIndicator()
  }
  
  @objc
  private func onSliderValChanged(slider: UISlider, event: UIEvent) {
    if let touchEvent = event.allTouches?.first {
      switch touchEvent.phase {
      case .began:
        seekTo = Int(slider.value)
      case .moved:
        seekTo = Int(slider.value)
      default:
        seekTo = nil
      }
    }
  }
  
  @objc
  private func onVideoEnd() {
    videoControlsView.isHidden = false
    playButton.setImage(UIImage.image("play"), for: .normal)
    player?.seek(to: .zero)
  }
  
  private func insertMessage(_ message: Message) {
    messagesDataSource.append(message)
    let shouldScroll = currentTableView.contentOffset.y >= currentTableView.contentSize.height - currentTableView.frame.size.height - 20
    let indexPath = IndexPath(row: messagesDataSource.count - 1, section: 0)
    currentTableView.beginUpdates()
    currentTableView.insertRows(at: [indexPath], with: .none)
    currentTableView.endUpdates()
    updateContentInsetForTableView(currentTableView)
    currentTableView.layoutIfNeeded()
    if shouldScroll {
      UIView.animate(withDuration: 0.3) {
        self.currentTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
      }
    }
    
  }
  
  private func removeMessage(_ message: Message) {
    if let index = messagesDataSource.firstIndex(where: {$0.key == message.key}) {
      self.messagesDataSource.remove(at: index)
      let indexPath = IndexPath(row: index, section: 0)
      UIView.setAnimationsEnabled(false)
      currentTableView.beginUpdates()
      currentTableView.deleteRows(at: [indexPath], with: .none)
      currentTableView.endUpdates()
      updateContentInsetForTableView(currentTableView)
      UIView.setAnimationsEnabled(true)
    }
  }
  
  private func updateContentInsetForTableView(_ table: UITableView) {
    let numRows = tableView(table, numberOfRowsInSection: 0)
    var contentInsetTop = table.bounds.size.height
    guard table.contentSize.height <= contentInsetTop else {
      table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
      return
    }
    for i in 0..<numRows {
      let rowRect = table.rectForRow(at: IndexPath(item: i, section: 0))
      contentInsetTop -= rowRect.size.height
      if contentInsetTop <= 0 {
        contentInsetTop = 0
      }
    }
    table.contentInset = UIEdgeInsets(top: contentInsetTop, left: 0, bottom: 0, right: 0)
  }
  
  @IBAction func fullScreenButtonPressed(_ sender: UIButton) {
    OrientationUtility.rotateToOrientation(OrientationUtility.isPortrait ? .landscapeRight : .portrait)
  }
  
  @IBAction func closeButtonPressed(_ sender: UIButton) {
    if shouldNotify {
      NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ViewerWillDisappear"), object: nil)
    }
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func handleTouchOnVideo(_ sender: UITapGestureRecognizer) {
    guard isControlsEnabled else {return}
    if isKeyboardShown {
      portraitTextView.endEditing(true)
      landscapeTextView.endEditing(true)
      return
    }
    startLabel.text = videoContent.date.timeAgo()
    videoControlsView.isHidden = !videoControlsView.isHidden
    controlsDebouncer.call { [weak self] in
      if self?.player?.isPlaying == true {
        if OrientationUtility.isLandscape && self?.seekTo != nil {
          return
        }
        self?.videoControlsView.isHidden = true
      }
    }
  }
  
  @IBAction func playButtonPressed(_ sender: UIButton) {
    if player?.isPlaying == true {
      player?.pause()
      playButton.setImage(UIImage.image("play"), for: .normal)
      controlsDebouncer.call {}
    } else {
      player?.play()
      playButton.setImage(UIImage.image("pause"), for: .normal)
      controlsDebouncer.call { [weak self] in
        self?.videoControlsView.isHidden = true
      }
    }
  }
  
  @IBAction func sendButtonPressed(_ sender: UIButton) {
    let textView = sender == portraitSendButton ? portraitTextView : landscapeTextView
    
    guard let text = textView?.text, text.trimmingCharacters(in: .whitespacesAndNewlines).count != 0 else {
      textView?.text.removeAll()
      return
    }
    guard let stream = videoContent as? AntViewerExt.Stream else {return}
    sender.isEnabled = false
    let name = UserDefaults.standard.string(forKey: "userName") ?? "SuperFan123"
    let message = Message(userID: "testViewerID", nickname: name, text: text)
    self.chat?.send(message: message) { (error) in
      textView?.text = ""
      if error == nil {
        self.adjustHeightForTextView(self.landscapeTextView)
        self.adjustHeightForTextView(self.portraitTextView)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
          let lastIndexPath = IndexPath(row: self.messagesDataSource.count - 1, section: 0)
          if lastIndexPath.row >= 0 {
            self.currentTableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: false)
          }
        })
      }
      sender.isEnabled = true
    }
  }
  
  fileprivate func adjustHeightForTextView(_ textView: UITextView) {
    let fixedWidth = textView.frame.size.width
    let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
    switch textView {
    case portraitTextView:
      portraitMessageHeight.constant = newSize.height
    case landscapeTextView:
      landscapeMessageHeight.constant = newSize.height
    default:
      break
    }
    
    view.layoutIfNeeded()
  }
  
  @IBAction func handleSwipeGesture(_ sender: UISwipeGestureRecognizer) {
    let halfOfViewWidth = view.bounds.width / 2
    guard OrientationUtility.isLandscape, sender.location(in: view).x <= halfOfViewWidth else {return}
    
    var isRightDirection = false
    switch sender.direction {
    case .right:
//      landscapeChatLeading.constant = landscapeStreamInfoStackView.frame.origin.x
      isRightDirection = true
      let isLeftInset = view.safeAreaInsets.left > 0
      chatFieldLeading = isKeyboardShown ? OrientationUtility.currentOrientatin == .landscapeRight && isLeftInset ? 30 : 0 : landscapeStreamInfoStackView.frame.origin.x
    case .left:
//      landscapeChatLeading.constant = -view.bounds.width
//      chatFieldLeading = -view.bounds.width
//      view.endEditing(true)
//      landscapeChatLeading.constant = -currentTableView.frame.width//view.bounds.width
      chatFieldLeading = -currentTableView.frame.width//view.bounds.width

    default:
      return
    }
    view.endEditing(false)
        UIView.animate(withDuration: 0.3) {
          self.view.layoutIfNeeded()
          self.currentTableView.frame.origin = CGPoint(x: isRightDirection ? 0 : -self.currentTableView.frame.width, y: 0)
        }
  }
  
  @objc
  private func openPollButtonPressed(_ sender: Any) {
    view.endEditing(true)
    pollController = PollController()
    pollController?.poll = activePoll
    guard let pollController = pollController else {return}
    addChild(pollController)
    pollContainerView.addSubview(pollController.view)
    pollController.view.frame = pollContainerView.bounds
    pollController.didMove(toParent: self)
    pollController.delegate = self
    pollContainerView.isHidden = false
    let oldValue = shouldShowBigPollMessage
    shouldShowBigPollMessage = oldValue
  }
  
  @IBAction func closePollButtonPressed(_ sender: UIButton) {
    shouldShowBigPollMessage = false
  }
  
  private func setupChatTableView(_ sender: UITableView) {
    var cellNib: UINib!
    var reuseIdentifire: String!
    
    switch sender {
    case portraitTableView:
      cellNib = UINib.init(nibName: "PortraitMessageCell", bundle: Bundle(for: type(of: self)))
      reuseIdentifire = "portraitCell"
    case landscapeTableView:
      cellNib = UINib.init(nibName: "LandscapeMessageCell", bundle: Bundle(for: type(of: self)))
      reuseIdentifire = "landscapeCell"
      
      chatGradientLayer.frame = sender.superview!.bounds
      sender.superview?.layer.mask = chatGradientLayer
    default:
      return
    }
    
    sender.register(cellNib, forCellReuseIdentifier: reuseIdentifire)
    sender.estimatedRowHeight = 50
    sender.estimatedSectionHeaderHeight = 0
    sender.estimatedSectionFooterHeight = 0
    sender.rowHeight = UITableView.automaticDimension
  }
  
}

//MARK: Keyboard handling
extension PlayerController {
  
  @objc
  fileprivate func keyboardWillShow(notification: NSNotification) {
    if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
      let userInfo = notification.userInfo!
      let animationDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
      let rawAnimationCurve = (notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber).uint32Value << 16
      let animationCurve = UIView.AnimationOptions.init(rawValue: UInt(rawAnimationCurve))
      let bottomPadding = view.safeAreaInsets.bottom
      self.isKeyboardShown = true
      portraitMessageBottomSpace.constant = keyboardSize.height - bottomPadding
      landscapeMessageBottomSpace.constant = keyboardSize.height - bottomPadding
      landscapeMessageWidth.priority = UILayoutPriority(rawValue: 100)
      landscapeMessageTrailing.priority = UILayoutPriority(rawValue: 999)
      if OrientationUtility.isLandscape {
        let isLeftInset = view.safeAreaInsets.left > 0
        chatFieldLeading = OrientationUtility.currentOrientatin == .landscapeRight && isLeftInset ? 30 : 0
      }
      
      
      adjustHeightForTextView(landscapeTextView)
      adjustHeightForTextView(portraitTextView)

      UIView.animate(withDuration: animationDuration, delay: 0, options: [.beginFromCurrentState, animationCurve], animations: {
        self.view.layoutIfNeeded()
        let lastIndexPath = IndexPath(row: self.messagesDataSource.count - 1, section: 0)
        if lastIndexPath.row >= 0 {
          self.currentTableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: false)
        }
        self.updateContentInsetForTableView(self.currentTableView)
  
      }, completion: { value in
        self.currentTableView.beginUpdates()
        self.currentTableView.endUpdates()
      })
    }
  }
  
  @objc
  fileprivate func keyboardWillHide(notification: NSNotification) {
    if let _ = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
      let userInfo = notification.userInfo!
      let animationDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
      let rawAnimationCurve = (notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber).uint32Value << 16
      let animationCurve = UIView.AnimationOptions.init(rawValue: UInt(rawAnimationCurve))
      self.isKeyboardShown = false
      portraitMessageBottomSpace.constant = 0
      landscapeMessageBottomSpace.constant = 4
      landscapeMessageWidth.priority = UILayoutPriority(rawValue: 999)
      landscapeMessageTrailing.priority = UILayoutPriority(rawValue: 100)

      landscapeMessageHeight.constant = 30
      chatFieldLeading = chatFieldLeading >= 0 ? landscapeStreamInfoStackView.frame.origin.x : chatFieldLeading
      adjustHeightForTextView(portraitTextView)
      adjustHeightForTextView(landscapeTextView)
      UIView.animate(withDuration: animationDuration, delay: 0, options: [.beginFromCurrentState, animationCurve], animations: {
        self.view.layoutIfNeeded()
        let lastIndexPath = IndexPath(row: self.messagesDataSource.count - 1, section: 0)
        if lastIndexPath.row >= 0 {
          self.currentTableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: false)
        }
        self.updateContentInsetForTableView(self.currentTableView)
        
      }, completion: { value in
        self.currentTableView.beginUpdates()
        self.currentTableView.endUpdates()
        
      })
    }
  }
  
}

extension PlayerController: UITextViewDelegate {
  
  func textViewDidChange(_ textView: UITextView) {
    adjustHeightForTextView(textView)
  }
  
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    let curentText = text != "" ? (textView.text ?? "") + String(text.dropFirst()) : String((textView.text ?? " ").dropLast())
    
    if curentText.count > maxTextLength {
      textView.text = String(curentText.prefix(maxTextLength))
      return false
    }
    return textView.text.count + text.count - range.length <= maxTextLength
  }
  
}

extension PlayerController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if messagesDataSource.count > 0 {
      portraitTableView.backgroundView = nil
    } else if portraitTableView.backgroundView == nil {
      portraitTableView.backgroundView = EmptyView(frame: tableView.bounds)
    }
    
    
    return messagesDataSource.count
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let identifier = tableView == portraitTableView ? "portraitCell" : "landscapeCell"
    let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
    
    if let cell = cell as? MessageSupportable {
      let message = messagesDataSource[indexPath.row]
      cell.messageLabel.text = message.text
      cell.nameLabel.text = message.nickname
    }
    
    return cell
  }
}


extension PlayerController: PollControllerDelegate {
  
  func closeButtonPressed() {
    pollController?.willMove(toParent: nil)
    pollController?.view.removeFromSuperview()
    pollController?.removeFromParent()
    pollController = nil
    pollContainerView.isHidden = true
    if activePoll != nil {
      shouldShowBigPollMessage = false
    }
  }
  
}
