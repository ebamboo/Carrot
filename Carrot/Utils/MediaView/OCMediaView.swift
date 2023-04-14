//
//  OCMediaView.swift
//  Carrot
//
//  Created by ebamboo on 2022/10/10.
//

import Foundation

@objc class OCMediaView: MediaView {
    
    @objc var oc_isImageFill: Bool {
        get {
            return isImageFill
        }
        set {
            isImageFill = newValue
        }
    }
    
    @objc var oc_isVideoFill: Bool {
        get {
            return isVideoFill
        }
        set {
            isVideoFill = newValue
        }
    }
    
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
    
    @objc var oc_onDidShowMedia: ((_ index: Int) -> Void)? {
        get {
            return nil
        }
        set {
            newValue == nil ? () : onDidShowMedia(newValue!)
        }
    }
    
}
