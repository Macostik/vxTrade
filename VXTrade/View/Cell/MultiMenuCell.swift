//
//  MultiMenuCell.swift
//  VXTrade
//
//  Created by Yuriy on 1/31/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import UIKit

enum TransactionOptions: String {
    case history, deposit, withdrawal
}

protocol MultiMenuCellDelegate: class {
    func cell(cell: MultiMenuCell, didToggle viewController: UIViewController?)
}

class MultiMenuCell: MenuCell {
   
    var entries = [TransactionOptions.history.rawValue, TransactionOptions.deposit.rawValue, TransactionOptions.withdrawal.rawValue]
    let arrowButton = Button(icon: "f", textColor: UIColor.white)
    
    private let streamView = StreamView()
    private var dataSource: StreamDataSource<[String]>!
    weak var delegate: MultiMenuCellDelegate?
    
    override func setup(entry: String) {
        super.setup(entry: entry)
        streamView.isScrollEnabled = false
        arrowButton.rotate = true
        arrowButton.touchArea = CGSize(width: Constants.screenWidth, height: height)
        arrowButton.addTarget(self, action: #selector(self.open(sender:)), for: .touchUpInside)
        dataSource = StreamDataSource(streamView: streamView)
        let historyVC = Storyboard.HistroryHeader.instantiate()
        let depostitVC = Storyboard.DepositHeader.instantiate()
        let withdrawalVC = Storyboard.WithdrawalHeader.instantiate()
        dataSource.addMetrics(metrics: StreamMetrics<SubMenuCell>().change(initializer: {  metrics in
            metrics.size = 35.0
            metrics.selection = { [weak self] view in
                guard let `self` = self else { return }
                var viewController = UIViewController()
                if view.entry == TransactionOptions.history.rawValue {
                    viewController = historyVC
                } else if view.entry == TransactionOptions.deposit.rawValue {
                    viewController = depostitVC
                } else {
                    viewController = withdrawalVC
                }
                self.delegate?.cell(cell: self, didToggle: viewController)
            }
        }))
        dataSource.items = entries
    }
    
    override func layoutWithMetrics(metrics: StreamMetricsProtocol) {
        super.layoutWithMetrics(metrics: metrics)
        add(arrowButton, {
            $0.trailing.equalTo(self).inset(20)
            $0.centerY.equalTo(nameLabel)
        })
        add(streamView) { (make) -> Void in
            make.leading.trailing.bottom.equalTo(self)
            make.top.equalTo(nameLabel.snp.bottom).offset(20)
        }
    }
    
    var opened: Bool = false {
        willSet {
            UIView.beginAnimations(nil, context: nil)
            arrowButton.contentMode = newValue == true ? .right : .top
            UIView.commitAnimations()
        }
    }
    
    @IBAction func open(sender: AnyObject) {
        delegate?.cell(cell: self, didToggle: nil)
    }
}
