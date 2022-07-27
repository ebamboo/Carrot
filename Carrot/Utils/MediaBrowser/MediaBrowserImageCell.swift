//
//  Created by ebamboo on 2022/7/20.
//

import UIKit
import SDWebImage

class MediaBrowserImageCell: UICollectionViewCell {
    
    // MARK: - data
    
    var mediaInfo: MediaBrowserItemModel! {
        didSet {
            status = .loading
            switch mediaInfo {
            case .localImage(let img):
                status = .success
                imageView.image = img
                resetScrollView()
            case .webImage(let url):
                let maxScreenPixelSide = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height) * UIScreen.main.scale
                imageView.sd_setImage(with: URL(string: url),
                                      placeholderImage: nil,
                                      options: .avoidAutoSetImage,
                                      context: [.imageThumbnailPixelSize: CGSize(width: maxScreenPixelSide, height: maxScreenPixelSide)],
                                      progress: nil) { [weak self] image, _, _, _ in
                    if image == nil {
                        self?.status = .failure
                    } else {
                        self?.status = .success
                        self?.imageView.image = image
                        self?.resetScrollView()
                    }
                }
            default:
                break
            }
        }
    }
    
    enum Status {
        case loading
        case failure
        case success
    }
    var status: Status = .loading {
        didSet {
            switch status {
            case .loading:
                scrollView.isHidden = true
                failureView.isHidden = true
                loadingView.startAnimating()
            case .failure:
                scrollView.isHidden = true
                failureView.isHidden = false
                loadingView.stopAnimating()
            case .success:
                scrollView.isHidden = false
                failureView.isHidden = true
                loadingView.stopAnimating()
            }
        }
    }
    
    // MARK: - ui
    
    lazy var scrollView: UIScrollView = {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction(_:)))
        doubleTap.numberOfTapsRequired = 2
        let view = UIScrollView()
        view.delegate = self
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.backgroundColor = .black
        view.contentInsetAdjustmentBehavior = .never
        view.minimumZoomScale = 1
        view.maximumZoomScale = 3
        view.addGestureRecognizer(doubleTap)
        contentView.addSubview(view)
        return view
    }()
    @objc func doubleTapAction(_ sender: UITapGestureRecognizer) {
        if scrollView.zoomScale != scrollView.maximumZoomScale {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        }
    }
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        scrollView.addSubview(view)
        return view
    }()
    
    lazy var failureView: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 37, height: 37))
        view.tintColor = .white
        view.image = UIImage(named: "__media_browser_error__")?.withRenderingMode(.alwaysTemplate)
        contentView.addSubview(view)
        return view
    }()
    
    lazy var loadingView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        if #available(iOS 13.0, *) {
            view.style = .medium
        } else {
            view.style = .white
        }
        view.hidesWhenStopped = true
        view.color = .white
        contentView.addSubview(view)
        return view
    }()
    
    // MARK: - life circle

    var lastBounds: CGRect = .zero
    override func layoutSubviews() {
        super.layoutSubviews()
        if lastBounds != bounds {
            lastBounds = bounds
            scrollView.frame = bounds
            resetScrollView()
            failureView.center = CGPoint(x: bounds.width/2, y: bounds.height/2)
            loadingView.center = CGPoint(x: bounds.width/2, y: bounds.height/2)
        }
    }
    
    // 使 scrollView 恢复初始状态并设置该状态下
    // scrollView 的 content size 和 imageView 的 frame
    func resetScrollView() {
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
        var size = imageView.image?.size ?? .zero
        if size.width > scrollView.bounds.width || size.height > scrollView.bounds.height { // 图片尺寸超出 scrollView.bounds.size
            let imageSize = imageView.image?.size ?? .zero
            let usaleSize = scrollView.bounds.size
            if imageSize.height * usaleSize.width / imageSize.width > usaleSize.height { // 图片高比较 "大"
                size = CGSize(width: imageSize.width * usaleSize.height / imageSize.height, height: usaleSize.height)
            } else { // 图片宽比较 "大"
                size = CGSize(width: usaleSize.width, height: imageSize.height * usaleSize.width / imageSize.width)
            }
        }
        scrollView.contentSize = size
        imageView.bounds = CGRect(origin: .zero, size: size)
        imageView.center = CGPoint(x: scrollView.bounds.width/2, y: scrollView.bounds.height/2)
    }
    
}

extension MediaBrowserImageCell: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let centerX = max(scrollView.bounds.width, scrollView.contentSize.width) / 2
        let centerY = max(scrollView.bounds.height, scrollView.contentSize.height) / 2
        imageView.center = CGPoint(x: centerX, y: centerY)
    }
    
}
