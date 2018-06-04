//
//  AmountTradeView.swift
//  VXTrade
//
//  Created by Yuriy on 1/10/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import UIKit
import SnapKit

class AmountTradeView: MessageAlertView {
    
    static let sharedView = AmountTradeView()
    var bottomVeiwInset: Constraint!
    let widthButton = Constants.screenWidth/4 - 12.5
    var containerButtons = [Button]()
    
    required init() {
        super.init()
        
        User.notifier.subscribe(self, block: {[weak self] owner, user in
            Dispatch.mainQueue.async({
                self?.dismiss()
            })
        })
        
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        addSubview(blurView)
        blurView.snp.makeConstraints { $0.edges.equalTo(self) }
        let colorView = UIView()
        colorView.backgroundColor = UIColor.black
        addSubview(colorView)
        colorView.snp.makeConstraints { $0.edges.equalTo(self) }
        
        let click: ObjectBlock = {[weak self] _ in
            let amount = self?.containerButtons.filter({ $0.isSelected == true }).first?.titleLabel?.text ?? ""
            User.currentUser?.setupPreferedAmountTrade(amount)
        }
        
        let doneButton = specify(Button(), {
            $0.setTitle("Done".ls, for: UIControlState())
            $0.titleLabel?.textColor = UIColor.white
            $0.backgroundColor = UIColor.gray
            $0.layer.cornerRadius = 5.0
        })
        doneButton.click(click)
        add(doneButton, {
            $0.centerX.equalTo(self)
            $0.bottom.equalTo(self).offset(-20)
            $0.width.equalTo(widthButton * 2)
            $0.height.equalTo(40)
        })
    }
    
    func setupAmountButtons() {
        guard let user = User.currentUser else { return }
        for i in 0...1 {
            for y in 0...3 {
                let button = specify(Button(), {
                    let title = Constants.amountTitleArray[i * 4 + y]
                    $0.normalColor = Color.gray
                    $0.backgroundColor = Color.gray
                    $0.selectedColor = Color.green
                    $0.setTitle(title, for: UIControlState())
                    $0.titleLabel?.textColor = UIColor.white
                    $0.layer.cornerRadius = 5.0
                    $0.isSelected = user.preferedAmountTrade == title
                    $0.click { [weak self] sender in
                        _ = self?.containerButtons.map { $0.isSelected = sender === $0 }
                    }
                })
                addSubview(button)
                button.snp.makeConstraints {
                    $0.centerY.equalTo(self).offset((i - 1) * 60)
                    $0.leading.equalTo(self).offset((CGFloat(y) * widthButton) + (CGFloat(y + 1) * 10))
                    $0.width.equalTo(widthButton)
                    $0.height.equalTo(40)
                }
                containerButtons.append(button)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func dismiss() {
        sharedView.removeFromSuperview()
    }
    
    override func dismiss() {
        removeFromSuperview()
    }
    
    func show(inViewController viewController: UIViewController? = nil, appearence: Appearance = DefaultMessageAlertViewAppearance()) {
        
        weak var _viewController = viewController ?? UIViewController.actionSheetAppearanceViewController(self)
        
        guard let viewController = _viewController else { return }
        guard let view = viewController.view else { return }
        let referenceView = viewController.actionSheetAppearanceReferenceView(self)
        
        self.backgroundColor = appearence.backgroundColor
        self.messageLabel.textColor = appearence.textColor
        
        if self.superview != view {
            self.removeFromSuperview()
            view.addSubview(self)
            self.addConstraints(view, referenceView: referenceView)
            UIView.animate(withDuration: 2.0, animations: {
                self.bottomVeiwInset.update(offset: -200)
            })
            setupAmountButtons()
            self.layoutIfNeeded()
        }
    }
    
    fileprivate func addConstraints(_ view: UIView, referenceView: UIView) {
        snp.remakeConstraints {
            $0.width.centerX.equalTo(referenceView)
            bottomVeiwInset = $0.top.equalTo(referenceView.snp.bottom).constraint
            $0.height.equalTo(200)
        }
    }
}
