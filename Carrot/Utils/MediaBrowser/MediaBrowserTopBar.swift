//
//  MediaBrowserTopBar.swift
//  SwiftDemo06
//
//  Created by ebamboo on 2022/7/24.
//

import UIKit

class MediaBrowserTopBar: UIView {

    var onClose: (() -> Void)?
    lazy var closeBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 15
        btn.setImage(UIImage(named: "__media_browser_close__"), for: .normal) // 14 pixel
        btn.backgroundColor = .black.withAlphaComponent(0.5)
        btn.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        addSubview(btn)
        return btn
    }()
    @objc func closeAction() {
        onClose?()
    }
    
    lazy var indexLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 120, height: 30)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .white
        addSubview(label)
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        closeBtn.center = CGPoint(x: safeAreaInsets.left + 16 + 15, y: bounds.height/2)
        indexLabel.center = CGPoint(x: bounds.width/2, y: bounds.height/2)
    }

}
