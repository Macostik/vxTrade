//
//  SellConfirmView.swift
//  VXTrade
//
//  Created by Yuriy on 1/24/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import Foundation
import UIKit

class SellConfirmView: ConfirmView {
    var titleLabel = UILabel()
    var flagsView = UIView()
    let cancelButton = UIButton()
    let approveButton = UIButton()
    var flagsLabel = specify(UILabel(), {
        $0.textColor = Color.darkGray
        $0.font = UIFont.systemFont(ofSize: 13)
    })
    var firstFlagImageView = specify(UIImageView(), {
        $0.image = UIImage(named: "EUR")
    })
    var secondFlagImageView = specify(UIImageView(), {
        $0.image = UIImage(named: "USD")
    })
    var expireLabel = specify(UILabel(), {
        $0.textColor = Color.gray
        $0.text = "Expirity Time"
        $0.font = UIFont.systemFont(ofSize: 13)
    })
    var expireValueLabel = specify(UILabel(), {
        $0.textColor = Color.darkGray
        $0.font = UIFont.boldSystemFont(ofSize: 13)
    })
    private var investLabel = specify(UILabel(), {
        $0.textColor = Color.gray
        $0.text = "Invest"
        $0.font = UIFont.systemFont(ofSize: 13)
    })
    private var investValueLabel = specify(UILabel(), {
        $0.textColor = Color.darkGray
        $0.font = UIFont.boldSystemFont(ofSize: 13)
    })
    private var currentLabel = specify(UILabel(), {
        $0.textColor = Color.gray
        $0.text = "Current Lose"
        $0.font = UIFont.systemFont(ofSize: 13)
    })
    private var currentValueLabel = specify(UILabel(), {
        $0.textColor = Color.caral
        $0.font = UIFont.boldSystemFont(ofSize: 13)
        
    })
    private var outOfferLabel = specify(UILabel(), {
        $0.textColor = Color.gray
        $0.text = "Out Offer"
        $0.font = UIFont.systemFont(ofSize: 13)
    })
    private var outOfferValueLabel = specify(UILabel(), {
        $0.textColor = Color.darkGray
        $0.font = UIFont.boldSystemFont(ofSize: 13)
    })
    
    let sellRateSocket = SocketManager()
    
    init (frame: CGRect = CGRect.zero, entry: Position) {
        self.flagsView = UIView()
        self.flagsLabel.text = entry.assetName()
        let expireDate = Date().stringWithFormat("dd.MM.YY hh:mm:ss")
        self.expireValueLabel.text = expireDate
        self.investValueLabel.text = "$" + entry.investment.toString()
        super.init(frame: frame)
        cancelButton.addTarget(self, touchUpInside: #selector(self.cancel(_:)))
        approveButton.addTarget(self, touchUpInside: #selector(self.approve(_:)))
        let invest = entry.investment
        
        if let customerID = CustomToken.currentToken?.id {
            sellRateSocket.sendMessage(.sellRate(customerID: customerID.toString(), positionID: entry.id.toString()), messageHandler: { [weak self]  value, _ in
                self?.currentValueLabel.textColor = invest > value.toDouble() ? Color.caral : Color.green
                let doubleValue = value.toDouble()
                let diffCur = abs(invest - doubleValue)
                let diffOut = invest > doubleValue ? invest - diffCur : invest + diffCur
                self?.currentValueLabel.text =  "$" + diffCur.toString()
                self?.outOfferValueLabel.text = "$" + diffOut.toString()
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
            $0.text = "BUY ME OUT"
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
            $0.top.equalTo(flagsLabel.snp.bottom).offset(10)
        })
        expireView.add(expireLabel, {
            $0.trailing.equalTo(contentView.snp.centerX).offset(-2.5)
            $0.top.leading.bottom.equalTo(expireView)
        })
        expireView.add(expireValueLabel, {
            $0.top.trailing.bottom.equalTo(expireView)
            $0.leading.equalTo(expireLabel.snp.trailing).offset(5)
        })
        let investView = UIView()
        contentView.add(investView, {
            $0.top.equalTo(expireView.snp.bottom).offset(15)
        })
        investView.add(investLabel, {
            $0.trailing.equalTo(contentView.snp.centerX).offset(-2.5)
            $0.top.leading.bottom.equalTo(investView)
        })
        investView.add(investValueLabel, {
            $0.top.trailing.bottom.equalTo(investView)
            $0.leading.equalTo(investLabel.snp.trailing).offset(5)
        })
        let currentLoseView = UIView()
        contentView.add(currentLoseView, {
            $0.top.equalTo(investView.snp.bottom).offset(5)
        })
        currentLoseView.add(currentLabel, {
            $0.trailing.equalTo(contentView.snp.centerX).offset(-2.5)
            $0.top.leading.bottom.equalTo(currentLoseView)
        })
        currentLoseView.add(currentValueLabel, {
            $0.top.trailing.bottom.equalTo(currentLoseView)
            $0.leading.equalTo(investLabel.snp.trailing).offset(5)
        })
        let outOfferView = UIView()
        contentView.add(outOfferView, {
            $0.top.equalTo(currentLoseView.snp.bottom).offset(5)
        })
        outOfferView.add(outOfferLabel, {
            $0.trailing.equalTo(contentView.snp.centerX).offset(-2.5)
            $0.top.leading.bottom.equalTo(outOfferView)
        })
        outOfferView.add(outOfferValueLabel, {
            $0.top.trailing.bottom.equalTo(outOfferView)
            $0.leading.equalTo(investLabel.snp.trailing).offset(5)
        })
        let cancelView = specify(UIView(), {
            $0.backgroundColor = Color.caral
            $0.layer.cornerRadius = 5.0
        })
        contentView.add(cancelView, {
            $0.top.equalTo(outOfferView.snp.bottom).offset(20)
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
