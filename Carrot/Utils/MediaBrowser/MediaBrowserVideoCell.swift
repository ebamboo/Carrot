//
//  Created by ebamboo on 2022/7/20.
//

import UIKit
import BBPlayerView

class MediaBrowserVideoCell: UICollectionViewCell {
    
    // MARK: - public
    
    func tryPlay() {
        if status == .paused {
            MediaBrowserCellManager.pause()
            MediaBrowserCellManager.manage(self)
            status = .playing
            playerView.bb_play()
        }
    }
    
    func tryPause() {
        if status == .playing {
            status = .paused
            playerView.bb_pause()
        }
    }
    
    // MARK: - data
    
    var onShouldPlay: (() -> Bool)!
    
    var mediaInfo: MediaBrowserItemModel! {
        didSet {
            switch mediaInfo {
            case .video(let url):
                playerView.bb_loadData(withURL: url)
            default:
                break
            }
        }
    }
    
    enum Status {
        case loading
        case failure
        case paused
        case playing
    }
    var status: Status = .loading {
        didSet {
            switch status {
            case .loading:
                playerView.isHidden = true
                playImageView.isHidden = true
                failureView.isHidden = true
                loadingView.startAnimating()
            case .failure:
                playerView.isHidden = true
                playImageView.isHidden = true
                failureView.isHidden = false
                loadingView.stopAnimating()
            case .paused:
                playerView.isHidden = false
                playImageView.isHidden = false
                failureView.isHidden = true
                loadingView.stopAnimating()
            case .playing:
                playerView.isHidden = false
                playImageView.isHidden = true
                failureView.isHidden = true
                loadingView.stopAnimating()
            }
        }
    }
    
    // MARK: - ui
    
    lazy var playerView: BBPlayerView = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(singleTapAction(_:)))
        tap.numberOfTapsRequired = 1
        let view = BBPlayerView()
        view.bb_delegate = self
        view.bb_videoGravity = .aspectFit
        view.addGestureRecognizer(tap)
        contentView.addSubview(view)
        return view
    }()
    @objc func singleTapAction(_ sender: UITapGestureRecognizer) {
        if status == .playing {
            status = .paused
            playerView.bb_pause()
            return
        }
        if status == .paused {
            MediaBrowserCellManager.pause()
            MediaBrowserCellManager.manage(self)
            status = .playing
            playerView.bb_play()
            return
        }
    }
    lazy var playImageView: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 85, height: 85))
        view.image = UIImage(named: "__media_browser_play__")
        playerView.addSubview(view)
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerView.frame = bounds
        playImageView.center = CGPoint(x: playerView.bounds.width/2, y: playerView.bounds.height/2)
        failureView.center = CGPoint(x: bounds.width/2, y: bounds.height/2)
        loadingView.center = CGPoint(x: bounds.width/2, y: bounds.height/2)
    }
    
}

extension MediaBrowserVideoCell: BBPlayerViewDelegate {
    
    func bb_playerView(_ playerView: BBPlayerView?, statusDidUpdated status: BBPlayerViewStatus) {
        switch status {
        case .unknown:
            self.status = .loading
        case .failed:
            self.status = .failure
        case .readyToPlay:
            if onShouldPlay() {
                MediaBrowserCellManager.pause()
                MediaBrowserCellManager.manage(self)
                self.status = .playing
                playerView?.bb_play()
            } else {
                self.status = .paused
            }
        default:
            break
        }
    }
    
    func bb_playerView(_ playerView: BBPlayerView?, progressDidUpdatedAtTime currentTime: CGFloat, totalTime: CGFloat, progress: CGFloat) {
        if progress >= 1.0 {
            playerView?.bb_seek(toProgress: 0, completionHandler: { finished in
                playerView?.bb_play()
            })
        }
    }
    
}
