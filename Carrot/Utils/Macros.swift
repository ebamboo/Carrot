//
//  Macros.swift
//  Carrot
//
//  Created by ebamboo on 2021/4/21.
//

import UIKit

let SystemVersion = UIDevice.current.systemVersion
let AppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

let HomePath = NSHomeDirectory()
let DocumentsPath = HomePath + "/Documents"
let CachesPath = HomePath + "/Library/Caches"

var ScreenWidth: CGFloat {
    return UIScreen.main.bounds.size.width
}
var ScreenHeight: CGFloat {
    return UIScreen.main.bounds.size.height
}

var DeviceWidth: CGFloat {
    min(ScreenWidth, ScreenHeight)
}
var DeviceHeight: CGFloat {
    max(ScreenWidth, ScreenHeight)
}

var Portrait: Bool {
    return ScreenWidth < ScreenHeight
}
var Landscape: Bool {
    return ScreenWidth > ScreenHeight
}
