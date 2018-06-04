//
//  RiskConfirmView.swift
//  VXTrade
//
//  Created by Yuriy on 1/26/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import Foundation
import UIKit

class RiskConfirmView: SellConfirmView {
    
    let infoFirstLabel = specify(UILabel(), textColor: Color.gray , {
        $0.text = "Risk free guarantees you won't lose,"
    })
    var infoSecondLabel = specify(UILabel(), textColor: Color.gray, {
        $0.text = "eigher you win or get your money back."
    })
    var chooseView = UIView()
    let maxPayoutLabel = specify(UILabel(), textColor: Color.gray , {
        $0.text = "Max Payout:"
    })
    var maxPayoutValueLabel = specify(UILabel(), textColor: Color.green)
    var amountLabel = specify(UILabel(), textColor: Color.gray, {
        $0.text = "Guaranteed Amount:"
    })
    var amountValueLabel = specify(UILabel(), textColor: Color.gray)
    
    override init (frame: CGRect = CGRect.zero, entry: Position) {
        super.init(frame: frame, entry: entry)
        self.flagsView = UIView()
        self.flagsLabel.text = entry.assetName()
        let expireDate = Date.init(timeIntervalSince1970: TimeInterval.convertMillisecond(date: entry.expiryDate.toString())).stringWithFormat("dd.MM.YY hh:mm:ss")
        maxPayoutValueLabel.text = "$" + entry.id.toString()
        self.expireValueLabel.text = expireDate
        amountValueLabel.text = "$" + entry.baseCurrencyInvestment.toString()
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
            $0.text = "RISK FREE"
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
        let infoView = UIView()
        contentView.add(infoView, {
            $0.top.equalTo(expireView.snp.bottom)
            $0.centerX.equalTo(contentView)
        })
        infoView.add(infoFirstLabel, {
            $0.top.centerX.equalTo(infoView)
        })
        infoView.add(infoSecondLabel, {
            $0.centerX.bottom.equalTo(infoView)
            $0.top.equalTo(infoFirstLabel.snp.bottom)
        })
        contentView.add(chooseView, {
            $0.centerX.equalTo(contentView)
            $0.top.equalTo(infoView.snp.bottom).offset(10)
        })
        let chargeView = UIView()
        contentView.add(chargeView, {
            $0.top.equalTo(chooseView.snp.bottom).offset(5)
            $0.centerX.equalTo(contentView)
        })
        chargeView.add(maxPayoutLabel, {
            $0.top.leading.bottom.equalTo(chargeView)
        })
        chargeView.add(maxPayoutValueLabel, {
            $0.top.trailing.bottom.equalTo(chargeView)
            $0.leading.equalTo(maxPayoutLabel.snp.trailing).offset(5)
        })
        let newExpirityView = UIView()
        contentView.add(newExpirityView, {
            $0.top.equalTo(chargeView.snp.bottom)
            $0.centerX.equalTo(contentView)
        })
        newExpirityView.add(amountLabel, {
            $0.top.leading.bottom.equalTo(newExpirityView)
        })
        newExpirityView.add(amountValueLabel, {
            $0.top.trailing.bottom.equalTo(newExpirityView)
            $0.leading.equalTo(amountLabel.snp.trailing).offset(5)
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
