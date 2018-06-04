//
//  HistoryListViewController.swift
//  VXTrade
//
//  Created by Yuriy on 2/3/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import UIKit

class HistoryListViewController: BaseViewController {
    
    @IBOutlet var streamView: StreamView!
    var dataSource: StreamDataSource<[Transaction]>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = StreamDataSource(streamView: streamView)
        let metrics = StreamMetrics<TransactionCell>(size: 70.0)
        let footerMetrics = StreamMetrics<TransactionItemFooter>(size: 100.0)
        dataSource?.addMetrics(metrics: metrics)
        dataSource?.addSectionFooterMetrics(metrics: footerMetrics)
    }
}

class WithdrawalListViewController: HistoryListViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

class DepositListViewController: HistoryListViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let token = ProftitToken().proftitToken()?.token  else { return }
        let depositEntryParam = DepositEntryParam(entryParameters: (baseURL: (MainURL.proftit.description, nil),
                                                                    headerParameters: ["Authorization" : "Bearer \(token)"],
                                                                    bodyParameters: nil))
        UserRequest.getDepositList(depositEntryParam, completion: { [weak self] json, success in
            guard let json = json, success == true else { return }
            let depositList: [Deposit] = Deposit.setupList(json: json)
            if (depositList.count > 0) { self?.dataSource?.items = depositList }
        })
    }
}

