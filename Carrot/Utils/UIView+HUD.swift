//
//  UIView+HUD.swift
//  SwiftTools
//
//  Created by 征国科技 on 2021/5/17.
//

import MBProgressHUD

extension UIView {
    
    /// HUD 前景颜色
    private static let HUDForegroundColor = UIColor.white
    /// HUD 背景颜色
    private static let HUDBackgroundColor = UIColor.black
    /// HUD 展示时间
    private static let HUDDely: TimeInterval = 1.5
    
    func show(message: String, detail: String? = nil, completion: (() -> Void)? = nil) {
        let hud = MBProgressHUD.showAdded(to: self, animated: true)
        hud.mode = .text
        hud.removeFromSuperViewOnHide = true
        hud.contentColor = UIView.HUDForegroundColor
        hud.bezelView.color = UIView.HUDBackgroundColor
        hud.bezelView.style = .solidColor
        
        hud.label.text = message
        hud.detailsLabel.text = detail
        hud.completionBlock = completion
        hud.hide(animated: true, afterDelay: UIView.HUDDely)
    }
    
    func startLoading(with message: String? = nil) {
        let hud = MBProgressHUD.showAdded(to: self, animated: true)
        hud.mode = .indeterminate
        hud.removeFromSuperViewOnHide = true
        hud.contentColor = UIView.HUDForegroundColor
        hud.bezelView.color = UIView.HUDBackgroundColor
        hud.bezelView.style = .solidColor
        
        hud.label.text = message
    }
    
    func stopLoading(with message: String? = nil, completion: (() -> Void)? = nil) {
        guard let hud = MBProgressHUD.forView(self) else { return }
        if message == nil {
            hud.completionBlock = completion
            hud.hide(animated: true, afterDelay: UIView.HUDDely)
            return
        }
        hud.mode = .text
        hud.label.text = message
        hud.completionBlock = completion
        hud.hide(animated: true, afterDelay: UIView.HUDDely)
    }
       
}