//
//  SaveCardConfirmView.swift
//  VXTrade
//
//  Created by Yuriy on 1/13/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import Foundation
import UIKit

enum SaveResultType {
    case success, failure
}

class SaveCardConfirmView: ConfirmView {
    
    var cardNumberLabel = UILabel()
    var titleLabel = UILabel()
    var cardInfoView = UIView()
    var dotView: UIView?
    var cardLabel: Label?
    
    init (frame: CGRect = CGRect.zero, resultType: SaveResultType = .success, cardNumber: String = "4356") {
        self.dotView = UIView().createDotView(with: resultType == .success ? Color.green : Color.caral)
        self.cardNumberLabel.textColor = resultType == .success ? Color.green : Color.caral
        self.cardNumberLabel.text = cardNumber
        self.cardNumberLabel.font = UIFont.systemFont(ofSize: 24)
        self.cardLabel = Label(icon: resultType == .success ? "n" : "o" , size: 54, textColor: resultType == .success ? Color.green : Color.caral)
        super.init(frame: frame)
        titleView.backgroundColor = resultType == .success ? Color.green : Color.caral
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
            $0.text = "CREDIT CARD INFORMATION"
            $0.font = UIFont.boldSystemFont(ofSize: 15)
            $0.textColor = UIColor.white
        }), {
            $0.center.equalTo(titleView)
        })
        guard let dotView = dotView, let cardLabel = cardLabel else { return }
        
        contentView.add(cardLabel, {
            $0.top.equalTo(titleView.snp.bottom).offset(20)
            $0.centerX.equalTo(contentView)
        })
        contentView.add(cardInfoView)
        
        cardInfoView.add(dotView, {
            $0.centerY.leading.equalTo(cardInfoView)
        })
        cardInfoView.add(cardNumberLabel, {
            $0.top.trailing.bottom.equalTo(cardInfoView)
            $0.leading.equalTo(dotView.snp.trailing).offset(10)
        })
        cardInfoView.snp.makeConstraints({
            $0.top.equalTo(cardLabel.snp.bottom).offset(20)
            $0.centerX.equalTo(contentView)
        })
        let infoLabel = UILabel()
        contentView.add(specify(infoLabel, {
            $0.text = "Changed Has Been Saved"
            $0.font = UIFont.systemFont(ofSize: 13.0)
            $0.textColor = UIColor.lightGray
        }), {
            $0.centerX.equalTo(contentView)
            $0.top.equalTo(cardInfoView.snp.bottom).offset(20)
        })
        contentView.add(specify(UILabel(), {
            $0.text = "Successfully"
            $0.font = UIFont.boldSystemFont(ofSize: 13.0)
            $0.textColor = UIColor.lightGray
        }), {
            $0.centerX.equalTo(contentView)
            $0.top.equalTo(infoLabel.snp.bottom)
            $0.bottom.equalTo(contentView).inset(20)
        })
    }
}
