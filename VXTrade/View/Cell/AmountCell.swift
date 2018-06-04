//
//  AmountCell.swift
//  VXTrade
//
//  Created by Yuriy on 2/1/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import Foundation
import UIKit

struct Amount {
    let price: String
    let description: String
}

class AmountCell: EntryStreamReusableView<Amount> {
    
    let amountLabel = UILabel()
    let desriptionLabel = UILabel()
    let arrowLabel = Label(icon: "f", size: 15.0, textColor: UIColor.black)
    
    override func setup(entry amount: Amount) {
        amountLabel.text = amount.price
        desriptionLabel.text = amount.description
        desriptionLabel.textColor = Color.green
        backgroundColor = UIColor.white
        if item?.position.index != 0 {
            arrowLabel.removeFromSuperview()
        }
    }
    
    override func layoutWithMetrics(metrics: StreamMetricsProtocol) {
        super.layoutWithMetrics(metrics: metrics)
        
        add(amountLabel,  { (make) in
            make.centerY.equalTo(self)
            make.leading.equalTo(self).offset(12)
        })
        add(arrowLabel,  { (make) in
            make.trailing.equalTo(self).offset(-12)
            make.centerY.equalTo(self)
        })
        add(desriptionLabel,  { (make) in
            make.centerY.equalTo(self)
            make.trailing.equalTo(self).offset(-30)
        })
    }
}
