//
//  FlowImageView.swift
//  Carrot
//
//  Created by ebamboo on 2021/11/26.
//

import SDWebImage

/// 网格样式展示图片
/// 可添加、删除图片
class FlowImageView: UICollectionView {
    
    /// image 模型
    enum ImageModel {
        case image(rawValue: UIImage)
        case url(rawValue: String)
    }
    
    /// 滑动方向
    var direction: UICollectionView.ScrollDirection {
        get {
            let layout = collectionViewLayout as! UICollectionViewFlowLayout
            return layout.scrollDirection
        }
        set {
            let layout = collectionViewLayout as! UICollectionViewFlowLayout
            layout.scrollDirection = newValue
        }
    }
    /// 区域内间距
    var degeInsets: UIEdgeInsets = UIEdgeInsets.zero
    /// item 最小间距
    var minItemSpacing: CGFloat = 10.0
    /// line 最小间距
    var minLineSpacing: CGFloat = 10.0
    /// 最大 image 数量范围：[1,  ∞]
    var maxImageCount = 9
    /// 每行 item 数量
    /// 如果设置了 itemSIze 则忽略该属性
    var lineItemCount = 3
    /// 每次将要布局 FlowImageView 时都会试图读取 itemSize
    /// 如果没有设置则根据 lineItemCount 进行计算
    /// 并且设定之后要执行 reloadData() 使之生效
    /// 一般在 superView 中的 layoutSubviews() 方法
    /// 或者 UIViewController 中的 viewWillLayoutSubviews() 方法进行设定
    /// 可根据实际情况决定是否需要在 viewDidLayoutSubviews() 方法中进行设定
    var itemSize: CGSize?
    
    /// 直接赋值会刷新 collection view
    /// 赋值时要注意不能超过最大限制数量
    /// 不可以在外部添加和删除 item
    var images: [ImageModel] = [] {
        didSet {
            reloadData()
        }
    }
    
    /// 是否具备添加图片功能
    var addable = false
    /// 添加按钮图片
    var addableImage: UIImage?
    ///
    /// 点击添加按钮回调
    ///
    private var additionHandler: (() -> Void)?
    func additionHandler(_ handler: @escaping () -> Void) {
        additionHandler = handler
    }
    /// 添加一个 image
    func addImage(_ image: ImageModel) {
        guard addable, images.count < maxImageCount else { return }
        images.append(image)
        self.reloadData()
        // 最后一个元素下表
        let lastIndex = images.count - (images.count == maxImageCount ? 1 : 0)
        let lastIndexPath = IndexPath(item: lastIndex, section: 0)
        // 滑动到尾部
        switch direction {
        case .vertical:
            self.scrollToItem(at: lastIndexPath, at: .bottom, animated: true)
        default:
            self.scrollToItem(at: lastIndexPath, at: .right, animated: true)
        }
    }
    
    /// 是否具备删除图片功能
    var deletable = false
    /// 删除按钮图片
    var deletableImage: UIImage?
    
    ///
    /// 点击图片回调
    ///
    private var clickImageHandler: ((_ index: Int) -> Void)?
    func clickImageHandler(_ handler: @escaping (_ index: Int) -> Void) {
        clickImageHandler = handler
    }
    
    ///
    /// 构造器 init
    ///
    init(frame: CGRect) {
        super.init(frame: frame, collectionViewLayout: UICollectionViewFlowLayout())
        dataSource = self
        delegate = self
        register(FlowImageViewCell.self, forCellWithReuseIdentifier: "FlowImageViewCell")
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension FlowImageView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if addable, images.count < maxImageCount {
            return images.count + 1
        } else {
            return images.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlowImageViewCell", for: indexPath) as! FlowImageViewCell
        // deleteBtn 设置
        cell.deleteBtn.isHidden = !deletable
        cell.deleteBtn.setImage(deletableImage, for: .normal)
        cell.deleteHandler = {
            self.images.remove(at: indexPath.item)
            self.reloadData()
        }
        // imageView 设置
        if addable, images.count < maxImageCount, indexPath.item == images.count { // 添加 item
            cell.imageView.image = addableImage
            cell.deleteBtn.isHidden = true
        } else { // 图片 item
            cell.image = images[indexPath.item]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        if addable, images.count < maxImageCount, indexPath.item == images.count { // 添加 item
            additionHandler?()
        } else { // 图片 item
            clickImageHandler?(indexPath.item)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if itemSize == nil {
            let usableWidth = collectionView.bounds.size.width - CGFloat(lineItemCount - 1) * minItemSpacing - degeInsets.left - degeInsets.right
            let side = usableWidth / CGFloat(lineItemCount)
            return CGSize(width: side, height: side)
        } else {
            return itemSize!
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return degeInsets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minLineSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return minItemSpacing
    }
    
}

class FlowImageViewCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    let deleteBtn: UIButton = {
        let view = UIButton(type: .custom)
        view.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(deleteBtn)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
        deleteBtn.frame = CGRect(x: contentView.bounds.size.width-30, y: 0, width: 30, height: 30)
    }
    
    @objc func deleteAction() {
        deleteHandler?()
    }
    
    var image: FlowImageView.ImageModel? {
        didSet {
            switch image {
            case .image(let rawValue):
                imageView.image = rawValue
            case .url(let rawValue):
                imageView.sd_setImage(with: URL(string: rawValue))
            case .none:
                imageView.image = nil
            }
        }
    }
    var deleteHandler: (() -> Void)?
    
}
