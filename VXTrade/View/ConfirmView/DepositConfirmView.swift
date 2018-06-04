//
//  DepositConfirmView.swift
//  VXTrade
//
//  Created by Yuriy on 1/30/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import UIKit

class DepositConfirmView: ConfirmView {

    var titleLabel = UILabel()
    var amountLabel = specify(UILabel(), {
        $0.font = UIFont.boldSystemFont(ofSize: 36.0)
        $0.textColor = Color.green
    })
    let imageLabel = Label(icon: "i", size: 46.0, textColor: Color.green )
    let infoLabel = specify(UILabel(), textColor: UIColor.lightGray)
    let infoLabelValue = UILabel()
    let descriptionLabel = specify(UILabel(), textColor: UIColor.lightGray, {
        $0.numberOfLines = 4
        $0.textAlignment = .center
    })
    
    init (frame: CGRect = CGRect.zero, resultType: SaveResultType = .failure, amount: String = "$250") {
        self.amountLabel.text =  resultType == .success ? amount : ""
        imageLabel.textColor = resultType == .success ? Color.green : Color.caral
        titleLabel.text =  resultType == .success ? "DEPOSIT SUCCESS!" : "DEPOSIT FAILED!"
        infoLabel.text = resultType == .success ? "Additional" : "Your deposit has failed,"
        infoLabel.font = resultType == .success ? UIFont.systemFont(ofSize: 13.0) : UIFont.boldSystemFont(ofSize: 13.0)
        infoLabel.textColor = resultType == .success ? UIColor.lightGray : Color.darkGray
        infoLabelValue.font = resultType == .success ? UIFont.boldSystemFont(ofSize: 13.0) : UIFont.systemFont(ofSize: 13.0)
        infoLabelValue.textColor = resultType == .success ? Color.darkGray : UIColor.lightGray
        infoLabelValue.text = resultType == .success ? "2 Risk Free Trade Bonus" : "we encourage you"
        descriptionLabel.text = resultType == .success ? "Have been added to Your Account" : "to re-enter your bank information to make sure there wasn't typo. You may also with to contact your bank to confirm the exact details that you need to submit and try again."
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
            $0.font = UIFont.boldSystemFont(ofSize: 15)
            $0.textColor = UIColor.white
        }), {
            $0.center.equalTo(titleView)
        })
        contentView.add(imageLabel,{
            $0.centerX.equalTo(contentView)
            $0.top.equalTo(titleView.snp.bottom).offset(20)
        })
        
        contentView.add(amountLabel, {
            $0.centerX.equalTo(contentView)
            $0.top.equalTo(imageLabel.snp.bottom).offset(10)
        })
        
        let infoView = UIView()
        contentView.add(infoView, {
            $0.leading.trailing.equalTo(contentView).inset(Constants.screenWidth > 320 ? 20 : 5)
            $0.top.equalTo(amountLabel.snp.bottom).offset(10)
            $0.bottom.equalTo(contentView).inset(20)
        })
        let view = UIView()
        infoView.add(view, {
            $0.top.centerX.equalTo(infoView)
        })
        view.add(infoLabel, {
            $0.leading.top.bottom.equalTo(view)
        })
        view.add(infoLabelValue, {
            $0.trailing.top.bottom.equalTo(view)
            $0.leading.equalTo(infoLabel.snp.trailing).offset(5)
        })
        infoView.add(descriptionLabel, {
            $0.leading.trailing.bottom.equalTo(infoView)
            $0.top.equalTo(view.snp.bottom)
        })
    }
}



