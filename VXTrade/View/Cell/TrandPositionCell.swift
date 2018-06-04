//
//  TrandPositionCell.swift
//  VXTrade
//
//  Created by Yura Granchenko on 2/22/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Charts

class TrandPositionCell<T: PositionItem>: EntryStreamReusableView<T> {
    let toggleView = specify(UIView(), {
        $0.backgroundColor = Color.darkGray
        $0.layer.cornerRadius = 1.5
    })
    let separatorView = specify(UIView(), {
        $0.backgroundColor = Color.darkGray
    })
    var cirleView = specify(CircleProgressView(), {
        $0.roundedCorners = false
        $0.thicknessRatio = 0.05
        $0.trackTintColor = Color.darkGray
        $0.progressTintColor = Color.green
    })
    let assetNameLabel = specify(UILabel(), {
        $0.textColor = UIColor.white
        $0.font = UIFont.boldSystemFont(ofSize: 17.0)
    })
    let assetValueLabel = specify(UILabel(), {
        $0.textColor = Color.green
        $0.font = UIFont.systemFont(ofSize: 11.5)
    })
    let investmentLabel = specify(UILabel(), {
        $0.textColor = Color.gray
        $0.font = UIFont.systemFont(ofSize: 11.5)
    })
    let investmentValueLabel = specify(UILabel(), {
        $0.textColor = UIColor.white
        $0.font = UIFont.systemFont(ofSize: 11.5)
    })
    let payoutLabel = specify(UILabel(), {
        $0.textColor = Color.gray
        $0.font = UIFont.systemFont(ofSize: 11.5)
    })
    let payoutValueLabel = specify(UILabel(), {
        $0.textColor = Color.green
        $0.font = UIFont.systemFont(ofSize: 11.5)
    })
    let entryRateLabel = specify(UILabel(), {
        $0.textColor = Color.gray
        $0.font = UIFont.systemFont(ofSize: 11.5)
    })
    let entryRateValueLabel = specify(UILabel(), {
        $0.textColor = UIColor.white
        $0.font = UIFont.systemFont(ofSize: 11.5)
    })
    let currencyLabel = Label(icon: "v", size: 24.0, textColor: UIColor.white)
    let arrowLabel = Label(icon: "H", size: 13.0, textColor: Color.green)
    let currencyAmountLabel = specify(UILabel(), {
        $0.textColor = UIColor.white
        $0.font = UIFont.boldSystemFont(ofSize: 15.0)
        $0.adjustsFontSizeToFitWidth = true
    })
   
    let currencyButton = Button()
    
    let chartView = specify(LineChartView(), {
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
    
    override func setup(entry positionItem: T) {
        backgroundColor = UIColor.black

        if let asset: Asset = getRealmEntry(Asset.self, by: positionItem.position.assetId) {
             assetNameLabel.text = asset.name
        }
        assetValueLabel.text = positionItem.position.marketExpiryRate.toString()
        investmentLabel.text = "Invest"
        investmentValueLabel.text = "$ " + positionItem.position.investment.toString()
        payoutLabel.text = "Payout"
        payoutValueLabel.text = "$ " + positionItem.position.payout.toString()
        entryRateLabel.text = "Entry Rate"
        entryRateValueLabel.text = positionItem.position.pricedEntryRate.toString()
        currencyAmountLabel.text = "$ 0.000"

        if positionItem.position is TemporaryRegularPosition {
            cirleView.snp.updateConstraints{ (make) in
                make.leading.equalTo(-46)
            }
            layoutIfNeeded()
        } else {
            if positionItem.progress == 0 {
                  positionItem.handleProgress(for: cirleView)
            }
        }
        
        currencyButton.click { _ in
            guard let view = UINavigationController.main.topViewController?.view,
            let token = CustomToken.currentToken?.token,
            let amountText = self.currencyAmountLabel.text else { return }
            let amount = 1 << String(amountText.characters.dropFirst())
            SellConfirmView(entry: positionItem.position).showInView(view, success: {
                let rolloverPositionEntryParam = RolloverPositionEntryParam(entryParameters: (baseURL: (MainURL.base(server: .prod).description, positionItem.position.id.toString() ),
                                                                                        headerParameters: ["x-api-token" : "\(token)"],
                                                                                        bodyParameters: (nil, [ "Price" : amount, "Type" : "ByMeOut" ] )))
                UserRequest.makeRolloverPositions(rolloverPositionEntryParam, completion: { _, success in
                    guard success == true else { return }
                    positionItem.prepareDelete()
                })
            }, cancel: nil)
        }
        
        positionItem.arrivedAssetRateData = { [weak self] isCall, value in
            guard let `self` = self else { return }
            self.assetValueLabel.textColor = isCall ? Color.caral : Color.green
            self.assetValueLabel.text = value
            UIView.beginAnimations(nil, context: nil)
            self.arrowLabel.textColor = isCall ? Color.caral : Color.green
            self.arrowLabel.contentMode = isCall ? .top : .bottom
            self.arrowLabel.rotate = true
            UIView.commitAnimations()
        }
        positionItem.arrivedSellRateData = { [weak self] value in
            guard let `self` = self else { return }
            self.currencyAmountLabel.text = "$ " + value
            if positionItem.position is TemporaryTrendPosition {
                self.cirleView.progressTintColor = positionItem.position.investment > value.toDouble() ? Color.caral : Color.green
            }
        }
        setupChart(positionItem: positionItem)
    }
    
    func setupChart(positionItem: T) {
        guard let closeDatesList = positionItem.position.graphData?.close.components(separatedBy: " ").flatMap(Double.init),
              let datesList = positionItem.position.graphData?.date.components(separatedBy: " ").flatMap(Double.init) else { return }
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<closeDatesList.count {
            let dataEntry = ChartDataEntry(x: datesList[i], y: closeDatesList[i])
            dataEntries.append(dataEntry)
        }
        
        let lineChartDataSet = LineChartDataSet(values: dataEntries, label: "")
        let gradientColors = [Color.green.cgColor, UIColor.black.cgColor]
        let entryRate = positionItem.position.pricedEntryRate
        let minValue = (closeDatesList.min() ?? 1.0)
        let maxValue = (closeDatesList.max() ?? 1.0)
        var entryRateValue: CGFloat = 0.0
        if entryRate > minValue {
            entryRateValue = 1 - CGFloat((maxValue - entryRate)/(maxValue - minValue))
        }
        entryRateValue = entryRateValue > 1.0 ? 1.0 : entryRateValue
        let colorLocations:[CGFloat] = [entryRateValue, entryRateValue]
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors as CFArray, locations: colorLocations)
        lineChartDataSet.fill = Fill.fillWithLinearGradient(gradient!, angle: 90)
        lineChartDataSet.fillFormatter = positionItem.position.direction == "call" ? posFormatter() : negFormatter()
        lineChartDataSet.drawFilledEnabled = true
        lineChartDataSet.lineWidth = 0.0
        lineChartDataSet.drawValuesEnabled = false
        lineChartDataSet.drawCirclesEnabled = false
        lineChartDataSet.drawVerticalHighlightIndicatorEnabled = false
        lineChartDataSet.drawHorizontalHighlightIndicatorEnabled = false
        
        let lineChartData = LineChartData(dataSet: lineChartDataSet)
        self.chartView.data = lineChartData
    }
    
    override func layoutWithMetrics(metrics: StreamMetricsProtocol) {
        super.layoutWithMetrics(metrics: metrics)
        
        add(cirleView, {
            $0.leading.top.equalTo(self).inset(12)
            $0.size.equalTo(46)
        })
        add(assetNameLabel, {
            $0.top.equalTo(self).offset(5)
            $0.leading.equalTo(cirleView.snp.trailing).offset(Constants.screenWidth > 320 ? 12 : 5)
        })
        add(arrowLabel, {
            $0.centerY.equalTo(assetNameLabel)
            $0.leading.equalTo(assetNameLabel.snp.trailing).offset(5)
        })
        add(assetValueLabel, {
            $0.centerY.equalTo(arrowLabel)
            $0.leading.equalTo(arrowLabel.snp.trailing).offset(5)
        })
        add(investmentLabel, {
            $0.leading.equalTo(assetNameLabel)
            $0.top.equalTo(assetValueLabel.snp.bottom).offset(5)
        })
        add(investmentValueLabel, {
            $0.centerY.equalTo(investmentLabel)
            $0.leading.equalTo(investmentLabel.snp.trailing).offset(5)
        })
        add(payoutLabel, {
            $0.leading.equalTo(investmentValueLabel.snp.trailing).offset(5)
            $0.centerY.equalTo(investmentValueLabel)
        })
        add(payoutValueLabel, {
            $0.centerY.equalTo(investmentLabel)
            $0.leading.equalTo(payoutLabel.snp.trailing).offset(5)
        })
        add(entryRateLabel, {
            $0.leading.equalTo(assetNameLabel)
            $0.top.equalTo(investmentLabel.snp.bottom).offset(5)
        })
        add(entryRateValueLabel, {
            $0.centerY.equalTo(entryRateLabel)
            $0.leading.equalTo(entryRateLabel.snp.trailing).offset(5)
        })
        let currencyView = specify(UIView(), {
            $0.layer.cornerRadius = 5.0
            $0.backgroundColor = Color.caral
        })
        add(currencyView, {
            $0.trailing.equalTo(self).inset(Constants.screenWidth > 320 ? 12 : 5)
            $0.centerY.equalTo(cirleView)
        })
        add(currencyButton, {
            $0.size.equalTo(currencyView)
            $0.center.equalTo(currencyView)
        })
        currencyView.add(currencyLabel, {
            $0.leading.top.bottom.equalTo(currencyView).inset(10)
        })
        currencyView.add(currencyAmountLabel, {
            $0.trailing.top.bottom.equalTo(currencyView).inset(10)
            $0.leading.equalTo(currencyLabel.snp.trailing).offset(5)
        })
        
        add(separatorView, {
            $0.leading.trailing.bottom.equalTo(self)
            $0.height.equalTo(1)
        })
        add(toggleView, {
            $0.centerX.equalTo(self)
            $0.bottom.equalTo(separatorView.snp.top).offset(-3)
            $0.height.equalTo(3)
            $0.width.equalTo(60)
        })
        add(chartView, {
            $0.leading.trailing.bottom.equalTo(self)
            $0.top.equalTo(cirleView.snp.bottom).offset(12)
        })
    }
}

class negFormatter: IFillFormatter {
    func getFillLinePosition(dataSet: ILineChartDataSet, dataProvider: LineChartDataProvider) -> CGFloat {
        return 10
    }
}

class posFormatter: IFillFormatter {
    func getFillLinePosition(dataSet: ILineChartDataSet, dataProvider: LineChartDataProvider) -> CGFloat {
        return 1
    }
}
