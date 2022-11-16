//
//  Created by ebamboo on 2021/11/26.
//

import UIKit

/// 网格样式展示图片、添加图片、删除图片
/// 展示网络图片时，只需要实现 var howShowWebImage: ((_ imageView: UIImageView, _ url: String) -> Void)? 即可
class FlowImageView: UICollectionView {
    
    // MARK: - 功能配置
    
    /// 是否自适应大小
    /// 如果为 true，则布局表现和 UILabel 设置多行之后的自适应布局表现类似
    @IBInspectable var autosize: Bool = false
    /// 最大 image 数量范围：[1,  ∞]
    @IBInspectable var maxImageCount: Int = 9
    
    /// 是否具备删除图片功能
    @IBInspectable var deletable: Bool = true
    /// 删除按钮图片 30 · 30
    @IBInspectable var deletableImage: UIImage? = UIImage(named: "bb-image-deletion")
    
    /// 是否具备添加图片功能
    @IBInspectable var addable: Bool = true
    /// 添加按钮图片
    @IBInspectable var addableImage: UIImage? = UIImage(named: "bb-image-addition")
    
    // MARK: - 布局配置
    
    /// 滑动方向，默认垂直方向 vertical。
    var direction = UICollectionView.ScrollDirection.vertical {
        didSet {
            guard let layout = collectionViewLayout as? FlowImageViewLayout else {  return }
            layout.scrollDirection = direction
        }
    }
    
    /// 区域内间距
    var degeInsets = UIEdgeInsets.zero {
        didSet {
            guard let layout = collectionViewLayout as? FlowImageViewLayout else {  return }
            layout.sectionInset = degeInsets
        }
    }
    
    /// item 最小间距
    var minItemSpacing = 10.0 {
        didSet {
            guard let layout = collectionViewLayout as? FlowImageViewLayout else {  return }
            layout.minimumInteritemSpacing = minItemSpacing
        }
    }
    
    /// line 最小间距
    var minLineSpacing = 10.0 {
        didSet {
            guard let layout = collectionViewLayout as? FlowImageViewLayout else {  return }
            layout.minimumLineSpacing = minItemSpacing
        }
    }
    
    /// 获取 itemSize 方法器
    var itemSizeReader: (FlowImageView) -> CGSize = { view in
        let lineNum = 4.0 // 垂直滑动时，每行 item 个数；水平滑动时，每列 item 个数；
        switch view.direction {
        case .vertical: // 垂直滑动布局
            let spacing = view.degeInsets.left + view.degeInsets.right + view.minItemSpacing * (lineNum - 1)
            let side = (view.bounds.width - spacing) / lineNum - 1
            return CGSize(width: side, height: side)
        default: // 水平滑动布局
            let spacing = view.degeInsets.top + view.degeInsets.bottom + view.minItemSpacing * CGFloat(lineNum - 1)
            let side = (view.bounds.height - spacing) / lineNum - 1
            return CGSize(width: side, height: side)
        }
    } {
        didSet {
            guard let layout = collectionViewLayout as? FlowImageViewLayout else {  return }
            layout.itemSizeReader = itemSizeReader
        }
    }
    
    // MARK: - 功能
    
    /// 删除图片之后回调（内部已删除该图片，实现该回调来更新对应的外部数据源）
    var didDeleteImage: ((_ index: Int) -> Void)?
    
    /// 点击添加图片按钮回调
    var willAddImages: ((_ flowImageView: FlowImageView) -> Void)?
    
    /// 点击图片回调
    var didClickImage: ((_ index: Int) -> Void)?
    
    /// imageView 如何展示网络图片 url
    var howShowWebImage: ((_ imageView: UIImageView, _ url: String) -> Void)?
    
    /// 试图使用新的数据源刷新视图
    /// 如果新的数据源数量大于 maxImageCount 则不能刷新视图
    func reloadImages(_ newImages: [ImageModel]) {
        guard newImages.count <= maxImageCount else { return }
        images = newImages
        reloadData()
        // 非自适应大小时，滑动到尾部
        autosize ? () : scrollToLastItem()
    }
    
    /// 试图添加新的图片并刷新视图
    /// 如果添加新的图片之后数量大于 maxImageCount 则不能添加图片
    func addImages(_ newImages: [ImageModel]) {
        guard images.count + newImages.count <= maxImageCount else { return }
        images += newImages
        reloadData()
        // 非自适应大小时，滑动到尾部
        autosize ? () : scrollToLastItem()
    }
    
    // MARK: - life
    
    /// 要展示的图片数据源，不包括添加按钮图片
    private var images: [ImageModel] = []
    
    /// 滑动到尾部
    private func scrollToLastItem() {
        let lastIndexPath: IndexPath = { [unowned self] in
            if self.addable, self.images.count < self.maxImageCount {
                let lastIndex = self.images.count
                return IndexPath(item: lastIndex, section: 0)
            } else {
                let lastIndex = self.images.count - 1
                return IndexPath(item: lastIndex, section: 0)
            }
        }()
        switch direction {
        case .vertical:
            self.scrollToItem(at: lastIndexPath, at: .bottom, animated: true)
        default:
            self.scrollToItem(at: lastIndexPath, at: .right, animated: true)
        }
    }
    
    ///
    /// 构造器 init
    ///
    init(frame: CGRect) {
        let layout = FlowImageViewLayout()
        layout.scrollDirection = direction
        layout.sectionInset = degeInsets
        layout.minimumLineSpacing = minLineSpacing
        layout.minimumInteritemSpacing = minItemSpacing
        layout.itemSizeReader = itemSizeReader
        super.init(frame: frame, collectionViewLayout: layout)
        dataSource = self
        delegate = self
        register(FlowImageViewCell.self, forCellWithReuseIdentifier: "FlowImageViewCell")
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        let layout = FlowImageViewLayout()
        layout.scrollDirection = direction
        layout.sectionInset = degeInsets
        layout.minimumLineSpacing = minLineSpacing
        layout.minimumInteritemSpacing = minItemSpacing
        layout.itemSizeReader = itemSizeReader
        collectionViewLayout = layout
        dataSource = self
        delegate = self
        register(FlowImageViewCell.self, forCellWithReuseIdentifier: "FlowImageViewCell")
    }
    
    ///
    /// 自适应大小时生效
    ///
    override var contentSize: CGSize {
        didSet {
            autosize ? invalidateIntrinsicContentSize() : ()
        }
    }
    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return contentSize
    }
    
}

extension FlowImageView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if addable, images.count < maxImageCount {
            return images.count + 1
        } else {
            return images.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlowImageViewCell", for: indexPath) as! FlowImageViewCell
        if addable, images.count < maxImageCount, indexPath.item == images.count { // 添加 item
            cell.imageView.image = addableImage
            cell.deleteBtn.isHidden = true
            cell.deleteHandler = nil
        } else { // 图片 item
            let image = images[indexPath.item]
            switch image {
            case .image(let rawValue):
                cell.imageView.image = rawValue
            case .url(let rawValue):
                howShowWebImage?(cell.imageView, rawValue)
            }
            cell.deleteBtn.isHidden = !deletable
            cell.deleteBtn.setImage(deletableImage, for: .normal)
            cell.deleteHandler = { [unowned self] in // 点击删除按钮
                self.images.remove(at: indexPath.item)
                self.reloadData()
                self.didDeleteImage?(indexPath.item)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        if addable, images.count < maxImageCount, indexPath.item == images.count { // 点击添加按钮
            willAddImages?(collectionView as! FlowImageView)
        } else { // 点击图片
            didClickImage?(indexPath.item)
        }
    }
    
}

extension FlowImageView {
    
    enum ImageModel {
        case image(rawValue: UIImage)
        case url(rawValue: String)
    }
}

extension FlowImageView {
    
    class FlowImageViewLayout: UICollectionViewFlowLayout {
        var itemSizeReader: ((FlowImageView) -> CGSize)?
        override func prepare() {
            super.prepare()
            if let reader = itemSizeReader, let view = collectionView as? FlowImageView {
                itemSize = reader(view)
            }
        }
    }
    
}

extension FlowImageView {
    
    class FlowImageViewCell: UICollectionViewCell {
        lazy var imageView: UIImageView = {
            let view = UIImageView()
            view.contentMode = .scaleAspectFill
            view.clipsToBounds = true
            self.contentView.insertSubview(view, at: 0)
            return view
        }()
        lazy var deleteBtn: UIButton = {
            let view = UIButton(type: .custom)
            view.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
            self.contentView.addSubview(view)
            return view
        }()
        var deleteHandler: (() -> Void)?
        override func layoutSubviews() {
            super.layoutSubviews()
            imageView.frame = contentView.bounds
            deleteBtn.frame = CGRect(x: contentView.bounds.size.width - 30, y: 0, width: 30, height: 30)
        }
        @objc func deleteAction() {
            deleteHandler?()
        }
    }
    
}
