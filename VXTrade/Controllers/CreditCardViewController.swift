//
//  CreditCardViewController.swift
//  VXTrade
//
//  Created by Yuriy on 12/30/16.
//  Copyright © 2016 VXmarkets. All rights reserved.
//

import UIKit

class CreditCardViewController: BaseViewController {
    
    @IBOutlet var amountStreamView: StreamView?
    @IBOutlet var heightAmountStreamView: NSLayoutConstraint?
    var dataSource: StreamDataSource<[Amount]>?
    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let streamView = amountStreamView {
            streamView.showsVerticalScrollIndicator = false
            streamView.layout = StreamLayout()
            streamView.layer.cornerRadius = 5
            dataSource = StreamDataSource(streamView: streamView)
            let metrics = StreamMetrics<AmountCell>(size: streamView.height)
            
            metrics.selection = {[weak self] view in
                guard let weakSelf = self, let containerView = weakSelf.embededView?.view else { return }
                if !view.arrowLabel.isHidden {
                    view.arrowLabel.isHidden = true
                    containerView.add(weakSelf.blurView, {
                        $0.top.equalTo(streamView.snp.bottom)
                        $0.leading.trailing.bottom.equalTo(weakSelf.view)
                    })
                    self?.dataSource?.items = [Amount(price: "$250", description: "2 Risk Free Trades"),
                                               Amount(price: "$500", description: "5 Risk Free Trades"),
                                               Amount(price: "$1000", description: "$100 Bonus")]
                    UIView.animate(withDuration: 0.5, animations: {
                        weakSelf.heightAmountStreamView?.constant = streamView.contentSize.height
                    })
                    streamView.layoutIfNeeded()
                } else {
                    view.arrowLabel.isHidden = false
                    self?.dataSource?.items = [Amount(price: "$250", description: "2 Risk Free Trades")]
                    weakSelf.blurView.removeFromSuperview()
                    UIView.animate(withDuration: 0.5, animations: {
                        weakSelf.heightAmountStreamView?.constant = streamView.contentSize.height
                    })
                    streamView.layoutIfNeeded()
                }
            }
            dataSource?.addMetrics(metrics: metrics)
            dataSource?.items = [Amount(price: "$250", description: "2 Risk Free Trades")]
        }
    }

    @IBAction func addCardClick (sender: Button) {
        guard let view = embededView?.view, let controller = embededView?.controller else { return }
        let editViewController = Storyboard.EditCreditCard.instantiate()
        editViewController.embededViewController(to: view, parent: controller)
    }
    
    @IBAction func depositClick(sender: Button) {
//        SaveCardConfirmView().showInView(view, success: nil, cancel: nil)
        DepositConfirmView().showInView(view, success: nil, cancel: nil)
    }
    
    @IBAction func toggleSwitch(sender: UISwitch) {
        if !sender.isOn {
            AmountTradeView.sharedView.show()
        } else {
            AmountTradeView.sharedView.dismiss()
        }
    }
}
