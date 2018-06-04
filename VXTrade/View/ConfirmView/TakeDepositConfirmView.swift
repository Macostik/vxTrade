//
//  TakeDepositConfirmView.swift
//  VXTrade
//
//  Created by Yuriy on 2/15/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import Foundation
import UIKit

class TakeDepositConfirmView: ConfirmView {
    
    var depositHandler: Block? = nil
    
    var titleLabel = UILabel()
    let imageLabel = Label(icon: "i", size: 46.0, textColor: Color.caral)
    let infoLabelTop = specify(UILabel(), {
        $0.textColor = UIColor.lightGray
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 13.0)
    })
    var amountLabel = specify(UILabel(), {
        $0.font = UIFont.boldSystemFont(ofSize: 36.0)
        $0.textColor = Color.caral
    })
    let infoLabelBottom = specify(UILabel(), {
        $0.textColor = UIColor.lightGray
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.font = UIFont.systemFont(ofSize: 13.0)
    })
    let depositButton = specify(UIButton(), {
        $0.setTitle("DEPOSIT", for: .normal)
        $0.setTitleColor(UIColor.white, for: .normal)
        $0.backgroundColor = Color.gray
        $0.layer.cornerRadius = 5.0
        $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
    })
    
    init (frame: CGRect = CGRect.zero, balance: String, depositHandler: Block? = nil) {
        titleLabel.text = "FUND YOUR ACCOUNT"
        infoLabelTop.text =  "Your Current Balance is"
        amountLabel.text = "$" + balance
        infoLabelBottom.text = "In Order to Trade\n Please Fund Your Account"
        self.depositHandler = depositHandler
        super.init(frame: frame)
        titleView.backgroundColor = Color.caral
        depositButton.addTarget(self, touchUpInside: #selector(self.depositHandle(sender:)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupSubViews() {
        titleView.add(xButton) { (make) in
            make.trailing.equalTo(titleView).inset(12)
            make.centerY.equalTo(titleView)
        }
        titleView.add(specify(titleLabel, {
            $0.font = UIFont.boldSystemFont(ofSize: 15)
            $0.textColor = UIColor.white
        }), {
            $0.center.equalTo(titleView)
        })
        contentView.add(imageLabel,{
            $0.centerX.equalTo(contentView)
            $0.top.equalTo(titleView.snp.bottom).offset(20)
        })
        
        contentView.add(infoLabelTop, {
            $0.centerX.equalTo(contentView)
            $0.top.equalTo(imageLabel.snp.bottom).offset(20)
        })
        
        contentView.add(amountLabel, {
            $0.centerX.equalTo(contentView)
            $0.top.equalTo(infoLabelTop.snp.bottom).offset(10)
        })
        
        contentView.add(infoLabelBottom, {
            $0.centerX.equalTo(contentView)
            $0.top.equalTo(amountLabel.snp.bottom).offset(20)
        })
        
        contentView.add(depositButton, {
            $0.centerX.equalTo(contentView)
            $0.height.equalTo(40)
            $0.width.equalTo(120)
            $0.top.equalTo(infoLabelBottom.snp.bottom).offset(20)
            $0.bottom.equalTo(contentView).inset(20)
        })
    }
    
    @IBAction func depositHandle(sender: Button) {
        depositHandler?()
        hide()
    }
}
