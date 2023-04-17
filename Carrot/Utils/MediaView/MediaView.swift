//
//  MediaView.swift
//  Carrot
//
//  Created by ebamboo on 2022/10/9.
//

import UIKit

extension MediaView {
    
    var isImageFill: Bool {
        get {
            return _isImageFill
        }
        set {
            _isImageFill = newValue
        }
    }
    
    var isVideoFill: Bool {
        get {
            return _isVideoFill
        }
        set {
            _isVideoFill = newValue
        }
    }
    
    var itemList: [MediaBrowserItemModel] {
        get {
            return _itemList
        }
        set {
            _itemList = newValue
            _currentIndex = 0
            collectionView.reloadData()
            if !newValue.isEmpty {
                collectionView.scrollToItem(at: IndexPath(item: _currentIndex, section: 0), at: .centeredHorizontally, animated: false)
            }
            didEndScrolling()
        }
    }
    
    var currentIndex: Int {
        get {
            return _currentIndex
        }
    }
    
    func onDidShowMedia(_ handler: @escaping (_ index: Int) -> Void) {
        _onDidShowMedia = handler
    }
    
}

class MediaView: UIView {

    // MARK: - data
    
    private var _isImageFill = false
    private var _isVideoFill = false
    private var _itemList: [MediaBrowserItemModel] = []
    private var _currentIndex = 0
    private var _onDidShowMedia: ((_ index: Int) -> Void)?
    
    // MARK: - ui
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        layout.minimumInteritemSpacing = CGFloat.leastNonzeroMagnitude
        layout.minimumLineSpacing = 10
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.dataSource = self
        view.delegate = self
        view.allowsSelection = false
        view.isPagingEnabled = true
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = .black
        view.contentInsetAdjustmentBehavior = .never
        view.register(MediaViewImageCell.self, forCellWithReuseIdentifier: "MediaViewImageCell")
        view.register(MediaViewVideoCell.self, forCellWithReuseIdentifier: "MediaViewVideoCell")
        return view
    }()
    
    // MARK: - life circle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        insertSubview(collectionView, at: 0)
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        insertSubview(collectionView, at: 0)
        clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var collectionFrame = bounds
        collectionFrame.size.width += 10
        collectionView.frame = collectionFrame
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.itemSize = bounds.size
        if !_itemList.isEmpty {
            collectionView.scrollToItem(at: IndexPath(item: _currentIndex, section: 0), at: .centeredHorizontally, animated: false)
        }
        collectionView.backgroundColor = backgroundColor
    }
    
    private func didEndScrolling() {
        _onDidShowMedia?(_currentIndex)
        MediaViewCellManager.pause()
    }

}

extension MediaView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _itemList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let info = _itemList[indexPath.item]
        switch info {
        case .video:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaViewVideoCell", for: indexPath) as! MediaViewVideoCell
            cell.isFill = _isVideoFill
            cell.mediaInfo = info
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaViewImageCell", for: indexPath) as! MediaViewImageCell
            cell.isFill = _isImageFill
            cell.mediaInfo = info
            return cell
        }
    }
    
}

extension MediaView: UICollectionViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate { // 停止拖拽，不再滑动
            let indexF = scrollView.contentOffset.x / scrollView.bounds.size.width
            _currentIndex = Int(indexF + 0.5)
            didEndScrolling()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) { // 停止拖拽，滑动一段距离后不再滑动
        let indexF = scrollView.contentOffset.x / scrollView.bounds.size.width
        _currentIndex = Int(indexF + 0.5)
        didEndScrolling()
    }
    
}

