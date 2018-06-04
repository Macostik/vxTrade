//
//  RolloverConfirmView.swift
//  VXTrade
//
//  Created by Yuriy on 1/25/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import Foundation
import UIKit

class RolloverConfirmView: SellConfirmView {
    
    let changeLabel = specify(UILabel(), textColor: Color.darkGray , {
        $0.font = UIFont.boldSystemFont(ofSize: 13.0)
        $0.text = "Change expiry within"
    })
    var changeValueLabel = specify(UILabel(), textColor: Color.gray, {
        $0.text = "(minute)"
        $0.font = UIFont.italicSystemFont(ofSize: 11.0)
    })
    var chooseView = UIView()
    let chargeLabel = specify(UILabel(), textColor: Color.gray , {
        $0.text = "Your account will be charged:"
    })
    var chargeValueLabel = specify(UILabel(), textColor: Color.green)
    var newExpiryLabel = specify(UILabel(), textColor: Color.gray, {
        $0.text = "New expiry:"
    })
    var newExpiryValueLabel = specify(UILabel(), textColor: Color.gray)
    
    override init (frame: CGRect = CGRect.zero, entry: Position) {
        let (view, buttons) = UIView().createChooseView(with: Color.gray)
        self.chooseView = view
        let chooseButtons = buttons
        super.init(frame: frame, entry: entry)
        self.flagsView = UIView()
        self.flagsLabel.text = entry.assetName()
        let expireDate = Date.init(timeIntervalSince1970: TimeInterval.convertMillisecond(date: entry.expiryDate.toString())).stringWithFormat("dd.MM.YY hh:mm:ss")
        self.expireValueLabel.text = expireDate
        chargeValueLabel.text = "$ 0.000"
//        let newExirityDate = expireDate
//        newExpiryValueLabel.text = newExirityDate
        _ = chooseButtons.map { [weak self] button in
            button.click { [weak self] sender in
                let _ = chooseButtons.forEach { $0.isSelected = false }
                let _ = chooseButtons.map { $0.isSelected = sender === $0 }
                let _sender = chooseButtons.filter ({ $0 === sender }).first
                
                guard let label = _sender?.titleLabel, let value = label.text else { return }
                self?.chargeValueLabel.text = "$\((Float(entry.payout)) + (Float(value) ?? 0.0))"
                let newExirityDate = Date.init(timeIntervalSince1970: TimeInterval.convertMillisecond(date: entry.expiryDate.toString()) +
                                                        ((Double(value) ?? 0.0) * 60)).stringWithFormat("dd.MM.YY  hh:mm:ss")
                self?.newExpiryValueLabel.text = newExirityDate
            }
        }
        
        if let customerID = CustomToken.currentToken?.id {
            sellRateSocket.sendMessage(.sellRate(customerID: customerID.toString(), positionID: entry.id.toString()), messageHandler: { [weak self]  value, _ in
                self?.chargeValueLabel.text = "$ \(value)"
            })
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupSubViews() {
        titleView.add(cancelButton) { (make) in
            make.trailing.equalTo(titleView).inset(12)
            make.centerY.equalTo(titleView)
        }
        titleView.add(specify(titleLabel, {
            $0.text = "CHANGE EXPIRY"
            $0.font = UIFont.boldSystemFont(ofSize: 15)
            $0.textColor = UIColor.white
        }), {
            $0.center.equalTo(titleView)
        })
        contentView.add(flagsView, {
            $0.top.equalTo(titleView.snp.bottom).offset(20)
            $0.centerX.equalTo(contentView)
        })
        flagsView.add(firstFlagImageView, {
            $0.top.leading.bottom.equalTo(flagsView)
            $0.size.equalTo(30)
        })
        flagsView.add(secondFlagImageView, {
            $0.top.trailing.bottom.equalTo(flagsView)
            $0.leading.equalTo(firstFlagImageView.snp.trailing).offset(5)
            $0.size.equalTo(firstFlagImageView)
        })
        contentView.add(flagsLabel, {
            $0.centerX.equalTo(flagsView)
            $0.top.equalTo(flagsView.snp.bottom).offset(5)
        })
        let expireView = UIView()
        contentView.add(expireView, {
            $0.centerX.equalTo(contentView)
            $0.top.equalTo(flagsLabel.snp.bottom).offset(10)
        })
        expireView.add(expireLabel, {
            $0.top.leading.bottom.equalTo(expireView)
        })
        expireView.add(expireValueLabel, {
            $0.top.trailing.bottom.equalTo(expireView)
            $0.leading.equalTo(expireLabel.snp.trailing).offset(5)
        })
        let changeView = UIView()
        contentView.add(changeView, {
            $0.top.equalTo(expireView.snp.bottom).offset(30)
            $0.centerX.equalTo(contentView)
        })
        changeView.add(changeLabel, {
            $0.top.leading.bottom.equalTo(changeView)
        })
        changeView.add(changeValueLabel, {
            $0.top.trailing.bottom.equalTo(changeView)
            $0.leading.equalTo(changeLabel.snp.trailing).offset(5)
        })
    
        contentView.add(chooseView, {
            $0.centerX.equalTo(contentView).offset(-20)
            $0.top.equalTo(changeView.snp.bottom).offset(10)
        })
        let chargeView = UIView()
        contentView.add(chargeView, {
            $0.top.equalTo(chooseView.snp.bottom).offset(5)
            $0.centerX.equalTo(contentView)
        })
        chargeView.add(chargeLabel, {
            $0.top.leading.bottom.equalTo(chargeView)
        })
        chargeView.add(chargeValueLabel, {
            $0.top.trailing.bottom.equalTo(chargeView)
            $0.leading.equalTo(chargeLabel.snp.trailing).offset(5)
        })
        let newExpirityView = UIView()
        contentView.add(newExpirityView, {
            $0.top.equalTo(chargeView.snp.bottom)
            $0.centerX.equalTo(contentView)
        })
        newExpirityView.add(newExpiryLabel, {
            $0.top.leading.bottom.equalTo(newExpirityView)
        })
        newExpirityView.add(newExpiryValueLabel, {
            $0.top.trailing.bottom.equalTo(newExpirityView)
            $0.leading.equalTo(newExpiryLabel.snp.trailing).offset(5)
        })
        let cancelView = specify(UIView(), {
            $0.backgroundColor = Color.caral
            $0.layer.cornerRadius = 5.0
        })
        contentView.add(cancelView, {
            $0.top.equalTo(newExpirityView.snp.bottom).offset(20)
            $0.trailing.equalTo(contentView.snp.centerX).offset(-10)
            $0.bottom.equalTo(contentView).offset(-20)
        })
        let cancelXLabel = Label(icon: "y", size: 24)
        let cancelLabel = specify(UILabel(), {
            $0.text = "CANCEL"
            $0.textColor = UIColor.white
            $0.font = UIFont.boldSystemFont(ofSize: 17.0)
        })
        cancelView.add(cancelXLabel, {
            $0.top.bottom.equalTo(cancelView).inset(10)
        })
        cancelView.add(cancelLabel, {
            $0.top.bottom.equalTo(cancelView).inset(10)
            $0.leading.equalTo(cancelXLabel.snp.trailing).offset(5)
            $0.leading.equalTo(cancelView.snp.centerX).offset(-20)
        })
        cancelView.add(cancelButton, {
            $0.edges.equalTo(cancelView)
        })
        let approveView = specify(UIView(), {
            $0.backgroundColor = Color.green
            $0.layer.cornerRadius = 5.0
        })
        contentView.add(approveView, {
            $0.top.equalTo(cancelView)
            $0.leading.equalTo(contentView.snp.centerX).offset(10)
            $0.width.equalTo(cancelView)
        })
        let approveYLabel = Label(icon: "x", size: 24)
        let approveLabel = specify(UILabel(), {
            $0.text = "APPROVE"
            $0.textColor = UIColor.white
            $0.font = UIFont.boldSystemFont(ofSize: 17.0)
        })
        approveView.add(approveYLabel, {
            $0.leading.top.bottom.equalTo(approveView).inset(10)
        })
        approveView.add(approveLabel, {
            $0.top.bottom.equalTo(approveView).inset(5)
            $0.trailing.equalTo(approveView).inset(10)
            $0.leading.equalTo(approveYLabel.snp.trailing).offset(5)
        })
        approveView.add(approveButton, {
            $0.edges.equalTo(approveView)
        })
    }
}

extension UIView {
    func createChooseView(with color: UIColor) -> (UIView, [Button]) {
        let chooseView = UIView()
        add(chooseView)
        var buttons = [Button]()
//        for i  in 1...4 {
            let button = specify(Button(), {
                $0.setTitle("15", for: .normal)
                $0.titleLabel?.font = UIFont.systemFont(ofSize: 15)
                $0.layer.cornerRadius = 5.0
                $0.backgroundColor = color
                $0.selectedColor = Color.darkGray
            })
            buttons.append(button)
//        }
        
        chooseView.add(buttons[0], {
            $0.leading.top.bottom.equalTo(chooseView)
            $0.size.equalTo(40)
        })
//        chooseView.add(buttons[1], {
//            $0.leading.equalTo(buttons[0].snp.trailing).offset(30)
//            $0.centerY.equalTo(buttons[0])
//            $0.size.equalTo(buttons[0])
//        })
//        chooseView.add(buttons[2], {
//            $0.leading.equalTo(buttons[1].snp.trailing).offset(30)
//            $0.centerY.equalTo(buttons[1])
//            $0.size.equalTo(buttons[1])
//        })
//        chooseView.add(buttons[3], {
//            $0.leading.equalTo(buttons[2].snp.trailing).offset(30)
//            $0.centerY.equalTo(buttons[2])
//            $0.size.equalTo(buttons[2])
//            $0.trailing.equalTo(chooseView)
//        })
        
        return (chooseView, buttons)
    }
}
