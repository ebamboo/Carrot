//
//  FlowImageViewController.swift
//  Carrot
//
//  Created by ebamboo on 2021/11/27.
//

import UIKit

class FlowImageViewController: UIViewController {

//    @IBOutlet weak var testView: FlowImageView!
    var testView: FlowImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "FlowImageView"
        
        testView = FlowImageView.init(frame: .zero)
        testView.backgroundColor = .red
        view.addSubview(testView)
        testView.direction = .horizontal
        testView.maxImageCount = 16
        

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
        let frame = CGRect(x: view.safeAreaInsets.left, y: view.safeAreaInsets.top, width: view.bounds.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: view.bounds.size.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom)
        testView.frame = frame
        testView.updateLayout()
    }
    
}
