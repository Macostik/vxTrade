//
//  PositionsExpireViewController.swift
//  VXTrade
//
//  Created by Yuriy on 1/19/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import Foundation
import UIKit

class PositionsViewController: BaseViewController {
    
    @IBOutlet var streamView: StreamView?
    @IBOutlet var pickerView: UIView!
    @IBOutlet var datePrioritazer: LayoutPrioritizer!
    
    var dataSource: PositionDataSource?
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
    var dateShow = false {
        willSet {
            whenLoaded { [weak self] in
                self?.datePrioritazer.setDefaultState(state: newValue, animated: true)
            }
        }
    }
    
    override func loadView() {
        super.loadView()
        guard let streamView = streamView else { return }
        spinner.hidesWhenStopped = true
        streamView.add(spinner) { (make) in
            make.center.equalTo(streamView)
        }
        spinner.startAnimating()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let streamView = streamView else { return }
        streamView.showsVerticalScrollIndicator = false
        streamView.layout = StreamLayout()
        dataSource = PositionDataSource(streamView: streamView)
        pickerView.add(specify(UIDatePicker(), {
            $0.datePickerMode = .date
            $0.setValue(UIColor.white, forKeyPath: "textColor")
            $0.addTarget(self, action: #selector(PositionsOpenViewController.chooseDate(sender:)), for: .valueChanged)
        }), {
            $0.edges.equalTo(pickerView)
        })
    }
    
    func chooseDate(sender: UIDatePicker) {
        let positions: [ExpirePosition] = ExpirePosition().entries()
        let startOfDay = sender.date.startOfDay.stringWithFormat("dd MMM")
        let regularPositons = positions.filter { $0.discriminator == "regular" &&
            Date.init(timeIntervalSince1970:TimeInterval.convertMillisecond(date: $0.expiryDate.toString())).stringWithFormat("dd MMM") == startOfDay }
        let trendPositions = positions.filter { $0.discriminator == "trend" &&
            Date.init(timeIntervalSince1970:TimeInterval.convertMillisecond(date: $0.expiryDate.toString())).stringWithFormat("dd MMM") == startOfDay }
        if (positions.count > 0) {
            dataSource?.items = [PositionWrapper(title: "regular", positions: regularPositons),
                                 PositionWrapper(title: "trend", positions: trendPositions)]
        }
    }
    
    @IBAction func canceChooselDate(sender: AnyObject) {
        let positions: [ExpirePosition] = ExpirePosition().entries()
        let regularPositons = positions.filter { $0.discriminator == "regular" }.sorted { $0.expiryDate > $1.expiryDate }
        let trendPositions = positions.filter { $0.discriminator == "trend" }.sorted { $0.expiryDate > $1.expiryDate }
        if (positions.count > 0) {
            dataSource?.items = [PositionWrapper(title: "regular", positions: regularPositons),
                                 PositionWrapper(title: "trend", positions: trendPositions)]
        }
        datePrioritazer.setDefaultState(state: false, animated: true)
    }
    
    @IBAction func doneChooseDate(sender: AnyObject) {
        datePrioritazer.setDefaultState(state: false, animated: true)
    }
}

class PositionsExpireViewController: PositionsViewController {
    var calendar: UIView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getExpirePositions()
        
        Position.notifier.subscribe(self , block: { [weak self] _, _ in
            self?.getExpirePositions()
        })
        
        dataSource?.positionMetrics.modifyItem = { item in
            guard let position = item.entry as? Position else { return }
            item.size = position.isOpen == true ? 240 : 70
        }
        dataSource?.positionMetrics.selection = { [weak self] view in
            guard let position = view.item?.entry as? Position else { return }
            position.isOpen = !position.isOpen
            
            if position.isOpen {
                view.setupChart(position: position)
            }
            self?.dataSource?.reload()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        calendar?.isHidden = false
    }
    
    func getExpirePositions() {
        guard let token = CustomToken.currentToken?.token  else { return }
        let expirePositionEntryParam = ExpirePositionEntryParam(entryParameters: (baseURL: (MainURL.base(server: .prod).description, nil),
                                                                                  headerParameters: ["x-api-token" : "\(token)"],
                                                                                  bodyParameters: nil))
        UserRequest.getExpirePositions(expirePositionEntryParam, completion: { [weak self] json, success in
            self?.spinner.stopAnimating()
            guard let json = json, success == true else { return }
            let positions: [ExpirePosition] = ExpirePosition.setupPosition(json: json)
            let regularPositons = positions.filter { $0.discriminator == "regular" }.sorted { $0.expiryDate > $1.expiryDate }
            let trendPositions = positions.filter { $0.discriminator == "trend" }.sorted { $0.expiryDate > $1.expiryDate }
            if (positions.count > 0) {
                self?.dataSource?.items = [PositionWrapper(title: "regular", positions: regularPositons),
                                           PositionWrapper(title: "trend", positions: trendPositions)]
            }
            self?.streamView?.reload()
        })
    }
}
