//
//  PositionConfirmView.swift
//  VXTrade
//
//  Created by Yura Granchenko on 2/21/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import Foundation
import UIKit

var timeInterval = 3

class PositionConfirmView: ConfirmView {
    
    let titleLabel = UILabel()
    let expiryTime = specify(UILabel(), {
        $0.textColor = UIColor.gray
        $0.font = UIFont.systemFont(ofSize: 13.0)
    })
    let expiryTimeValue = specify(UILabel(), {
        $0.textColor = UIColor.darkGray
        $0.font = UIFont.boldSystemFont(ofSize: 15.0)
    })
    let asset = specify(UILabel(), {
        $0.textColor = UIColor.gray
        $0.font = UIFont.systemFont(ofSize: 13.0)
    })
    let assetValue = specify(UILabel(), {
        $0.textColor = UIColor.darkGray
        $0.font = UIFont.boldSystemFont(ofSize: 15.0)
    })
    let rate = specify(UILabel(), {
        $0.textColor = UIColor.gray
        $0.font = UIFont.systemFont(ofSize: 13.0)
    })
    let rateValue = specify(UILabel(), {
        $0.textColor = UIColor.darkGray
        $0.font = UIFont.boldSystemFont(ofSize: 15.0)
    })
    let rateArror = Label(icon: "G", size: 17.0, textColor: Color.green)
    let investment = specify(UILabel(), {
        $0.textColor = UIColor.gray
        $0.font = UIFont.systemFont(ofSize: 13.0)
    })
    let investmentValue = specify(UILabel(), {
        $0.textColor = UIColor.darkGray
        $0.font = UIFont.boldSystemFont(ofSize: 15.0)
    })
    let payout = specify(UILabel(), {
        $0.textColor = UIColor.gray
        $0.font = UIFont.systemFont(ofSize: 13.0)
    })
    let payoutValue = specify(UILabel(), {
        $0.textColor = UIColor.darkGray
        $0.font = UIFont.boldSystemFont(ofSize: 15.0)
    })
//    lazy var timer: Timer = {
//        return Timer(timeInterval: 3.0, target: self, selector: #selector(self.fireUp(sender:)), userInfo: nil, repeats: false)
//    }()
    
    let cancelButton = UIButton()
    let approveButton = UIButton()
    
    private var timer: Timer? = nil
    
    init (frame: CGRect = CGRect.zero, entry: Rule, investmentString: String, payoutString: String) {
        super.init(frame: frame)
        expiryTime.text = "Expirity Time"
        asset.text = "Asset"
        rate.text = "Rate"
        investment.text = "Investment"
        payout.text = "Payout"
        expiryTimeValue.text = entry.duration
        assetValue.text = entry.asset?.name
        rateValue.text = entry.ruleDuration.toString()
        investmentValue.text = "$" + investmentString
        payoutValue.text =  "$" + payoutString
        titleLabel.text = "0:0" + "\(timeInterval)"
        var _timeInterval = timeInterval
        
        if #available(iOS 10.0, *) {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true){ [weak self] timer in
                guard let `self` = self else { return }
                _timeInterval = _timeInterval - 1
                self.titleLabel.text = "0:0" + "\(_timeInterval)"
                if _timeInterval < 0 {
                    timer.invalidate()
                    self.approveBlock?()
                    self.hide()
                    PositionStateConfirmView().showInView(UINavigationController.main.view)
                }
            }
        }
       
        cancelButton.addTarget(self, touchUpInside: #selector(self.cancel(_:)))
        approveButton.addTarget(self, touchUpInside: #selector(self.approve(_:)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupSubViews() {
        
        titleView.add(specify(titleLabel, {
            $0.font = UIFont.boldSystemFont(ofSize: 15)
            $0.textColor = UIColor.white
        }), {
            $0.center.equalTo(titleView)
        })
        let expireView = UIView()
        contentView.add(expireView, {
            $0.top.equalTo(titleView.snp.bottom).offset(20)
        })
        expireView.add(expiryTime, {
            $0.leading.top.bottom.equalTo(expireView)
        })
        expireView.add(expiryTimeValue, {
            $0.leading.equalTo(expiryTime.snp.trailing).offset(10)
            $0.top.bottom.trailing.equalTo(expireView)
            $0.leading.equalTo(self.snp.centerX).offset(5)
        })
        let assetView = UIView()
        contentView.add(assetView, {
            $0.top.equalTo(expireView.snp.bottom).offset(10)
        })
        assetView.add(asset, {
            $0.leading.top.bottom.equalTo(assetView)
        })
        assetView.add(assetValue, {
            $0.leading.equalTo(asset.snp.trailing).offset(10)
            $0.top.bottom.trailing.equalTo(assetView)
            $0.leading.equalTo(self.snp.centerX).offset(5)
        })
        let rateView = UIView()
        contentView.add(rateView, {
            $0.top.equalTo(assetView.snp.bottom).offset(10)
        })
        rateView.add(rate, {
            $0.leading.top.bottom.equalTo(rateView)
        })
        rateView.add(rateArror, {
            $0.leading.equalTo(rate.snp.trailing).offset(10)
            $0.top.bottom.equalTo(rateView)
            $0.leading.equalTo(self.snp.centerX).offset(5)
        })
        rateView.add(rateValue, {
            $0.leading.equalTo(rateArror.snp.trailing).offset(5)
            $0.top.bottom.trailing.equalTo(rateView)
        })
        let investmentView = UIView()
        contentView.add(investmentView, {
            $0.top.equalTo(rateView.snp.bottom).offset(10)
        })
        investmentView.add(investment, {
            $0.leading.top.bottom.equalTo(investmentView)
        })
        investmentView.add(investmentValue, {
            $0.leading.equalTo(investment.snp.trailing).offset(10)
            $0.top.bottom.trailing.equalTo(investmentView)
            $0.leading.equalTo(self.snp.centerX).offset(5)
        })
        let payoutView = UIView()
        contentView.add(payoutView, {
            $0.top.equalTo(investmentView.snp.bottom).offset(10)
        })
        payoutView.add(payout, {
            $0.leading.top.bottom.equalTo(payoutView)
        })
        payoutView.add(payoutValue, {
            $0.leading.equalTo(payout.snp.trailing).offset(10)
            $0.top.bottom.trailing.equalTo(payoutView)
            $0.leading.equalTo(self.snp.centerX).offset(5)
        })
        let cancelView = specify(UIView(), {
            $0.backgroundColor = Color.caral
            $0.layer.cornerRadius = 5.0
        })
        contentView.add(cancelView, {
            $0.top.equalTo(payoutView.snp.bottom).offset(20)
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
    
    override func cancel(_ sender: AnyObject) {
        timer?.invalidate()
        timer = nil
        PositionStateConfirmView(resultType: .failure).showInView(UINavigationController.main.view)
        super.cancel(sender)
    }
}
