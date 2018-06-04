//
//  PositionsViewController.swift
//  VXTrade
//
//  Created by Yuriy on 1/3/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import UIKit

class PositionsOpenViewController: PositionsViewController {
    
    @IBOutlet var sellValueLabel: UILabel?
    var calendar: UIView? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        sellValueLabel?.text = ""
        
        Position.notifier.subscribe(self , block: { [weak self] _, _ in
            Dispatch.mainQueue.after(1.0, block: {
                self?.getPositions()
            })
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getPositions()
        calendar?.isHidden = true
    }
    
    func getPositions() {
        spinner.stopAnimating()
        let regularPositions: [TemporaryRegularPosition] = TemporaryRegularPosition().entries().sorted { $0.expiryDate > $1.expiryDate }
        let trendPositions: [TemporaryTrendPosition] = TemporaryTrendPosition().entries().sorted { $0.expiryDate > $1.expiryDate }
            dataSource?.items = [PositionWrapper(title: "regular", positions: regularPositions),
                                 PositionWrapper(title: "trend", positions: trendPositions)]
        let regularAmount = regularPositions.flatMap { Float($0.payoutValue()) }.reduce(0, +)
        let trandAmount =  trendPositions.flatMap { Float($0.payoutValue()) }.reduce(0, +)
        sellValueLabel?.text = "$" + 3 << "\(regularAmount + trandAmount)"
        streamView?.reload()
    }
}

extension PositionsOpenViewController: PositionCellDelegate {
    func positionCellDidBeginPanning(cell: Any) {
        streamView?.isUserInteractionEnabled = false
        streamView?.lock()
    }
    
    func positionCellDidEndPanning(cell: Any, performedAction:Bool) {
        streamView?.unlock()
        streamView?.isUserInteractionEnabled = true
    }
}
