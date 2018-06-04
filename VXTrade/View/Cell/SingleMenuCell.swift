//
//  SingleMenuCell.swift
//  VXTrade
//
//  Created by Yuriy on 1/31/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import UIKit

class MenuCell: EntryStreamReusableView<String> {
    let nameLabel = specify(UILabel(), {
        $0.textColor = UIColor.white
    })
    
    override func setup(entry: String) {
        nameLabel.text = entry.uppercased()
    }
    
    override func layoutWithMetrics(metrics: StreamMetricsProtocol) {
        add(nameLabel, {
            $0.leading.equalTo(self).offset(20)
            $0.top.equalTo(self).offset(25)
        })
        add(specify(UIView(), {
            $0.backgroundColor = UIColor.lightGray
        }), {
            $0.height.equalTo(1)
            $0.leading.trailing.bottom.equalTo(self)
        })
    }
}


class SingleMenuCell: MenuCell {}
