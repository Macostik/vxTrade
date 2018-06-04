//
//  SubMenuCell.swift
//  VXTrade
//
//  Created by Yuriy on 1/31/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import UIKit

class SubMenuCell: EntryStreamReusableView<String> {
    
    let nameLabel = specify(UILabel(), {
        $0.font = UIFont.systemFont(ofSize: 14.0)
        $0.textColor = UIColor.white
    })
    
    override func setup(entry: String) {
        nameLabel.text = entry.uppercased()
    }
    
    override func layoutWithMetrics(metrics: StreamMetricsProtocol) {
        add(nameLabel, {
            $0.leading.equalTo(self).offset(20)
            $0.centerY.equalTo(self)
        })
        
    }
}
