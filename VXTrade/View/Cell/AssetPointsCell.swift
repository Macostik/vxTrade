//
//  AssetPointsCell.swift
//  VXTrade
//
//  Created by Yura Granchenko on 3/7/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import Foundation
import UIKit

struct AssetPoint {
    let direction: String
    let value: String
    let time: String
}

class AssetPointCell: EntryStreamReusableView<AssetPoint> {
    
    let valueLabel = specify(UILabel(), {
        $0.textColor = UIColor.white
        $0.font = UIFont.boldSystemFont(ofSize: 13.0)
        $0.textAlignment = .center
        $0.adjustsFontSizeToFitWidth = true
    })
    let timeLabel = specify(UILabel(), {
        $0.textColor = UIColor.white
        $0.font = UIFont.systemFont(ofSize: 11.0)
        $0.textAlignment = .center
        $0.adjustsFontSizeToFitWidth = true
    })
    let backgroundView = UIView()
    
    override func setup(entry assetPoint: AssetPoint) {
        backgroundView.backgroundColor = assetPoint.direction == "call" ? Color.green : Color.caral
        valueLabel.text = assetPoint.value
        timeLabel.text = assetPoint.time
    }
    
    override func layoutWithMetrics(metrics: StreamMetricsProtocol) {
        super.layoutWithMetrics(metrics: metrics)
        
        add(backgroundView, {
            $0.leading.trailing.equalTo(self).inset(0.5)
            $0.top.equalTo(self)
           
        })
        
        add(valueLabel,  {
             $0.edges.equalTo(backgroundView)
        })
        
        add(timeLabel,  {
            $0.leading.bottom.trailing.equalTo(self)
            $0.top.equalTo(backgroundView.snp.bottom).offset(5)
        })
    }
}
