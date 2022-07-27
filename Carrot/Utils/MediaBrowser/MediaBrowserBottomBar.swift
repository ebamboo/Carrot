//
//  Created by ebamboo on 2022/7/24.
//

import UIKit

@objc class MediaBrowserBottomBar: UIView {
    
    @objc lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        return label
    }()
    
    @objc lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        return label
    }()
    
    lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .fill
        view.distribution = .equalSpacing
        view.spacing = 8
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        backgroundColor = .black.withAlphaComponent(0.5)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(detailLabel)
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        stackView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 8).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
        stackView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -8).isActive = true
    }
    
}
