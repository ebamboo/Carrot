//
//  Created by ebamboo on 2022/7/25.
//

import UIKit

@objc class OCMediaBrowserItemModel: NSObject {
    @objc var videoUrl: String?
    @objc var imageUrl: String?
    @objc var image: UIImage?
}

@objc class OCMediaBrowser: MediaBrowser {

    @objc var oc_itemList: [OCMediaBrowserItemModel] {
        get {
            let list = itemList.map { item -> OCMediaBrowserItemModel in
                switch item {
                case .video(let url):
                    let model = OCMediaBrowserItemModel()
                    model.videoUrl = url
                    return model
                case .webImage(let url):
                    let model = OCMediaBrowserItemModel()
                    model.imageUrl = url
                    return model
                case .localImage(let img):
                    let model = OCMediaBrowserItemModel()
                    model.image = img
                    return model
                }
            }
            return list
        }
        set {
            let list = newValue.compactMap { item -> MediaBrowserItemModel? in
                if let url = item.videoUrl, !url.isEmpty {
                    return .video(url: url)
                }
                if let url = item.imageUrl, !url.isEmpty {
                    return .webImage(url: url)
                }
                if let img = item.image {
                    return .localImage(img: img)
                }
                return nil
            }
            itemList = list
        }
    }
    
    @objc var oc_currentIndex: Int {
        get {
            return currentIndex
        }
    }
    
    @objc var oc_onDidShowMedia: ((_ index: Int, _ topBar: MediaBrowserTopBar, _ bottomBar: MediaBrowserBottomBar) -> Void)? {
        get {
            return nil
        }
        set {
            newValue == nil ? () : onDidShowMedia(newValue!)
        }
    }
    
    @objc func oc_open(on view: UIView, at index: Int) {
        open(on: view, at: index)
    }
    
}
