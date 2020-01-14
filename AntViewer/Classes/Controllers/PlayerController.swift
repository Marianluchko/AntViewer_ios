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
private let maxUserNameLength = 50

class PlayerController: UIViewController {
  
  private var player: Player!
  
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
  @IBOutlet weak var portraitTableView: UITableView! {
    didSet {
      setupChatTableView(portraitTableView)
      let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleHideKeyboardGesture(_:)))
      portraitTableView.addGestureRecognizer(tapGesture)
    }
  }
  
  @IBOutlet weak var landscapeTableViewContainer: UIView! {
    didSet {
      chatGradientLayer.frame = landscapeTableViewContainer.bounds
      landscapeTableViewContainer.layer.mask = chatGradientLayer
    }
  }
  @IBOutlet weak var landscapeTableView: UITableView! {
    didSet {
      setupChatTableView(landscapeTableView)
    }
  }
  @IBOutlet weak var portraitSendButton: UIButton!
  @IBOutlet weak var landscapeSendButton: UIButton!
  @IBOutlet weak var videoContainerView: AVPlayerView! {
    didSet {
      videoContainerView.contentMode = .scaleAspectFit
      videoContainerView.load(url: URL(string: videoContent.thumbnailUrl), placeholder: nil)
    }
  }
  
  @IBOutlet weak var videoControlsView: UIView!
  @IBOutlet weak var playButton: UIButton!
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var previousButton: UIButton!
  
  
  
  @IBOutlet weak var pollContainerView: UIView!
  @IBOutlet weak var infoPortraitView: UIView! {
    didSet {
      let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleHideKeyboardGesture(_:)))
      infoPortraitView.addGestureRecognizer(tapGesture)
    }
  }
  @IBOutlet weak var landscapeCollapsedPollLabel: UILabel!
  @IBOutlet weak var landscapeStreamInfoStackView: UIStackView!
  @IBOutlet weak var durationView: UIView! {
    didSet {
      durationView.isHidden = !(videoContent is Vod)
    }
  }
  
  var activeSpendTime: Double = 0 {
    didSet {
      Statistic.save(state: .end(span: Int(activeSpendTime)), for: videoContent)
    }
  }
  
  var dataSource: DataSource!
  fileprivate var streamTimer: Timer?
  override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
    return OrientationUtility.isLandscape ? .top : .bottom
  }
  
  @IBOutlet weak var portraitBottomContainerView: UIView!
  @IBOutlet weak var portraitBottomContainerViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var portraitEditProfileButton: UIButton! {
    didSet {
      portraitEditProfileButton.isHidden = videoContent is Vod
    }
  }
  @IBOutlet weak var landscapeEditProfileButton: UIButton!{
    didSet {
      landscapeEditProfileButton.isHidden = videoContent is Vod
    }
  }
  
  @IBOutlet weak var landscapeBottomContainerView: UIView!
  @IBOutlet weak var editProfileContainerView: UIView!
  
  @IBOutlet weak var durationLabel: UILabel! {
    didSet {
      if let video = videoContent as? Vod {
        durationLabel.text = video.duration
      }
    }
  }
  
  @IBOutlet weak var broadcasterProfileImage: CacheImageView! {
    didSet {
      broadcasterProfileImage.load(url: URL(string: videoContent.broadcasterPicUrl), placeholder: UIImage.image("avaPic"))
    }
  }
  
  @IBOutlet weak var landscapeBroadcasterProfileImage: CacheImageView! {
    didSet {
      landscapeBroadcasterProfileImage.load(url: URL(string: videoContent.broadcasterPicUrl), placeholder: UIImage.image("avaPic"))
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
      switch videoContent {
      case let vod as Vod:
        viewersCountLabel.text = "\(vod.viewsCount)"
      case let stream as AntViewerExt.Stream:
        viewersCountLabel.text = "\(stream.viewersCount)"
      default:
        break
      }
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
  
  @IBOutlet weak var portraitSeekSlider: CustomSlide! {
    didSet {
      if let video = videoContent as? Vod {
        portraitSeekSlider.isHidden = false
        portraitSeekSlider.maximumValue = Float(video.duration.duration())
        portraitSeekSlider.setThumbImage(UIImage.image("thumb"), for: .normal)
        portraitSeekSlider.tintColor = .clear
        portraitSeekSlider.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
      }
    }
  }
  
  @IBOutlet weak var landscapeSeekSlider: UISlider! {
    didSet {
      if let video = videoContent as? Vod {
        landscapeSeekSlider.isHidden = false
        landscapeSeekSlider.maximumValue = Float(video.duration.duration())
        landscapeSeekSlider.setThumbImage(UIImage.image("thumb"), for: .normal)
        landscapeSeekSlider.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
      }
    }
  }
  
  @IBOutlet weak var seekLabel: UILabel! {
    didSet {
      seekLabel.isHidden = !(videoContent is Vod)
    }
  }
  
  fileprivate var currentOrientation: UIInterfaceOrientation! {
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
  fileprivate var isShouldShowPollAnswers = false
  fileprivate var pollAnswersDebouncer = Debouncer(delay: 15)
  fileprivate var activePoll:  Poll? {
    didSet {
      NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "PollUpdated"), object: nil, userInfo: ["poll" : activePoll ?? 0])
      guard let poll = activePoll else {
        pollAnswersDebouncer.call {}
        self.isShouldShowPollAnswers = false
        collapsedPollButton.alpha = 0
        UIView.transition(with: collapsedPollButton, duration: 0.3, options: .transitionFlipFromTop, animations: {
          self.pollControllerCloseButtonPressed()
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
      self.shouldShowBigPollMessage = true
      
      poll.onUpdate = { [weak self] in
        guard let _ = self?.activePoll else { return }
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "PollUpdated"), object: nil, userInfo: ["poll" : self?.activePoll ?? 0])
        if self?.activePoll?.answeredByUser == true || self?.isShouldShowPollAnswers == true {
          self?.shouldShowBigPollMessage = false
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
      if !(self.newPollView.isHidden && shouldHideBigPoll) {
        self.newPollView.isHidden = shouldHideBigPoll
      }
      self.newPollView.alpha = shouldHideBigPoll ? 0 : 1
      self.collapsedPollButton.alpha = shouldHideBigPoll ? 1 : 0
      self.collapsedPollButton.isHidden = !shouldHideBigPoll
      self.landscapePollView.isHidden = !self.shouldShowBigPollMessage || !self.pollContainerView.isHidden
      self.landscapeCollapsedPollView.isHidden = self.shouldShowBigPollMessage || !self.pollContainerView.isHidden || isKeyboardShown
      self.view.layoutIfNeeded()
      self.updateContentInsetForTableView(self.portraitTableView)
      
      if !shouldShowBigPollMessage, oldValue {
        self.pollAnswersDebouncer.call { [weak self] in
          self?.isShouldShowPollAnswers = true
          if let count = self?.activePoll?.answersCount.reduce(0, +), count != 0 {
            self?.landscapeCollapsedPollLabel.text = "\(count)"
          }
        }
      }
      
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
  
  private var isChatEnabled = false {
    didSet {
      portraitEditProfileButton.isHidden = !isChatEnabled
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
  fileprivate var isVideoEnd = false
  fileprivate var swiftMessage: SwiftMessage?
  fileprivate var isPlayerError = false
  
  fileprivate var messagesDataSource = [Message]()
  fileprivate var pollController: PollController?
  fileprivate var currentTableView: UITableView {
    return OrientationUtility.isPortrait ? portraitTableView : landscapeTableView
  }
  
  fileprivate var isControlsEnabled = false
  fileprivate var controlsDebouncer = Debouncer(delay: 3)
  fileprivate var controlsAppearingDebouncer = Debouncer(delay: 0.4)
  fileprivate var seekByTapDebouncer = Debouncer(delay: 0.7)
  
  //MARK: For vods
  fileprivate var vodMessages: [Message]? = []
  fileprivate var chatFieldLeading: CGFloat! {
    didSet {
      landscapeMessageLeading.constant = chatFieldLeading
      chatFieldLeadingChanged?(chatFieldLeading)
    }
  }
  var chatFieldLeadingChanged: ((CGFloat) -> ())?
  private var timeOfLastTap: Date?
  fileprivate var seekToByTapping: Int?
  fileprivate var isSeekByTappingMode = false
  fileprivate var seekPaddingView: SeekPaddingView?
  fileprivate var isPlayerControlsHidden: Bool = true {
    didSet {
      setPlayerControlsHidden(isPlayerControlsHidden)
    }
  }
  
  
  fileprivate var seekTo: Int? {
    didSet {
      if seekTo == nil, let time = oldValue {
        player.player.rate = 0
        self.isVideoEnd = false
        player.seek(to: CMTime(seconds: Double(time), preferredTimescale: 1), completionHandler: { [weak self] (value) in
          self?.player.isPlayerPaused ?? false ? self?.player.pause() : self?.player.play()
          
          if self?.isSeekByTappingMode ?? true {
            self?.isSeekByTappingMode = false
          }
          
        })
        handleVODsChat(forTime: time)
        if messagesDataSource.count > 0 {
          currentTableView.scrollToRow(at: IndexPath(row: messagesDataSource.count - 1, section: 0), at: .bottom, animated: true)
        }
        controlsDebouncer.call { [weak self] in
          if self?.player.isPlayerPaused == false {
            if OrientationUtility.isLandscape && self?.seekTo != nil {
              return
            }
            self?.isPlayerControlsHidden = true
          }
        }
      }
    }
  }
  
  override var preferredStatusBarStyle : UIStatusBarStyle {
    return .lightContent
  }
  
  override var prefersStatusBarHidden: Bool {
    let window = UIApplication.shared.keyWindow
    let bottomPadding = window?.safeAreaInsets.bottom
    return bottomPadding == 0
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    swiftMessage = SwiftMessage(presentingController: self)
    previousButton.isExclusiveTouch = true
    nextButton.isExclusiveTouch = true
    chatFieldLeading = landscapeStreamInfoStackView.frame.origin.x
    //FIXME:
    OrientationUtility.rotateToOrientation(OrientationUtility.currentOrientatin)
    currentOrientation = OrientationUtility.currentOrientatin
    try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
    
    isChatEnabled = false
    
    Statistic.send(state: .start, for: videoContent)
    dataSource.pauseUpdatingDataSource()
    if videoContent is Vod {
      landscapeMessageContainerHeight.priority = UILayoutPriority(rawValue: 999)
      landscapeSendButton.superview?.isHidden = true
    } else {
      pollManager = PollManager(streamId: videoContent.streamId)
      pollManager?.observePolls(completion: { [weak self] (poll) in
        self?.activePoll = poll
      })
      streamTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { [weak self] (myTimer) in
        guard let `self` = self else {
          myTimer.invalidate()
          return
        }
        self.dataSource.getStreamWith(id: self.videoContent.id) { (result) in
          switch result {
          case .success(let stream):
            self.viewersCountLabel.text = "\(stream.viewersCount)"
          case .failure(let error):
            print(error.localizedDescription)
          }
        }
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
    
    if videoContent is Vod {
      portraitBottomContainerViewHeightConstraint.constant = 0
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
    adjustVideoControlsButtons()
    landscapeTableViewContainer.addObserver(self, forKeyPath: #keyPath(UIView.bounds), options: [.new], context: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackgroundHandler), name: UIApplication.didEnterBackgroundNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    UIApplication.shared.isIdleTimerDisabled = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    NotificationCenter.default.removeObserver(self)
    landscapeTableViewContainer.removeObserver(self, forKeyPath: #keyPath(UIView.bounds))
    view.endEditing(true)
    UIApplication.shared.isIdleTimerDisabled = false
    if let vod = videoContent as? Vod {
      let seconds = player.currentTime
      vod.isNew = false
      vod.stopTime = Int(seconds.isNaN ? 0 : seconds).durationString
      vod.stoped(at: vod.stopTime)
    }
    dataSource.startUpdatingDataSource()
    streamTimer?.invalidate()
  }
  
  deinit {
    pollManager?.removeFirObserver()
    Statistic.send(state: .end(span: Int(activeSpendTime)), for: videoContent)
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    portraitTextView.resignFirstResponder()
    landscapeTextView.resignFirstResponder()
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
    super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
  }
  
  private func handleVODsChat(forTime time: Int) {
    let messagesAfterStream = isVideoEnd ? 600 : 0
    let currentTime = Int(videoContent.date.timeIntervalSince1970) + time + messagesAfterStream
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
    
    var seekTo: Double?
    if let vod = videoContent as? Vod {
      seekTo = Double(vod.stopTime.duration())
    }
    player = Player(url: URL(string:videoContent.url)!, seekTo: seekTo)
    
    player.addPeriodicTimeObserver { [weak self] (time, isLikelyToKeepUp) in
      guard let `self` = self else {return}
      if isLikelyToKeepUp {
        self.videoContainerView.removeActivityIndicator()
        self.playButton.isHidden = false
        if !self.videoControlsView.isHidden {
          self.updatePlayButtonImage()
        }
      } else if self.player.isPlayerPaused == false, !self.videoContainerView.isActivityIndicatorLoaded {
        self.videoContainerView.showActivityIndicator()
        self.playButton.isHidden = true
      }
      self.activeSpendTime += 0.2
      
      if self.videoContent is Vod {
        self.handleVODsChat(forTime: Int(time.seconds))
        self.seekLabel.text = Int(time.seconds).durationString
        if self.seekTo == nil, self.player.player.rate == 1 {
          self.portraitSeekSlider.setValue(Float(time.seconds), animated: false)
          self.landscapeSeekSlider.setValue(Float(time.seconds), animated: false)
        }
      }
    }
    
    player.playerReadyToPlay = { [weak self] in
      self?.isControlsEnabled = true
      self?.videoContainerView.image = nil
    }
    
    //TODO: AirPlay
    
    videoContainerView.player = player.player
    
    player.onErrorApear = { [weak self] error in
      self?.playButton.setImage(UIImage.image("play"), for: .normal)
      self?.isPlayerControlsHidden = false
      self?.videoContainerView.removeActivityIndicator()
      self?.isControlsEnabled = true
      self?.swiftMessage?.showBanner(title: error.description)
      self?.isPlayerError = true
    }
    
    player.onVideoEnd = { [weak self] in
      self?.playButton.setImage(UIImage.image("play"), for: .normal)
      if self?.videoContent is Vod {
        self?.isVideoEnd = true
        self?.isPlayerControlsHidden = false
      } else {
        self?.videoContainerView.image = UIImage.image("thanks_for_watching")
        self?.videoContainerView.layer.sublayers?.first?.isHidden = true
        self?.liveLabelWidth.constant = 0
        self?.playButton.isHidden = true
        self?.view.layoutIfNeeded()
      }
      
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
  
  private func adjustVideoControlsButtons() {
    guard videoContent is Vod else {
      nextButton.isHidden = true
      previousButton.isHidden = true
      return
    }
    let index = dataSource.videos.firstIndex(where: { $0.id == videoContent.id }) ?? 0
    let videosCount = dataSource.videos.count
    
    switch index {
    case 0:
      previousButton?.isHidden = true
    case videosCount - 2:
      if videosCount % 15 == 0 {
        dataSource.fetchNextItemsFrom(index: videosCount) { (_) in }
      }
    case videosCount - 1:
      nextButton?.isHidden = true
    default:
      break
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
    UIView.animate(withDuration: 0.3,
                   delay: 0,
                   options: [.curveEaseOut, .beginFromCurrentState],
                   animations: {
                    table.contentInset = UIEdgeInsets(top: contentInsetTop, left: 0, bottom: 0, right: 0)
    }, completion: nil)
    
  }
  
  @IBAction func fullScreenButtonPressed(_ sender: UIButton) {
    OrientationUtility.rotateToOrientation(OrientationUtility.isPortrait ? .landscapeRight : .portrait)
  }
  
  @IBAction func closeButtonPressed(_ sender: UIButton) {
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    player.stop()
    dismiss(animated: true, completion: nil)
  }
  
  @objc
  private func didEnterBackgroundHandler() {
    player.pause()
    updatePlayButtonImage()
    isPlayerControlsHidden = false
  }
  
  func handleSeekByTapping(_ sender: UITapGestureRecognizer) {
    guard let vod = self.videoContent as? Vod else { return }
    self.controlsAppearingDebouncer.call {}
    self.videoControlsView.isHidden = true
    self.portraitSeekSlider.tintColor = .clear
    let isLeftSide = sender.location(in: self.videoContainerView).x < self.videoContainerView.bounds.width / 2
    let activeSlider = OrientationUtility.currentOrientatin == .portrait ? self.portraitSeekSlider : self.landscapeSeekSlider
    self.seekTo = Int(activeSlider?.value ?? 0)
    
    if self.seekToByTapping == nil {
      self.seekToByTapping = self.seekTo
    }
    
    self.seekToByTapping! += isLeftSide ? -10 : 10
    
    switch self.seekToByTapping! {
    case let val where val < 0:
      self.seekToByTapping = 0
    case let val:
      self.seekToByTapping = (vod.duration.duration() >= val) ? val : (vod.duration.duration() - 1)
    }
    //Initialization of seekPaddingView
    if self.seekPaddingView == nil {
      self.seekPaddingView = SeekPaddingView(showInView: self.videoContainerView)
    }
    //seek forward/backward
    if isLeftSide {
      self.seekPaddingView?.seekBackward()
      self.seekPaddingView?.soughtTime = self.seekToByTapping! == 0 ? 10 : (self.seekPaddingView?.soughtTime)! + 10
    } else {
      self.seekPaddingView?.seekForward()
      self.seekPaddingView?.soughtTime = (self.seekToByTapping! != vod.duration.duration() - 1) ? (self.seekPaddingView?.soughtTime)! + 10 : 0
    }
    activeSlider?.setValue(Float(self.seekToByTapping!), animated: true)
    self.seekTo = self.seekToByTapping
    
    seekByTapDebouncer.call { [weak self] in
      self?.seekToByTapping = nil
      self?.timeOfLastTap = nil
      self?.seekTo = nil
      self?.updatePlayButtonImage()
      self?.seekPaddingView = nil
    }
  }
  
  @IBAction func handleTouchOnVideo(_ sender: UITapGestureRecognizer) {
    guard !landscapeSendButton.frame.contains(sender.location(in: landscapeSendButton.superview)) else {
      sendButtonPressed(landscapeSendButton)
      return
    }
    
    let onPlayButton = playButton.frame.contains(sender.location(in: videoContainerView)) && !isPlayerControlsHidden
    guard isControlsEnabled else { return }
    if isKeyboardShown {
      portraitTextView.endEditing(true)
      landscapeTextView.endEditing(true)
      return
    }
    
    guard !onPlayButton else { return }
    //MARK: seek by typing
    self.updatePlayButtonImage()
    if self.isSeekByTappingMode {
      self.isPlayerControlsHidden = true
      handleSeekByTapping(sender)
    } else {
      if self.timeOfLastTap == nil {
        self.timeOfLastTap = Date()
      } else {
        if Date().timeIntervalSince(self.timeOfLastTap!) > 0.3 {
          self.timeOfLastTap = nil
          self.seekToByTapping = nil
        }
        else {
          self.isSeekByTappingMode = true
          handleSeekByTapping(sender)
        }
      }
    }
    guard !self.isSeekByTappingMode else { return }
    self.isPlayerControlsHidden = !self.isPlayerControlsHidden
  }
  
  @objc
  func handleHideKeyboardGesture(_ sender: UITapGestureRecognizer) {
    if isKeyboardShown {
      portraitTextView.endEditing(true)
      landscapeTextView.endEditing(true)
    }
  }
  
  func setPlayerControlsHidden(_ isHidden: Bool) {
    if !isHidden {
      self.controlsDebouncer.call { }
    }
    controlsAppearingDebouncer.call { [weak self] in
      guard let `self` = self else { return }
      self.startLabel.text = self.videoContent.date.timeAgo()
      self.videoControlsView.isHidden = isHidden
      self.updateSeekThumbAppearance(isHidden: isHidden)
      
      self.controlsDebouncer.call { [weak self] in
        
        if self?.player.isPlayerPaused == false {
          if OrientationUtility.isLandscape && self?.seekTo != nil {
            return
          }
          self?.updateSeekThumbAppearance(isHidden: true)
          self?.videoControlsView.isHidden = true
        }
      }
    }
  }
  
  func updateSeekThumbAppearance(isHidden: Bool) {
    let thumbTintColor = isHidden ? .clear : UIColor.color("a_pink")
    self.portraitSeekSlider.tintColor = thumbTintColor
    self.portraitSeekSlider.isUserInteractionEnabled = !isHidden
    self.landscapeSeekSlider.tintColor = thumbTintColor
    self.landscapeSeekSlider.isUserInteractionEnabled = !isHidden
  }
  
  @IBAction func playButtonPressed(_ sender: UIButton) {
    if self.isVideoEnd {
      self.isVideoEnd = false
      self.player.seek(to: .zero)
    }
    
    if player.isPlayerPaused {
      if isPlayerError {
        player.reconnect()
      } else {
        player.play()
      }
      
      controlsDebouncer.call { [weak self] in
        self?.isPlayerControlsHidden = true
      }
      
    } else {
      player.pause()
      controlsDebouncer.call {}
    }
    updatePlayButtonImage()
  }
  
  func updatePlayButtonImage() {
    let image = (player.isPlayerPaused == false) ? UIImage.image("pause") : UIImage.image("play")
    self.playButton.setImage(image, for: .normal)
  }
  
  @IBAction func sendButtonPressed(_ sender: UIButton) {
    guard let user = User.current else {
      return
    }
    let textView = sender == portraitSendButton ? portraitTextView : landscapeTextView
    
    guard let text = textView?.text, text.trimmingCharacters(in: .whitespacesAndNewlines).count != 0 else {
      textView?.text.removeAll()
      return
    }
    guard let _ = videoContent as? AntViewerExt.Stream else {return}
    sender.isEnabled = false
    let message = Message(userID: "\(user.id)", nickname: user.displayName, text: text, avatarUrl: User.current?.imageUrl)
    textView?.text = ""
    self.chat?.send(message: message) { (error) in
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
  
  func shouldEnableMessageTextFields(_ enable: Bool) {
    self.portraitTextView.isEditable = enable && isChatEnabled
    self.landscapeTextView.isEditable = enable && isChatEnabled
    self.portraitSendButton.isEnabled = enable && isChatEnabled
    self.landscapeSendButton.isEnabled = enable && isChatEnabled
  }
  
  @IBAction func editProfileButtonPressed(_ sender: UIButton?) {
    if editProfileContainerView.isHidden {
      showEditProfileView()
    } else {
      dismissEditProfileView()
    }
  }
  
  var editProfileControllerIsLoading = false
  
  func showEditProfileView() {
    editProfileControllerIsLoading = true
    shouldEnableMessageTextFields(false)
    let editProfileController = EditProfileViewController(nibName: "EditProfileViewController", bundle: Bundle(for: type(of: self)))
    editProfileController.delegate = self
    addChild(editProfileController)
    editProfileContainerView.addSubview(editProfileController.view)
    editProfileController.didMove(toParent: self)
    editProfileController.view.translatesAutoresizingMaskIntoConstraints = false
    editProfileController.view.topAnchor.constraint(equalTo: editProfileContainerView.topAnchor).isActive = true
    editProfileController.view.leftAnchor.constraint(equalTo: editProfileContainerView.leftAnchor).isActive = true
    editProfileController.view.rightAnchor.constraint(equalTo: editProfileContainerView.rightAnchor).isActive = true
    editProfileController.view.bottomAnchor.constraint(equalTo: editProfileContainerView.bottomAnchor).isActive = true
    
    portraitEditProfileButton.tintColor = .white
    landscapeEditProfileButton.tintColor = .white
    
    editProfileContainerView.isHidden = false
  }
  
  func dismissEditProfileView() {
    shouldEnableMessageTextFields(true)
    portraitEditProfileButton.tintColor = .darkGray
    landscapeEditProfileButton.tintColor = .darkGray
    
    editProfileContainerView.isHidden = true
    let editProfile = children.first(where: { $0 is EditProfileViewController})
    editProfile?.willMove(toParent: nil)
    editProfile?.view.removeFromSuperview()
    editProfile?.removeFromParent()
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
    guard editProfileContainerView.isHidden else { return }
    let halfOfViewWidth = view.bounds.width / 2
    guard OrientationUtility.isLandscape, sender.location(in: view).x <= halfOfViewWidth else {return}
    
    var isRightDirection = false
    switch sender.direction {
    case .right:
      isRightDirection = true
      let isLeftInset = view.safeAreaInsets.left > 0
      chatFieldLeading = isKeyboardShown ? OrientationUtility.currentOrientatin == .landscapeRight && isLeftInset ? 30 : 0 : landscapeStreamInfoStackView.frame.origin.x
    case .left:
      chatFieldLeading = -currentTableView.frame.width
      
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
    dismissEditProfileView()
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
    infoPortraitView.isHidden = true
    portraitTableView.isHidden = true
    portraitBottomContainerView.isHidden = true
    let oldValue = shouldShowBigPollMessage
    shouldShowBigPollMessage = oldValue
  }
  
  @IBAction func closePollButtonPressed(_ sender: UIButton) {
    shouldShowBigPollMessage = false
  }
  
  @IBAction func goToButtonPressed(_ sender: UIButton) {
    let index = sender == nextButton ? 1 : -1
    
    guard let currentIndex = dataSource.videos.firstIndex(where: {$0.id == videoContent.id}), dataSource.videos.indices.contains(currentIndex + index),
      let navController = navigationController as? PlayerNavigationController else {
        return
    }
    let nextContent = dataSource.videos[currentIndex + index]
    let playerVC = PlayerController(nibName: "PlayerController", bundle: Bundle(for: type(of: self)))
    playerVC.videoContent = nextContent
    playerVC.dataSource = dataSource
    player.stop()
    navController.pushViewController(playerVC, withPopAnimation: sender == previousButton)
    
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
  fileprivate func keyboardWillChangeFrame(notification: NSNotification) {
    if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
      let isHidden = keyboardSize.origin.y == view.bounds.height
      isKeyboardShown = !isHidden
      
      let userInfo = notification.userInfo!
      let animationDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
      let rawAnimationCurve = (notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber).uint32Value << 16
      let animationCurve = UIView.AnimationOptions.init(rawValue: UInt(rawAnimationCurve))
      
      let bottomPadding = view.safeAreaInsets.bottom
      print(keyboardSize)
      if keyboardSize.width == view.frame.width {
        if isHidden {
          if editProfileControllerIsLoading { return }
          landscapeMessageHeight.constant = 30
          landscapeMessageBottomSpace.constant = 4
          portraitMessageBottomSpace.constant = 0
          chatFieldLeading = chatFieldLeading >= 0 ? landscapeStreamInfoStackView.frame.origin.x : chatFieldLeading
        } else if OrientationUtility.isLandscape {
          let isLeftInset = view.safeAreaInsets.left > 0
          chatFieldLeading = OrientationUtility.currentOrientatin == .landscapeRight && isLeftInset ? 30 : 0
          landscapeMessageBottomSpace.constant = keyboardSize.height - bottomPadding
        } else {
          portraitMessageBottomSpace.constant = keyboardSize.height - bottomPadding
        }
        landscapeMessageWidth.priority = UILayoutPriority(rawValue: isHidden ? 999 : 100)
        landscapeMessageTrailing.priority = UILayoutPriority(rawValue: isHidden ? 100 : 999)
      }
      
      
      adjustViewsFor(keyboardFrame: keyboardSize, with: animationDuration, animationCurve: animationCurve)
      
    }
  }
  
  func adjustViewsFor(keyboardFrame: CGRect, with animationDuration: TimeInterval, animationCurve: UIView.AnimationOptions) {
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
  
  func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
    
    if User.current?.displayName.isEmpty == true {
      if editProfileContainerView.isHidden, !editProfileControllerIsLoading {
        showEditProfileView()
      }
      return false
    }
    return true
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
      let isCurrentUser = Int(message.userID) == User.current?.id
      cell.messageLabel.text = message.text
      if isCurrentUser {
        cell.nameLabel.text = User.current?.displayName ?? message.nickname
        cell.avatarImageView.load(url: URL(string: User.current?.imageUrl ?? ""), placeholder: UIImage(named: "avaPic"))
      } else {
        cell.nameLabel.text = message.nickname
        cell.avatarImageView.load(url: URL(string: message.avatarUrl ?? ""), placeholder: UIImage(named: "avaPic"))
      }
    }
    
    return cell
  }
}


extension PlayerController: PollControllerDelegate {
  
  func pollControllerCloseButtonPressed() {
    pollController?.willMove(toParent: nil)
    pollController?.view.removeFromSuperview()
    pollController?.removeFromParent()
    pollController = nil
    pollContainerView.isHidden = true
    infoPortraitView.isHidden = false
    portraitTableView.isHidden = false
    portraitBottomContainerView.isHidden = false
    if activePoll != nil {
      shouldShowBigPollMessage = false
    }
  }
}

extension PlayerController: EditProfileControllerDelegate {
  func editProfileLoaded() {
    editProfileControllerIsLoading = false
  }
  
  func editProfileCloseButtonPressed(withChanges: Bool) {
    if withChanges {
      currentTableView.reloadData()
    }
    dismissEditProfileView()
  }
}

