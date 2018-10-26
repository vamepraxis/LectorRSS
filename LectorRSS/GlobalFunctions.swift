//
//  GlobalFunctions.swift
//  LectorRSS
//
//  Created by MacBook Pro on 19/10/18.
//  Copyright © 2018 ccc. All rights reserved.
//

import Foundation
import UIKit

//MARK: - Vistas
class ViewsDesign {
    
    class func settingsNavigationItem(_ vc: UIViewController, navItem: UINavigationItem) {
        
        vc.navigationController?.navigationBar.barTintColor = colorPrimary
        vc.navigationController?.navigationBar.tintColor = UIColor.white
        vc.navigationController?.navigationBar.isTranslucent = false
        
        let nav = vc.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
    }
    
    class func hiddeNavigationItem(_ vc: UIViewController, navItem: UINavigationItem) {
        
        vc.navigationController?.navigationBar.barTintColor = UIColor.white
        vc.navigationController?.navigationBar.tintColor = UIColor.white
        vc.navigationController?.navigationBar.isTranslucent = true
        
        let nav = vc.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
    }
    
    class func translucentNavigationItem(_ vc: UIViewController) {
        
        vc.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        vc.navigationController?.navigationBar.shadowImage = UIImage()
        vc.navigationController?.navigationBar.isTranslucent = true
        
    }
    
    class func squareButton(_ button: UIButton) {
        
        button.layer.borderWidth = 2.0
        button.layer.borderColor = UIColor.white.cgColor
        
    }
    
    class func roundButton(_ button: UIButton, borderWidth:CGFloat, borderColor: CGColor) {
        
        button.layer.cornerRadius = button.frame.width/2
        button.layer.masksToBounds = true
        button.layer.borderWidth = borderWidth
        button.layer.borderColor = borderColor
        
    }
    
    class func borderTextField(_ textField: UITextField) {
        
        textField.layer.borderWidth = 2.0
        textField.layer.borderColor = UIColor.white.cgColor
        
    }
    
}

//MARK: - Loading View
class LoadingView {
    
    //MARK: Show loading screen
    class func showActivityIndicator(_ uiView: UIView) {
        DispatchQueue.main.async(execute: { () -> Void in
            container.frame = uiView.frame
            container.center = uiView.center
            container.backgroundColor = UIColorFromHex(0xffffff, alpha: 0.3)
            
            loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
            loadingView.center = uiView.center
            loadingView.backgroundColor = UIColorFromHex(0x444444, alpha: 0.7)
            loadingView.clipsToBounds = true
            loadingView.layer.cornerRadius = 10
            
            activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0);
            activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
            activityIndicator.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2);
            
            loadingLabel.textColor = UIColor.gray
            loadingLabel.textAlignment = NSTextAlignment.center
            loadingLabel.text = ""
            loadingLabel.frame = CGRect(x: 0, y: 0, width: 130, height: 30)
            
            loadingView.addSubview(activityIndicator)
            loadingView.addSubview(loadingLabel)
            container.addSubview(loadingView)
            uiView.addSubview(container)
            activityIndicator.startAnimating()
        })
    }
    
    //MARK: Hidde loading screen
    class func hideActivityIndicator(_ uiView: UIView) {
        DispatchQueue.main.async(execute: { () -> Void in
            activityIndicator.stopAnimating()
            container.removeFromSuperview()
        })
    }
    
    //MARK: Colors
    class func UIColorFromHex(_ rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
}

//MARK: Load view
class ProgressHUD: UIVisualEffectView {
    
    var text: String? {
        didSet {
            label.text = text
        }
    }
    
    let activityIndictor: UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
    let label: UILabel = UILabel()
    let blurEffect = UIBlurEffect(style: .light)
    let vibrancyView: UIVisualEffectView
    
    init(text: String) {
        self.text = text
        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        super.init(effect: blurEffect)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.text = ""
        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        contentView.addSubview(vibrancyView)
        contentView.addSubview(activityIndictor)
        contentView.addSubview(label)
        activityIndictor.startAnimating()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if let superview = self.superview {
            
            let width = superview.frame.size.width / 2.3
            let height: CGFloat = 50.0
            self.frame = CGRect(x: superview.frame.size.width / 2 - width / 2,
                                y: superview.frame.height / 2 - height / 2,
                                width: width,
                                height: height)
            vibrancyView.frame = self.bounds
            
            let activityIndicatorSize: CGFloat = 40
            activityIndictor.frame = CGRect(x: 5,
                                            y: height / 2 - activityIndicatorSize / 2,
                                            width: activityIndicatorSize,
                                            height: activityIndicatorSize)
            
            layer.cornerRadius = 8.0
            layer.masksToBounds = true
            label.text = text
            label.textAlignment = NSTextAlignment.center
            label.frame = CGRect(x: activityIndicatorSize + 5,
                                 y: 0,
                                 width: width - activityIndicatorSize - 15,
                                 height: height)
            label.textColor = UIColor.gray
            label.font = UIFont.boldSystemFont(ofSize: 16)
        }
    }
    
    func show() {
        self.isHidden = false
    }
    
    func hide() {
        self.isHidden = true
    }
}

//MARK: - Alert view
class AlertView {
    
    class func simple(_ titleAlert: String, messageAlert: String, titleAction: String) -> UIAlertController {
        
        let alert = UIAlertController(title: titleAlert, message: messageAlert, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: titleAction, style: .default) {
            (alert: UIAlertAction!) -> Void in
        }
        alert.addAction(defaultAction)
        return alert
    }
    
    class func presentAlert(_ selfView: UIViewController, alertShow: UIAlertController) {
        DispatchQueue.main.async(execute: { () -> Void in
            selfView.present(alertShow, animated: true, completion:nil)
        })
    }
    
}
