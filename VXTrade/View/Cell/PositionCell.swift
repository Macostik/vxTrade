//
//  PositionCell.swift
//  VXTrade
//
//  Created by Yuriy on 1/24/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import Foundation
import UIKit
import Charts

protocol PositionCellDelegate: class {
    func positionCellDidBeginPanning(cell: Any)
    func positionCellDidEndPanning(cell: Any, performedAction:Bool)
}

final class PositionItemHeader: EntryStreamReusableView<PositionWrapper> {
    
    var title: String? = nil {
        willSet {
            headerLabel.text = ((newValue ?? "") + " POSITIONS").uppercased()
            backgroundColor = UIColor.darkGray
        }
    }
    let headerLabel = specify(UILabel(), {
        $0.textColor = UIColor.white
    })
    
    override func setup(entry: PositionWrapper) { }

    override func layoutWithMetrics(metrics: StreamMetricsProtocol) {
        add(headerLabel, {
            $0.leading.equalTo(self).offset(20)
            $0.centerY.equalTo(self)
        })
    }
}

class PositionCell<T: Position>: EntryStreamReusableView<T> {
    
    var swipeAction: SwipeAction?
    weak var delegate: PositionCellDelegate?
    private let assetSocket = SocketManager()
    private let sellRateSocket = SocketManager()
    private let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
    var closeDatesList = [Double]()
    var datesList = [Double]()
    
    let containerView = UIView()
    
    let assetLabel = specify(UILabel(), {
        $0.textColor = UIColor.white
        $0.font = UIFont.systemFont(ofSize: 11)
        $0.textAlignment = .center
    })
    
    let assetValueLabel = specify(UILabel(), {
        $0.textColor = UIColor.white
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.numberOfLines = 2
    })
    
    let investLabel = specify(UILabel(), {
        $0.textColor = UIColor.white
        $0.font = UIFont.systemFont(ofSize: 11)
        $0.numberOfLines = 2
    })
    let investValueLabel = specify(UILabel(), {
        $0.textColor = UIColor.white
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.numberOfLines = 2
        $0.textAlignment = .center
    })
    
    let marketRateLabel = specify(UILabel(), {
        $0.textColor = UIColor.white
        $0.font = UIFont.systemFont(ofSize: 11)
        $0.numberOfLines = 2
        $0.textAlignment = .center
    })
    
    let marketRateValueLabelTop = specify(UILabel(), {
        $0.textColor = UIColor.white
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.numberOfLines = 2
        $0.textAlignment = .center
    })
    let marketRateValueLabelBottom = specify(UILabel(), {
        $0.textColor = Color.caral
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.numberOfLines = 2
        $0.textAlignment = .center
    })
    
    let expiryLabel = specify(UILabel(), {
        $0.textColor = UIColor.white
        $0.font = UIFont.systemFont(ofSize: 11)
        $0.numberOfLines = 2
    })
    
    let expiryValueLabel = specify(UILabel(), {
        $0.textColor = UIColor.white
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.numberOfLines = 2
        $0.textAlignment = .center
    })
    
    let payoutLabel = specify(UILabel(), {
        $0.textColor = UIColor.white
        $0.font = UIFont.systemFont(ofSize: 11)
        $0.numberOfLines = 2
        
    })
    
    let payoutValueLabelTop = specify(UILabel(), {
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.textColor = UIColor.white
        $0.numberOfLines = 2
        $0.textAlignment = .center
    })
    let payoutValueLabelBottom = specify(UILabel(), {
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.textColor = UIColor.white
        $0.numberOfLines = 2
        $0.textAlignment = .center
    })
    
    let separatorView = specify(UIView(), {
        $0.backgroundColor = Color.darkGray
    })
    
    let chartView = specify(LineChartView(), {
        $0.backgroundColor = UIColor.black
        $0.drawBordersEnabled = true
        $0.setScaleEnabled(true)
        $0.noDataText = ""
        $0.minOffset = 0
        $0.chartDescription?.text = ""
        $0.xAxis.labelPosition = .bottomInside
        $0.legend.enabled = false
        $0.drawBordersEnabled = false
        $0.highlightPerTapEnabled = false
        $0.drawGridBackgroundEnabled = false
        $0.xAxis.drawGridLinesEnabled = false
        $0.leftAxis.drawLabelsEnabled = false
        $0.leftAxis.drawAxisLineEnabled = false
        $0.leftAxis.drawGridLinesEnabled = false
        $0.rightAxis.drawGridLinesEnabled = false
        $0.xAxis.labelTextColor = UIColor.lightGray
        $0.rightAxis.labelTextColor = UIColor.lightGray
        $0.xAxis.valueFormatter = XAxisValueFormatter()
    })
    
    let linesLabel = Label(icon: "w", size: 28)
    
    var positionValue: String = "" {
        willSet {
            marketRateValueLabelBottom.textColor = (marketRateValueLabelBottom.text ?? "") > newValue ? Color.caral : Color.green
            marketRateValueLabelBottom.text = newValue
        }
    }
    
    override func setup(entry position: T) {
        assetLabel.text = "Asset"
        investLabel.text = "Inveset"
        assetValueLabel.text = position.assetName()
        investValueLabel.text = "$" + position.investment.toString()
        marketRateLabel.text = "Entry | Market Rate"
        marketRateValueLabelTop.text = position.marketEntryRate.toString()
        marketRateValueLabelBottom.text = position.marketExpiryRate.toString()
        expiryLabel.text = "Expiry"
        expiryValueLabel.text = Date.init(timeIntervalSince1970: TimeInterval.convertMillisecond(date: position.expiryDate.toString())).stringWithFormat("MMM dd hh:mm")
        payoutLabel.text = "Payout | Shell"
        if entry is ExpirePosition {
            payoutValueLabelTop.text = "$" + 3 << position.payout.toString()
            payoutValueLabelBottom.text = position.status.uppercased()
            payoutValueLabelTop.textColor = position.status == "won" ? Color.green : Color.caral
            payoutValueLabelBottom.textColor =  position.status == "won" ? Color.green : Color.caral
        } else {
            payoutValueLabelTop.text = "$0.000"
            payoutValueLabelBottom.text = "$0.000"
        }
        
        linesLabel.text = entry is ExpirePosition ? "" : "w"
        
        if entry is TemporaryRegularPosition || entry is TemporaryTrendPosition {
            if let assetID = entry?.assetId.toString() {
                assetSocket.sendMessage(.chartSubscribe(assetID: assetID) , messageHandler: {[weak self] close, time in
                    guard let `self` = self else { return }
                    self.positionValue = close
                })
            }
            if let customerID = CustomToken.currentToken?.id {
                sellRateSocket.sendMessage(.sellRate(customerID: customerID.toString(), positionID: position.id.toString()), messageHandler: { [weak self] value, _ in
                    guard let `self` = self else { return }
                    self.payoutValueLabelBottom.text = "$ " + value
                })
            }
        }
        
        swipeAction = specify(SwipeAction(containerView: self, movingView: containerView, entry: position), {
            $0.shouldBeginPanning = { _ in
                return position is ExpirePosition ? .unknown : .right
            }
            
            $0.didBeginPanning = { [weak self] (action) -> Void in
                guard let weakSelf = self as PositionCell<T>? else { return }
                weakSelf.delegate?.positionCellDidBeginPanning(cell: weakSelf)
            }
            
            $0.didEndPanning = { [weak self] (action, performedAction) -> Void in
                guard let weakSelf = self as PositionCell<T>? else { return }
                weakSelf.delegate?.positionCellDidEndPanning(cell: weakSelf, performedAction: performedAction)
            }
            
            $0.didPerformAction = { [weak self] act in
                guard let entry = self?.entry, let view = UINavigationController.main.topViewController?.view else { return }
                switch act {
                case .sell:
                    SellConfirmView(entry: entry).showInView(view)
                    break
                case .rollover:
                    RolloverConfirmView(entry: entry).showInView(view)
                    break
                case .riskFree:
                    RiskConfirmView(entry: entry).showInView(view)
                    break
                    
                }
            }
        })
    }
    
    func setupChart(position: Position) {
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        guard let token = CustomToken.currentToken?.token else { return }
        let positionGraphEntryParam = PositionGraphEntryParam(entryParameters: (baseURL: (MainURL.base(server: .prod).description, position.assetId.toString()),
                                                                              headerParameters: ["x-api-token" : "\(token)"],
                                                                              bodyParameters: nil))
        UserRequest.getPositionGraph(positionGraphEntryParam, completion: { [weak self] json, success in
            self?.spinner.stopAnimating()
            guard let json = json, success == true else { return }
            let dataGraph = json[position.assetId.toString()].arrayValue
            guard dataGraph.count > 0 else { return }
            
            let closesList = dataGraph.map { $0["value"].doubleValue }
            let datesList = dataGraph.map { $0["date"].stringValue.date()?.timeIntervalSince1970 ?? 0.0 }
            
            var dataEntries: [ChartDataEntry] = []
            
            for i in 0..<closesList.count {
                let dataEntry = ChartDataEntry(x: datesList[i], y: closesList[i])
                dataEntries.append(dataEntry)
            }
            
            let lineChartDataSet = LineChartDataSet(values: dataEntries, label: "")
            let gradientColors = [Color.green.cgColor, UIColor.black.cgColor]
            let entryRate = position.pricedEntryRate
            let minValue = (closesList.min() ?? 1.0)
            let maxValue = (closesList.max() ?? 1.0)
            var entryRateValue: CGFloat = 0.0
            if entryRate > minValue {
                entryRateValue = 1 - CGFloat((maxValue - entryRate)/(maxValue - minValue))
            }
            entryRateValue = entryRateValue > 1.0 ? 1.0 : entryRateValue
            let colorLocations:[CGFloat] = [entryRateValue, entryRateValue]
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors as CFArray, locations: colorLocations)
            lineChartDataSet.fill = Fill.fillWithLinearGradient(gradient!, angle: 90)
            lineChartDataSet.fillFormatter = position.direction == "call" ? posFormatter() : negFormatter()
            lineChartDataSet.drawFilledEnabled = true
            lineChartDataSet.lineWidth = 0.0
            lineChartDataSet.drawValuesEnabled = false
            lineChartDataSet.drawCirclesEnabled = false
            lineChartDataSet.drawVerticalHighlightIndicatorEnabled = false
            lineChartDataSet.drawHorizontalHighlightIndicatorEnabled = false
            
            let lineChartData = LineChartData(dataSet: lineChartDataSet)
            self?.chartView.data = lineChartData
        })
    }
    
    override func layoutWithMetrics(metrics: StreamMetricsProtocol) {
        super.layoutWithMetrics(metrics: metrics)
        
        add(containerView, {
            $0.edges.equalTo(self)
        })
        
        containerView.add(assetValueLabel, {
            $0.centerX.equalTo(containerView).multipliedBy(0.2)
            $0.top.equalTo(containerView).offset(30)
        })
        
        containerView.add(assetLabel, {
            $0.top.equalTo(containerView.snp.top).offset(12)
            $0.centerX.equalTo(assetValueLabel)
        })
        
        containerView.add(investLabel, {
            $0.centerX.equalTo(containerView).multipliedBy(0.525)
            $0.centerY.equalTo(assetLabel)
        })
        
        containerView.add(investValueLabel, {
            $0.centerX.equalTo(investLabel)
            $0.top.equalTo(assetValueLabel)
        })
        
        containerView.add(marketRateLabel, {
            $0.centerX.equalTo(containerView).multipliedBy(0.9)
            $0.width.equalTo(100)
            $0.centerY.equalTo(assetLabel)
        })
        
        containerView.add(marketRateValueLabelTop, {
            $0.centerX.equalTo(marketRateLabel)
            $0.top.equalTo(containerView).offset(30)
        })
        
        containerView.add(marketRateValueLabelBottom, {
            $0.centerX.equalTo(marketRateLabel)
            $0.top.equalTo(marketRateValueLabelTop.snp.bottom)
        })
        
        containerView.add(linesLabel,  {
            $0.centerX.equalTo(containerView).multipliedBy(1.9)
            $0.centerY.equalTo(containerView)
        })
        
        containerView.add(expiryLabel, {
            $0.trailing.equalTo(linesLabel.snp.leading)
            $0.centerY.equalTo(assetLabel)
        })
        
        containerView.add(expiryValueLabel, {
            $0.centerX.equalTo(expiryLabel)
            $0.top.equalTo(marketRateValueLabelTop)
            $0.width.equalTo(50)
        })
        
        containerView.add(payoutLabel, {
            $0.centerX.equalTo(containerView).multipliedBy(1.375)
            $0.centerY.equalTo(assetLabel)
        })
        
        containerView.add(payoutValueLabelTop, {
            $0.centerX.equalTo(payoutLabel)
            $0.top.equalTo(containerView).offset(30)
        })
        
        containerView.add(payoutValueLabelBottom, {
            $0.centerX.equalTo(payoutLabel)
            $0.top.equalTo(payoutValueLabelTop.snp.bottom)
        })
        
        add(separatorView, {
            $0.height.equalTo(1)
            $0.leading.trailing.bottom.equalTo(self)
        })
        
        add(chartView, {
            $0.leading.trailing.bottom.equalTo(self)
            $0.top.equalTo(payoutValueLabelBottom.snp.bottom).offset(12)
        })
        
        chartView.add(spinner) {
            $0.center.equalTo(chartView)
        }
    }
}
