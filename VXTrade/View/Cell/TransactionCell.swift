//
//  TransactionCell.swift
//  VXTrade
//
//  Created by Yuriy on 2/3/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import Foundation
import UIKit

class TransactionCell: EntryStreamReusableView<Transaction> {
    let requestedLabel = specify(UILabel(), {
        $0.textColor = Color.gray
        $0.font = UIFont.systemFont(ofSize: 13.0)
    })
    let cardLabel = specify(UILabel(), {
        $0.textColor = UIColor.white
    })
    let statusLabel = specify(UILabel(), {
        $0.textColor = Color.gray
        $0.font = UIFont.systemFont(ofSize: 13.0)
    })
    let amountLabel = specify(UILabel(), {
        $0.textColor = UIColor.white
    })
    
    override func setup(entry: Transaction) {
        requestedLabel.text = entry.requestedAt
        cardLabel.text = "XXXX - null"
        statusLabel.text = entry.transactionStatusCode
        amountLabel.text = "$ \(entry.amountRequested)"
    }
    
    override func layoutWithMetrics(metrics: StreamMetricsProtocol) {
        add(requestedLabel, {
            $0.leading.equalTo(self).offset(20)
            $0.bottom.equalTo(self.snp.centerY).offset(-2.5)
        })
        add(cardLabel, {
            $0.leading.equalTo(requestedLabel)
            $0.top.equalTo(self.snp.centerY).offset(2.5)
        })
        add(statusLabel, {
            $0.trailing.equalTo(self).offset(-20)
            $0.centerY.equalTo(requestedLabel)
        })
        add(amountLabel, {
            $0.trailing.equalTo(statusLabel)
            $0.centerY.equalTo(cardLabel)
        })
        add(specify(UIView(), {
            $0.backgroundColor = UIColor.lightGray
        }), {
            $0.height.equalTo(1)
            $0.leading.trailing.bottom.equalTo(self)
        })
    }
}

final class TransactionItemFooter: EntryStreamReusableView<String> {
    
    let headerLabel = specify(UILabel(), {
        $0.textColor = UIColor.white
        $0.font = UIFont.systemFont(ofSize: 11.0)
        $0.textAlignment = .center
        $0.numberOfLines = 2
    })
    let headerLabel2 = specify(UILabel(), {
        $0.textColor = UIColor.white
        $0.font = UIFont.systemFont(ofSize: 11.0)
        $0.textAlignment = .center
        $0.numberOfLines = 2
    })
    let ourLabel = specify(UILabel(), {
        $0.textColor = UIColor.white
        $0.font = UIFont.systemFont(ofSize: 11.0)
    })
    let customServiceButton = specify(Button(), {
        $0.setTitle("Custom Service", for: .normal)
        $0.setTitleColor(Color.green, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 11.0)
    })
    
    override func setEntry(entry: Any?) {
        headerLabel.text = "All deposit requests are subject to our Terms & Conditions."
        headerLabel2.text = "If you require assistance of further information please contact"
        ourLabel.text = "our"
    }
    
    override func layoutWithMetrics(metrics: StreamMetricsProtocol) {
        add(headerLabel, {
            $0.centerX.equalTo(self)
            $0.centerY.equalTo(self)
        })
        add(headerLabel2, {
            $0.top.equalTo(headerLabel.snp.bottom)
            $0.centerX.equalTo(self)
        })
        let view = UIView()
        add(view, {
            $0.top.equalTo(headerLabel2.snp.bottom).offset(-7.5)
            $0.centerX.equalTo(self)
        })
        view.add(ourLabel, {
            $0.leading.top.bottom.equalTo(view)
        })
        view.add(customServiceButton, {
            $0.trailing.top.bottom.equalTo(view)
            $0.leading.equalTo(ourLabel.snp.trailing).offset(5)
        })
    }
}
