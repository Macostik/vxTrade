//
//  CurrencyCell.swift
//  VXTrade
//
//  Created by Yura Granchenko on 2/20/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import Foundation
import UIKit

final class CurrencyItemHeader: EntryStreamReusableView<CurrencyWrapper> {
    
    var title: String? = nil {
        willSet {
            if newValue == "currency" {
                headerImage.text = "D"
            } else if newValue == "commodity" {
                headerImage.text = "E"
            }
     
            headerLabel.text = (newValue ?? "").uppercased()
            backgroundColor = Color.caral
        }
    }
    var headerImage = specify(Label(icon: "", size: 24.0, textColor: UIColor.white), {
        $0.textColor = UIColor.white
    })
    let headerLabel = specify(UILabel(), {
        $0.textColor = UIColor.white
    })
    
    override func setup(entry: CurrencyWrapper) {}
    
    override func layoutWithMetrics(metrics: StreamMetricsProtocol) {
        add(headerImage, {
            $0.leading.equalTo(self).offset(20)
            $0.centerY.equalTo(self)
        })
        add(headerLabel, {
            $0.leading.equalTo(headerImage.snp.trailing).offset(10)
            $0.centerY.equalTo(self)
        })
    }
}

class CurrencyCell<T: Asset>: EntryStreamReusableView<Asset> {
    
    let containerView = UIView()
    let firstImage = UIImageView()
    let secondImage = UIImageView()
    let nameLabel = specify(UILabel(), {
        $0.textColor = UIColor.white
    })
    let valueLabel = specify(UILabel(), {
        $0.textColor = Color.green
        $0.font = UIFont.systemFont(ofSize: 19.0)
    })
    
    var positionValue: String = "" {
        willSet {
            valueLabel.textColor = (valueLabel.text ?? "") >= newValue ? Color.caral : Color.green
            valueLabel.text = newValue
        }
    }
    private let socket = SocketManager()
    
    override func setup(entry: Asset) {
        let name = entry.name
        if name.contains("/") {
            let firstImageName = name.substring(to: name.index(name.startIndex, offsetBy: 3))
            let secondImageName = name.substring(from: name.index(name.endIndex, offsetBy: -3))
            firstImage.image = UIImage(named: firstImageName)
            secondImage.image = UIImage(named: secondImageName)
           
        } else {
            firstImage.image = UIImage(named: name) ?? UIImage(named: "EUR")
            secondImage.image = UIImage(named: "") ??  UIImage(named: "USD")
        }
        nameLabel.text = entry.name
        socket.sendMessage(.chartSubscribe(assetID: entry.id.toString()) , messageHandler: {[weak self] close, time in
            guard let `self` = self else { return }
            self.positionValue = close
        })
    }
    
    override func layoutWithMetrics(metrics: StreamMetricsProtocol) {
        super.layoutWithMetrics(metrics: metrics)
        
        add(containerView, {
            $0.edges.equalTo(self)
        })
        containerView.add(firstImage, {
            $0.leading.equalTo(containerView).offset(20)
            $0.centerY.equalTo(containerView)
            $0.size.equalTo(30)
        })
        containerView.add(secondImage, {
            $0.leading.equalTo(firstImage.snp.trailing).offset(5)
            $0.centerY.equalTo(containerView)
            $0.size.equalTo(30)
        })
        containerView.add(nameLabel, {
            $0.leading.equalTo(secondImage.snp.trailing).offset(10)
            $0.centerY.equalTo(containerView)
        })
        containerView.add(valueLabel, {
            $0.trailing.equalTo(containerView).inset(20)
            $0.centerY.equalTo(containerView)
        })
        add(specify(UIView(), {
            $0.backgroundColor = Color.gray
        }), {
            $0.height.equalTo(1)
            $0.leading.trailing.bottom.equalTo(containerView)
        })
    }
}

