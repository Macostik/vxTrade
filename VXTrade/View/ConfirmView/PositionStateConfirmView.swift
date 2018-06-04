//
//  PositionStateConfirmView.swift
//  VXTrade
//
//  Created by Yura Granchenko on 2/21/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import Foundation
import UIKit

class PositionStateConfirmView: ConfirmView {
    
    var titleLabel = UILabel()
    let signLabel = Label(icon: "", size: 156.0)
    let infoLabel = specify(UILabel(), {
        $0.font = UIFont.boldSystemFont(ofSize: 15.0)
        $0.textColor = UIColor.darkGray
    })

    init (frame: CGRect = CGRect.zero, resultType: SaveResultType = .success) {
        super.init(frame: frame)
        titleLabel.text = "0:00"
        signLabel.textColor = resultType == .success ? Color.green : Color.caral
        signLabel.text = resultType == .success ? "x" : "y"
        infoLabel.text = resultType == .success ? "Position Approved" : "Position Falied"
        titleView.backgroundColor = resultType == .success ? Color.green : Color.caral
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
        contentView.add(signLabel, {
            $0.top.equalTo(titleView.snp.bottom).offset(20)
            $0.centerX.equalTo(contentView)
        })
        contentView.add(infoLabel, {
            $0.top.equalTo(signLabel.snp.bottom)
            $0.centerX.equalTo(contentView)
            $0.bottom.equalTo(contentView).inset(20)
        })
    }
}
