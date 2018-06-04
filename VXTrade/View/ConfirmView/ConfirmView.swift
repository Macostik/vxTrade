//
//  ConfirmView.swift
//  BinarySwipe
//
//  Created by Yuriy on 6/23/16.
//  Copyright © 2016 EasternPeak. All rights reserved.
//

import Foundation
import UIKit

class ConfirmView: UIView {

    var updateBlock: Block?
    internal let contentView = UIView()
    
    internal let xButton = Button(icon: "p".ls, textColor: UIColor.white)
    internal let titleView = UIView()
    
    internal var approveBlock: Block?
    internal var cancelBlock: Block?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0, alpha: 0.75)
        contentView.cornerRadius = 5.0
        contentView.clipsToBounds = true
        contentView.backgroundColor = UIColor.white
        titleView.backgroundColor = Color.caral
        add(contentView) { (make) in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self).offset(-60)
            make.width.equalTo(self).inset(Constants.screenWidth > 320 ? 30 : 15)
        }
        contentView.add(titleView) {
            $0.leading.top.trailing.equalTo(contentView)
            $0.height.equalTo(40)
        }
        
        xButton.addTarget(self, touchUpInside: #selector(self.cancel(_:)))
        setupSubViews()
    }
    
    func setupSubViews() {}
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showInView(_ view: UIView, success: Block? = nil, cancel: Block? = nil) {
        self.approveBlock = success
        self.cancelBlock = cancel
        frame = view.frame
        view.addSubview(self)
        backgroundColor = UIColor.clear
        contentView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        contentView.alpha = 0.0
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn , animations: { _ in
            self.contentView.transform = CGAffineTransform.identity
            }, completion: nil)
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn , animations: { () -> Void in
            self.backgroundColor = UIColor.black.withAlphaComponent(0.75)
            self.contentView.alpha = 1.0
            }, completion: nil)
        
    }
    
    func hide() {
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5, options: .curveEaseIn , animations: { _ in
            self.contentView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self.contentView.alpha = 0.0
            self.backgroundColor = UIColor.clear
            }, completion: { _ in
                self.removeFromSuperview()
        })
    }
    
    internal func cancel(_ sender: AnyObject) {
        cancelBlock?()
        hide()
    }
    
    internal func approve(_ sender: AnyObject) {
        approveBlock?()
        hide()
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if contentView.frame.contains(point) { return true }
        hide()
        return false
    }
}
