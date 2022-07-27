//
//  Created by ebamboo on 2022/7/24.
//

import UIKit

@objc class MediaBrowserTopBar: UIView {

    @objc lazy var closeBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.bounds = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 15
        btn.setImage(UIImage(named: "__media_browser_close__"), for: .normal) // 14 pixel
        btn.backgroundColor = .black.withAlphaComponent(0.5)
        self.addSubview(btn)
        return btn
    }()
    
    @objc lazy var indexLabel: UILabel = {
        let label = UILabel()
        label.bounds = CGRect(x: 0, y: 0, width: 120, height: 30)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .white
        self.addSubview(label)
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        closeBtn.center = CGPoint(x: safeAreaInsets.left + 16 + closeBtn.bounds.width/2, y: bounds.height/2)
        indexLabel.center = CGPoint(x: bounds.width/2, y: bounds.height/2)
    }

}
