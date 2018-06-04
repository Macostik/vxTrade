//
//  PlaceholderView.swift
//  VXTrade
//
//  Created by Macostik on 1/9/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import Foundation
import UIKit


class PlaceholderView: UIView {
    
    static func placeholderView(iconName: String, message: String, color: UIColor = Color.gray) -> (() -> PlaceholderView) {
        return {
            let view = PlaceholderView()
            view.isUserInteractionEnabled = false
            view.addSubview(view.textLabel)
            view.addSubview(view.iconLabel)
            view.iconLabel.snp.makeConstraints { (make) -> Void in
                make.top.centerX.equalTo(view)
                make.bottom.equalTo(view.textLabel.snp.top).inset(-12)
            }
            view.textLabel.snp.makeConstraints { (make) -> Void in
                make.leading.trailing.bottom.equalTo(view)
            }
            view.textLabel.textColor = color
            view.iconLabel.textColor = color
            view.textLabel.text = message
            view.iconLabel.text = iconName
            return view
        }
    }
    
    let textLabel = specify(Label()) {
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    let iconLabel = Label(icon: "", size: 96, textColor: Color.gray)
    
    func layoutInStreamView(streamView: StreamView) {
        streamView.add(self, { (make) in
            make.centerX.equalTo(streamView)
            make.centerY.equalTo(streamView).offset(streamView.layout.offset/2 - streamView.contentInset.top/2)
            make.size.lessThanOrEqualTo(streamView).offset(-24)
        })
    }
}

