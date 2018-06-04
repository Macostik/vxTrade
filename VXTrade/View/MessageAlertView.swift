//
//  MessageAlertView.swift
//  VXTrade
//
//  Created by Yuriy on 1/10/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import UIKit
import SnapKit

protocol Appearance {
    var isIconHidden: Bool { get }
    var backgroundColor: UIColor  { get }
    var textColor: UIColor { get }
}

struct DefaultMessageAlertViewAppearance : Appearance {
    var isIconHidden: Bool { return false }
    var backgroundColor: UIColor  { return UIColor.clear }
    var textColor: UIColor { return UIColor.white }
}

class MessageAlertView: UIView {
    
    static let DismissalDelay: TimeInterval = 4.0
    fileprivate static let messageAlertView = MessageAlertView()
    var topMessageInset: Constraint!
    var queuedMessages = Set<String>()
    var leftIconView = Label(icon: "m", size: 21)
    var rightIconView = Label(icon: "n", size: 17)
    var messageLabel = UILabel()
    var dismissBlock: Block?
    
    required init() {
        super.init(frame: CGRect.zero)
        leftIconView.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
        rightIconView.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
        messageLabel.numberOfLines = 2
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        addSubview(blurView)
        blurView.snp.makeConstraints { $0.edges.equalTo(self) }
        let colorView = UIView()
        colorView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        addSubview(colorView)
        colorView.snp.makeConstraints { $0.edges.equalTo(self) }
        addSubview(leftIconView)
        addSubview(messageLabel)
        addSubview(rightIconView)
        leftIconView.snp.makeConstraints {
            $0.leading.equalTo(self).offset(12)
            $0.trailing.equalTo(messageLabel.snp.leading).offset(-12)
            $0.centerY.equalTo(messageLabel)
        }
        messageLabel.snp.makeConstraints {
            topMessageInset = $0.top.equalTo(self).inset(10).constraint
            $0.bottom.equalTo(self).inset(10)
            $0.trailing.lessThanOrEqualTo(rightIconView.snp.leading).offset(-12)
            $0.height.greaterThanOrEqualTo(21)
        }
        rightIconView.snp.makeConstraints {
            $0.trailing.equalTo(self).inset(12)
            $0.centerY.equalTo(messageLabel)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func show(_ message: String) {
        messageAlertView.show(message)
    }
    
    func show(_ message: String, inViewController viewController: UIViewController? = nil, appearence: Appearance = DefaultMessageAlertViewAppearance()) {
        if message.isEmpty || (superview != nil && messageLabel.text == message) { return }
        
        queuedMessages.insert(message)
        
        weak var _viewController = viewController ?? UIViewController.actionSheetAppearanceViewController(self)
        
        guard let viewController = _viewController else {
            self.queuedMessages.remove(message)
            return
        }
        let view = viewController.view
        let referenceView = viewController.actionSheetAppearanceReferenceView(self)
        
        self.messageLabel.text = message
        self.leftIconView.isHidden = appearence.isIconHidden
        self.backgroundColor = appearence.backgroundColor
        self.messageLabel.textColor = appearence.textColor
        
        if self.superview != view {
            self.removeFromSuperview()
            view?.addSubview(self)
            self.addConstraints(view!, referenceView: referenceView)
            self.layoutIfNeeded()
            self.alpha = 0.0
            UIView.performAnimated(true) { self.alpha = 1.0 }
        }
        
        self.dismissBlock = {
            self.queuedMessages.remove(message)
            
        }
        self.enqueueSelector(#selector(MessageAlertView.dismiss), delay: MessageAlertView.DismissalDelay)
    }
    
    fileprivate func addConstraints( _ view: UIView, referenceView: UIView) {
        snp.remakeConstraints {
            $0.width.centerX.equalTo(referenceView)
            if referenceView == view  {
                $0.top.equalTo(referenceView)
                topMessageInset.update(offset: UIApplication.shared.isStatusBarHidden ? 10 : 30)
            } else {
                $0.top.equalTo(referenceView.snp.bottom)
                topMessageInset.update(offset: 10)
            }
        }
    }
    
    func dismiss() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(MessageAlertView.dismiss), object: nil)
        UIView.animate(withDuration: 0.25, animations: { self.alpha = 0 }, completion: { (_) -> Void in
            self.removeFromSuperview()
            self.dismissBlock?()
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        dismiss()
    }
}

extension UIViewController {
    
    class func actionSheetAppearanceViewController(_ actionSheet: UIView?) -> UIViewController? {
        var visibleViewController: UIViewController? = UINavigationController.main
        var presentedViewController = visibleViewController?.presentedViewController
        while let _presentedViewController = presentedViewController {
            if _presentedViewController.definesactionSheetAppearance() {
                visibleViewController = presentedViewController
                presentedViewController = visibleViewController?.presentedViewController
            } else {
                presentedViewController = nil
            }
        }
        if let navigationController = visibleViewController as? UINavigationController {
            visibleViewController = navigationController.topViewController
        }
        return visibleViewController?.actionSheetAppearanceViewController(actionSheet)
    }
    
    func definesactionSheetAppearance() -> Bool {
        return true
    }
    
    func actionSheetAppearanceViewController(_ actionSheet: UIView?) -> UIViewController {
        return self
    }
    
    func actionSheetAppearanceReferenceView(_ actionSheet: UIView) -> UIView {
        return view
    }
}

extension BaseViewController {
    
    override func actionSheetAppearanceReferenceView(_ actionSheet: UIView) -> UIView {
        return navigationBar ?? view
    }
}

extension UIAlertController {
    override func definesactionSheetAppearance() -> Bool {
        return false
    }
}

extension UIActivityViewController {
    override func definesactionSheetAppearance() -> Bool {
        return false
    }
}
