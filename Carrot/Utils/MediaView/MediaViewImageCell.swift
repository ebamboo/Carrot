//
//  MediaViewImageCell.swift
//  Carrot
//
//  Created by ebamboo on 2022/10/9.
//

import UIKit

class MediaViewImageCell: UICollectionViewCell {
    
    // MARK: - extern
    
    var isFill = false
    
    var mediaInfo: MediaBrowserItemModel! {
        didSet {
            switch mediaInfo {
            case .localImage(let img):
                imageView.image = img
                resetImageView()
            case .webImage(let url):
                let maxScreenPixelSide = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height) * UIScreen.main.scale
                imageView.sd_setImage(with: URL(string: url),
                                      placeholderImage: nil,
                                      options: .avoidAutoSetImage,
                                      context: [.imageThumbnailPixelSize: CGSize(width: maxScreenPixelSide, height: maxScreenPixelSide)],
                                      progress: nil) { [weak self] image, _, _, _ in
                    self?.imageView.image = image
                    self?.resetImageView()
                }
            default:
                break
            }
        }
    }
    
    // MARK: - life
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        contentView.addSubview(view)
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        resetImageView()
    }
    
    func resetImageView() {
        guard !isFill else {
            imageView.frame = bounds
            return
        }
        var size = imageView.image?.size ?? .zero
        if size.width > bounds.width || size.height > bounds.height {
            let imageSize = imageView.image?.size ?? .zero
            let usaleSize = bounds.size
            if imageSize.height * usaleSize.width / imageSize.width > usaleSize.height { // 图片高比较 "大"
                size = CGSize(width: imageSize.width * usaleSize.height / imageSize.height, height: usaleSize.height)
            } else { // 图片宽比较 "大"
                size = CGSize(width: usaleSize.width, height: imageSize.height * usaleSize.width / imageSize.width)
            }
        }
        imageView.bounds = CGRect(origin: .zero, size: size)
        imageView.center = CGPoint(x: bounds.width/2, y: bounds.height/2)
    }
    
}
