//
//  BrowserTestSwiftViewController.swift
//  Carrot
//
//  Created by ebamboo on 2022/7/25.
//

import UIKit

class BrowserTestSwiftViewController: UIViewController {

    var itemList: [MediaBrowserItemModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Browser Swift"
        
        let testList = ["pingfen-yes", "01", "02", "03"]
        var tempArr: [MediaBrowserItemModel] = testList.map({ name in
            let model = MediaBrowserItemModel.localImage(img: UIImage(named: name)!)
            return model
        })
        
        let model1 = MediaBrowserItemModel.video(url: "http://1257982215.vod2.myqcloud.com/dcd3428cvodcq1257982215/8c6ec7b4387702293313409297/Sb2hYSuZFmEA.mp4")
        let model2 = MediaBrowserItemModel.video(url: "http://1257982215.vod2.myqcloud.com/dcd3428cvodcq1257982215/940cbaf7387702293313791287/xSxS1l5Uv3gA.mp4")
        let model3 = MediaBrowserItemModel.video(url: "http://1257982215.vod2.myqcloud.com/dcd3428cvodcq1257982215/914c35f5387702293313633992/dGevkJOtPHgA.mp4")
        
        tempArr.insert(model1, at: 0)
        tempArr.append(model2)
        tempArr.insert(model3, at: 3)
        
        
        tempArr.insert(.webImage(url: "https://gitee.com/ebamboo/Assets/raw/master/BBPictureBrowser/jpeg/01.jpeg"), at: 0)
        tempArr.insert(.webImage(url: "https://gitee.com/ebamboo/Assets/raw/master/BBPictureBrowser/gif/02.gif"), at: 0)
        
        itemList = tempArr
        
    }


    @IBAction func testAction(_ sender: Any) {
        
        let browser = MediaBrowser()
        browser.itemList = itemList
        browser.onDidShowMedia { [weak self] index, topBar, bottomBar in
            topBar.indexLabel.text = "\(index+1)/\(self?.itemList.count ?? 0)"
            let titleArr = (1...Int.random(in: 1...200)).map { _ in "恭喜" }
            bottomBar.titleLabel.text = titleArr.reduce("", { partialResult, item in
                partialResult + item
            })

            let detailArr = (1...Int.random(in: 1...200)).map { _ in "发财" }
            bottomBar.detailLabel.text = detailArr.reduce("", { partialResult, item in
                partialResult + item
            })
        }
        browser.open(on: navigationController!.view, at: 2)
        
    }

}
