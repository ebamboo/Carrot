//
//  MediaViewVideoCell.swift
//  Carrot
//
//  Created by ebamboo on 2022/10/9.
//

import UIKit
import BBPlayerView
import AVFoundation

class MediaViewVideoCell: UICollectionViewCell {
    
    // MARK: - public
    
    func tryPlay() {
        if status == .paused {
            MediaViewCellManager.pause()
            MediaViewCellManager.manage(self)
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
    
    var isFill = false {
        didSet {
            playerView.bb_videoGravity = isFill ? .aspectFill : .aspectFit
        }
    }
    
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
                voiceBtn.isHidden = true
                failureView.isHidden = true
                loadingView.startAnimating()
            case .failure:
                playerView.isHidden = true
                playImageView.isHidden = true
                voiceBtn.isHidden = true
                failureView.isHidden = false
                loadingView.stopAnimating()
            case .paused:
                playerView.isHidden = false
                playImageView.isHidden = false
                voiceBtn.isHidden = true
                failureView.isHidden = true
                loadingView.stopAnimating()
            case .playing:
                playerView.isHidden = false
                playImageView.isHidden = true
                voiceBtn.isHidden = false
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
            MediaViewCellManager.pause()
            MediaViewCellManager.manage(self)
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
    lazy var voiceBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 15
        btn.backgroundColor = .black.withAlphaComponent(0.2)
        btn.setImage(UIImage(named: "__media_voice_closed__"), for: .normal)
        btn.setImage(UIImage(named: "__media_voice_opened__"), for: .selected)
        btn.addTarget(self, action: #selector(voiceAction), for: .touchUpInside)
        playerView.addSubview(btn)
        return btn
    }()
    @objc func voiceAction() {
        voiceBtn.isSelected = !voiceBtn.isSelected
        setMuteForPlayer(mute: !voiceBtn.isSelected)
    }
    
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
        voiceBtn.frame = CGRect(x: playerView.bounds.width-16-30, y: playerView.bounds.height-30-30, width: 30, height: 30)
        failureView.center = CGPoint(x: bounds.width/2, y: bounds.height/2)
        loadingView.center = CGPoint(x: bounds.width/2, y: bounds.height/2)
    }
    
    
    func setMuteForPlayer(mute: Bool) {
        let player = playerView.value(forKeyPath: "player") as? AVPlayer
        player?.isMuted = mute
    }
    
}

extension MediaViewVideoCell: BBPlayerViewDelegate {
    
    func bb_playerView(_ playerView: BBPlayerView?, statusDidUpdated status: BBPlayerViewStatus) {
        switch status {
        case .unknown:
            self.status = .loading
        case .failed:
            self.status = .failure
        case .readyToPlay:
            self.status = .paused
            voiceBtn.isSelected = false
            setMuteForPlayer(mute: true)
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
