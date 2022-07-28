//
//  Created by ebamboo on 2022/7/22.
//

import UIKit

extension MediaBrowser {
    
    var itemList: [MediaBrowserItemModel] {
        get {
            return _itemList
        }
        set {
            _itemList = newValue
        }
    }
    
    var currentIndex: Int {
        get {
            return _currentIndex
        }
    }
    
    func onDidShowMedia(_ handler: @escaping (_ index: Int, _ topBar: MediaBrowserTopBar, _ bottomBar: MediaBrowserBottomBar) -> Void) {
        _onDidShowMedia = handler
    }
    
    func open(on view: UIView, at index: Int) {
        guard 0 <= index, index < _itemList.count else { return }
        view.addSubview(self)
        _currentIndex = index
        collectionView.reloadData()
        collectionView.scrollToItem(at: IndexPath(item: _currentIndex, section: 0), at: .centeredHorizontally, animated: false)
        didEndScrolling()
    }
    
}

class MediaBrowser: UIView {
    
    // MARK: - data
    
    private var _itemList: [MediaBrowserItemModel] = []
    private var _currentIndex = 0
    private var _onDidShowMedia: ((_ index: Int, _ topBar: MediaBrowserTopBar, _ bottomBar: MediaBrowserBottomBar) -> Void)?
    
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
        view.register(MediaBrowserImageCell.self, forCellWithReuseIdentifier: "MediaBrowserImageCell")
        view.register(MediaBrowserVideoCell.self, forCellWithReuseIdentifier: "MediaBrowserVideoCell")
        return view
    }()
    
    private lazy var topBar: MediaBrowserTopBar = {
        let bar  = MediaBrowserTopBar()
        bar.closeBtn.addTarget(self, action: #selector(removeFromSuperview), for: .touchUpInside)
        return bar
    }()
    
    private lazy var bottomBar: MediaBrowserBottomBar = {
        let bar  = MediaBrowserBottomBar()
        return bar
    }()
    
    // MARK: - life circle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        frame = superview?.bounds ?? .zero
        var collectionFrame = bounds
        collectionFrame.size.width += 10
        collectionView.frame = collectionFrame
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.itemSize = bounds.size
        collectionView.scrollToItem(at: IndexPath(item: _currentIndex, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    private func commonInit() {
        addSubview(collectionView)
        addSubview(topBar)
        topBar.translatesAutoresizingMaskIntoConstraints = false
        topBar.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        topBar.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        topBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        topBar.heightAnchor.constraint(equalToConstant: 44).isActive = true
        addSubview(bottomBar)
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        bottomBar.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        bottomBar.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        clipsToBounds = true
    }
    
    private func didEndScrolling() {
        _onDidShowMedia?(_currentIndex, topBar, bottomBar)
        let info = _itemList[_currentIndex]
        switch info {
        case .video:
            let cell = collectionView.cellForItem(at: IndexPath(item: _currentIndex, section: 0)) as? MediaBrowserVideoCell
            cell?.tryPlay()
        default:
            MediaBrowserCellManager.pause()
        }
    }
    
}

extension MediaBrowser: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _itemList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let info = _itemList[indexPath.item]
        switch info {
        case .video:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaBrowserVideoCell", for: indexPath) as! MediaBrowserVideoCell
            cell.mediaInfo = info
            cell.onShouldPlay = { [unowned self] () -> Bool in
                return self._currentIndex == indexPath.item
            }
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaBrowserImageCell", for: indexPath) as! MediaBrowserImageCell
            cell.mediaInfo = info
            return cell
        }
    }
    
}

extension MediaBrowser: UICollectionViewDelegate {
    
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
