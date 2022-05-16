//
//  FlowImageViewController.swift
//  Carrot
//
//  Created by ebamboo on 2021/11/27.
//

import UIKit

class FlowImageViewController: UIViewController {

    @IBOutlet weak var testView: FlowImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "FlowImageView"
        
        testView.itemSizeReader = { [unowned self] view in
            let side = (self.view.bounds.width - 30) / 4 - 1
            return CGSize(width: side, height: side)
        }
        
        testView.willAddImages = { [unowned testView] in
            let image = FlowImageView.ImageModel.image(rawValue: UIImage(named: "16")!)
            testView?.addImages([image])
        }
        testView.didDeleteImage = { index in
            print("delete index = \(index)")
        }
        testView.didClickImage = { index in
            print("click index = \(index)")
        }
        
        let images: [FlowImageView.ImageModel] = (1...9).map { i in
            let name = String(format: "%02d", i)
            let image = UIImage(named: name)!
            return FlowImageView.ImageModel.image(rawValue: image)
        }
        testView.reloadImages(images)
                                 
    }
    
}
