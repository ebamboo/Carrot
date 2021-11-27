//
//  FlowImageViewController.swift
//  Carrot
//
//  Created by ebamboo on 2021/11/27.
//

import UIKit

class FlowImageViewController: UIViewController {

    let testView = FlowImageView(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "FlowImageView"
        view.addSubview(testView)
        

        // 添加功能
        testView.addable = true
        testView.additionHandler {
            self.testView.addImage(.image(rawValue: UIImage(named: "16")!))
        }
        // 删除功能
        testView.deletable = true
        // 点击图片
        testView.clickImageHandler { index in
            print("index = \(index)")
        }
        
        // 数据
        testView.images = (1...6).map({ i in
            let name = String(format: "%02d", i)
            let image = UIImage(named: name)!
            return FlowImageView.ImageModel.image(rawValue: image)
        })
        
        
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        testView.frame = view.bounds
        let usable = view.bounds.size.width - 10 * 3
        let width = usable / 4.0
        let height = width * 3 / 4
        testView.itemSize = CGSize(width: width, height: height)
        testView.reloadData()
    }

}
