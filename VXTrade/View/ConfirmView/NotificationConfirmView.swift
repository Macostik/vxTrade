//
//  NotificationConfirmView.swift
//  VXTrade
//
//  Created by Yuriy on 2/9/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import Foundation
import UIKit

class NotificationConfirmView: ConfirmView {
    
    var titleLabel = specify(UILabel(), {
        $0.textColor = UIColor.white
    })
    let imageLabel = Label(icon: "A", size: 46.0, textColor: Color.caral)
    let infoLabelTop = specify(UILabel(), {
        $0.textColor = UIColor.lightGray
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 13.0)
    })
    let infoLabelBottom = specify(UILabel(), {
        $0.textColor = UIColor.lightGray
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 13.0)
    })
    let allowButton = specify(UIButton(), {
        $0.setTitle("Allow Notification", for: .normal)
        $0.setTitleColor(Color.caral, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
    })
    
    override init (frame: CGRect = CGRect.zero) {
        titleLabel.text = "NOTIFICATION"
        infoLabelTop.text =  "Notification may include alerts sounds and icon budges."
        infoLabelBottom.text = "These must be allow for Trading."
        super.init(frame: frame)
        titleView.backgroundColor = Color.gray
        allowButton.addTarget(self, touchUpInside: #selector(self.approve(_:)))
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
            $0.top.equalTo(imageLabel.snp.bottom).offset(20)
            $0.centerX.equalTo(contentView)
            $0.width.equalTo(200)
        })
        contentView.add(infoLabelBottom, {
            $0.top.equalTo(infoLabelTop.snp.bottom)
            $0.centerX.equalTo(contentView)
            $0.width.equalTo(infoLabelTop)
        })
        let separatorView = UIView()
        contentView.add(specify(separatorView, {
          $0.backgroundColor = UIColor.lightGray
        }), {
            $0.height.equalTo(1)
            $0.leading.trailing.equalTo(contentView)
            $0.top.equalTo(infoLabelBottom.snp.bottom).offset(20)
        })
        contentView.add(allowButton, {
            $0.leading.trailing.equalTo(contentView)
            $0.top.equalTo(separatorView.snp.bottom)
            $0.bottom.equalTo(contentView).offset(-5)
        })
    }
}
