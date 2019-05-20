//
//  StreamListController.swift
//  viewer-module
//
//  Created by Mykola Vaniurskyi on 12/4/18.
//  Copyright © 2018 Mykola Vaniurskyi. All rights reserved.
//

import UIKit
import AVKit
import AntViewerExt

private let reuseIdentifier = "NewStreamCell"

class StreamListController: UICollectionViewController {
  
  fileprivate var cellWidth: CGFloat!
  fileprivate var cellHeight: CGFloat!
  
  fileprivate var dataSource: DataSource = {
    return DataSource.shared
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    URLCache.shared.removeAllCachedResponses()
    setupNavigationBar()
    setupCollectionView()
    
    NotificationCenter.default.addObserver(forName: NSNotification.Name.init(rawValue: "StreamsUpdated"), object: nil, queue: .main) { [weak self](notification) in
      self?.collectionView.reloadData()
    }
  }
  
  private func setupNavigationBar() {
    navigationController?.navigationBar.barTintColor = collectionView.backgroundColor
    navigationController?.navigationBar.updateBackgroundColor()
    let closeButton = UIButton(type: .custom)
    closeButton.tintColor = .white
    closeButton.setImage(UIImage.image("cross"), for: .normal)
    
    closeButton.addTarget(self, action: #selector(closeButtonPressed(_:)), for: .touchUpInside)
    closeButton.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
    
    navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: closeButton)]
    
    let changeHost = UIButton(type: .custom)
    changeHost.tintColor = .white
    
    changeHost.setTitle("", for: .normal)

    let gestureRec = UITapGestureRecognizer(target: self, action:  #selector(changeHost(_:)))
    gestureRec.numberOfTapsRequired = 3
    changeHost.addGestureRecognizer(gestureRec)
    changeHost.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
    
    navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: changeHost)]
  }
  
  private func setupCollectionView() {
    let cellNib = UINib(nibName: "NewStreamCell", bundle: Bundle(for: type(of: self)))
    collectionView.register(cellNib, forCellWithReuseIdentifier: reuseIdentifier)
    let headerNib = UINib(nibName: "HeaderView", bundle: Bundle(for: type(of: self)))
    collectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "AntHeaderView")
    cellWidth = view.bounds.width * 0.85
    cellHeight = cellWidth * 0.56
    collectionView.reloadData()
  }
  
  @objc
  private func changeHost(_ sender: UIButton) {
    presentChangeHostAlert()
  }
  
  @objc
  private func closeButtonPressed(_ sender: UIButton) {
    dismiss(animated: true, completion: nil)
  }
  
  fileprivate func configureCell(_ cell: NewStreamCell, forIndexPath indexPath: IndexPath) -> NewStreamCell {
    let item = getItemForIndexPath(indexPath)
    cell.streamNameLabel.text = item.title
    cell.streamDurationView.isHidden = item is AntViewerExt.Stream
    cell.liveLabel.isHidden = item is Video
    cell.startTimeLabel.text = item.date.timeAgo()
    if let item = item as? Video {
      cell.imagePlaceholder.image = UIImage.image("\(item.id)")
      cell.viewersCountLabel.text = "\(item.viewersCount) views"
      cell.streamDurationLabel.text = item.duration.durationString
    } else {
      cell.imagePlaceholder.load(url: URL(string: item.thumbnailUrl), placeholder: UIImage.image("tempPic"))
//      cell.imagePlaceholder.sd_setImage(with: URL(string: item.thumbnailUrl), placeholderImage: UIImage.image("tempPic"))
      cell.viewersCountLabel.text = "\(item.viewersCount) Viewers"
    }
    cell.layoutSubviews()
    return cell
  }
  
  fileprivate func getItemForIndexPath(_ indexPath: IndexPath) -> VideoContent {
    if dataSource.streams.isEmpty || dataSource.videos.isEmpty {
      return dataSource.streams.isEmpty ? dataSource.videos[indexPath.row] : dataSource.streams[indexPath.row]
    } else {
      return indexPath.section == 0 ? dataSource.streams[indexPath.row] : dataSource.videos[indexPath.row]
    }
  }
}


// MARK: UICollectionViewDataSource
extension StreamListController {
  
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return dataSource.streams.isEmpty || dataSource.videos.isEmpty ? 1 : 2
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if dataSource.streams.isEmpty || dataSource.videos.isEmpty {
      return dataSource.streams.isEmpty ? dataSource.videos.count : dataSource.streams.count
    }
    return section == 0 ? dataSource.streams.count : dataSource.videos.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! NewStreamCell
    return configureCell(cell, forIndexPath: indexPath)
  }
  
  override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    guard kind == UICollectionView.elementKindSectionHeader else {
      return UICollectionReusableView()
    }
    let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "AntHeaderView", for: indexPath) as! HeaderView
    header.titleLabel.isHidden = indexPath.section != 0
    header.separatoView.isHidden = indexPath.section == 0
    if dataSource.videos.isEmpty && dataSource.streams.isEmpty {
      header.titleLabel.text = "No content yet :("
    }
    
    return header
  }
  
}

// MARK: UICollectionViewDelegate
extension StreamListController {
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let item = getItemForIndexPath(indexPath)
    let playerVC = PlayerController.init(nibName: "PlayerController", bundle: Bundle(for: type(of: self)))
    playerVC.videoContent = item
    present(playerVC, animated: true, completion: nil)
  }
  
}

// MARK: UICollectionViewDelegateFlowLayout
extension StreamListController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: cellWidth, height: cellHeight)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    let sideInset = (collectionView.bounds.width - cellWidth)/2
    return UIEdgeInsets(top: 30, left: sideInset, bottom: 30, right: sideInset)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 30
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return CGSize(width: collectionView.bounds.width, height: section == 0 ? 50 : 1)
  }
  
  
}

extension UIImageView {
  /// Loads image from web asynchronosly and caches it, in case you have to load url
  /// again, it will be loaded from cache if available
  func load(url: URL?, placeholder: UIImage?, cache: URLCache? = nil) {
    guard let url = url else { return }
    let cache = cache ?? URLCache.shared
    let request = URLRequest(url: url)
    if let data = cache.cachedResponse(for: request)?.data, let image = UIImage(data: data) {
      self.image = image
    } else {
      self.image = placeholder
      URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
        if let data = data, let response = response, ((response as? HTTPURLResponse)?.statusCode ?? 500) < 300, let image = UIImage(data: data) {
          let cachedData = CachedURLResponse(response: response, data: data)
          cache.storeCachedResponse(cachedData, for: request)
          DispatchQueue.main.async {
            self.image = image
          }
        }
      }).resume()
    }
  }
}
