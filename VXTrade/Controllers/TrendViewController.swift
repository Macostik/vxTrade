
//
//  TrendViewController.swift
//  VXTrade
//
//  Created by Yuriy on 2/13/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import UIKit
import Charts

enum MoveView {
    case Top, Middle, Bottom
    
    mutating func next() {
        switch self {
        case .Top:
            self = .Middle
        case .Middle:
            self = .Bottom
        case .Bottom:
            break
        }
    }
    
    mutating func previous() {
        switch self {
        case .Top:
            break
        case .Middle:
            self = .Top
        case .Bottom:
            self = .Middle
        }
    }
}

class TrendViewController: BaseViewController, UITextFieldDelegate {

    @IBOutlet var chartView: LineChartView!
    @IBOutlet var currencyStreamView: StreamView!
    @IBOutlet var positonsStreamView: StreamView!
    @IBOutlet var currencyLayoutPrioritizer: LayoutPrioritizer!
    @IBOutlet var searchTextField: TextField?
    @IBOutlet var assetNameLabel: UILabel!
    @IBOutlet var assetPositionLabel: UILabel!
    @IBOutlet var firstPersentButton: UIButton!
    @IBOutlet var secondPersentButton: UIButton!
    @IBOutlet var thirdPersentButton: UIButton!
    @IBOutlet var payoutLabel: UILabel!
    @IBOutlet var protectLabel: UILabel!
    @IBOutlet var profitSegmentControl: SegmentedControl!
    @IBOutlet var firstSeporatorView: UIView!
    @IBOutlet var secondSeporatorView: UIView!
    @IBOutlet var investmentTextField: TextField!
    @IBOutlet var assetStreamView: StreamView!
    @IBOutlet var expirePositionLabel: UILabel!
    @IBOutlet var movingView: UIView!
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    
    var updateBadgeHandler: Block?
    var updatePositionBlock: BooleanBlock?
    
    private var assetDataSource: StreamDataSource<[AssetPoint]>?
    private var currencyDataSource: CurrencyDataSource?
    private var positionDataSource: StreamDataSource<[PositionItem]>?
    private var currentRule: TrendRule? = nil
    private let socket = SocketManager()
    private var selectPayout: Payout? = nil
    private var investment: Float = 5
    private var payout = ""
    private var expirePositionTime = 60.0
    private let popoverView = PopoverView()
    
    private var closeDatesList = [Double]()
    private var datesList = [TimeInterval]()
    private var positionItemsList = [PositionItem]()
    
    private let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
    private var currencyList = [CurrencyWrapper]()
    var movingViewState = MoveView.Top {
        willSet {
            whenLoaded { [weak self] in
                var value: CGFloat = 0.0
                switch newValue {
                case .Top:
                    value = 0
                case .Middle:
                    if (self?.positionDataSource?.items?.count ?? 0) <= 1 {
                        value = 100
                    } else {
                        value = 180
                    }
        
                case .Bottom:
                    value = Constants.screenHeight/2
                }
                UIView.animate(withDuration: 0.5, animations: {
                    self?.movingView.y = value
                })
            }
        }
    }
    var positionValue: String = "" {
        willSet {
            assetPositionLabel.textColor = (assetPositionLabel.text ?? "") >= newValue ? Color.caral : Color.green
            assetPositionLabel.text = newValue
        }
    }
    
    override func loadView() {
        super.loadView()
        spinner.hidesWhenStopped = true
        chartView.add(spinner) { (make) in
            make.center.equalTo(chartView)
        }
        spinner.startAnimating()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chartView.drawBordersEnabled = true
        chartView.setScaleEnabled(true)
        chartView.noDataText = ""
        chartView.chartDescription?.text = ""
        chartView.minOffset = 0
        chartView.xAxis.labelPosition = .bottomInside
        chartView.legend.enabled = false
        chartView.drawBordersEnabled = false
        chartView.highlightPerTapEnabled = false
        chartView.drawGridBackgroundEnabled = false
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.leftAxis.drawLabelsEnabled = false
        chartView.leftAxis.drawAxisLineEnabled = false
        chartView.leftAxis.drawGridLinesEnabled = false
        chartView.rightAxis.drawGridLinesEnabled = false
        chartView.xAxis.labelTextColor = UIColor.lightGray
        chartView.rightAxis.labelTextColor = UIColor.lightGray
        chartView.xAxis.valueFormatter = XAxisValueFormatter()
        
        
        positionDataSource = StreamDataSource(streamView: positonsStreamView)
        let metrics = StreamMetrics<TrandPositionCell<PositionItem>>(size: 70)
        metrics.modifyItem = { item in
            guard let positionItem = item.entry as? PositionItem else { return }
            item.size = positionItem.position.isOpen == true ? 240 : 70
        }
        metrics.selection = { [weak self] view in
            guard let positonItem = view.item?.entry as? PositionItem else { return }
            positonItem.position.isOpen = !positonItem.position.isOpen
            self?.positionDataSource?.reload()
        }
        
        positionDataSource?.addMetrics(metrics: metrics)
        investmentTextField.text = "$\(Int(investment))"
    
        guard let token = CustomToken.currentToken?.token, let boot = Boot.boot()  else { return }
        let trendRulesEntryParam = OpenRulesEntryParam(entryParameters: (baseURL: (MainURL.base(server: .prod).description, boot.brandLastModified.toString()),
                                                                         headerParameters: ["x-api-token" : "\(token)"],
                                                                         bodyParameters: nil))
        UserRequest.getTrendRules(trendRulesEntryParam, completion: { [weak self]  json, success in
            guard let json = json, success == true else { return }
            
            let trendRule:[TrendRule] = TrendRule.setupRule(json: json)
            self?.currentRule = trendRule.sorted { $0.optionDuration > $1.optionDuration }.last
            guard let asset = self?.currentRule?.asset else { return }
            self?.handleGraph(with: asset)
            self?.gexExpireTime()
        })
        
        assetStreamView.layout = HorizontalViсeVersaStreamLayout()
        let screenWidth = Constants.screenWidth
        let size = screenWidth/(screenWidth < 375 ? 6 : screenWidth > 375 ? 8 : 7)
        let assetPointMetrics = StreamMetrics<AssetPointCell>(size: size)
        assetDataSource = StreamDataSource(streamView: assetStreamView)
        assetDataSource?.addMetrics(metrics: assetPointMetrics)
        assetDataSource?.items = [AssetPoint]()
        
        currencyDataSource = CurrencyDataSource(streamView: currencyStreamView)
        searchTextField?.addTarget(self, action: #selector(self.searchTextChanged(sender:)), for: .editingChanged)
        currencyDataSource?.positionMetrics.selection = { [weak self] view in
            self?.view.endEditing(true)
            guard let assetID = self?.currentRule?.asset?.id.toString() else { return }
            self?.socket.unsibsribeAsset(from: assetID)
            guard let asset = view.item?.entry as? Asset else { return }
            self?.currentRule = asset.getTrendRule()
            self?.handleGraph(with: asset)
        }
        Position.notifier.subscribe(self, block: { [weak self] _, position in
            if let deletePositionItem = self?.positionItemsList.first(where: { $0.position == position }) {
                self?.positionItemsList.remove(deletePositionItem)
            }
            self?.positionDataSource?.items = self?.positionItemsList
            self?.updateBadgeHandler?()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updatePositionBlock?(true)
    }
    
    func handleGraph(with asset: Asset) {
        guard let token = CustomToken.currentToken?.token,
        let rule = asset.getTrendRule(),
        let payouts = rule.groupPayouts.first?.payouts else { return }
        assetNameLabel.text = asset.name
        self.assetDataSource?.items = []
        
        for (i, payout) in payouts.enumerated() {
            switch i {
            case 0:
                firstPersentButton.setTitle("\(payout.profit)%", for: .normal)
                firstPersentButton.isHidden = false
            case 1:
                secondPersentButton.setTitle("\(payout.profit)%", for: .normal)
                secondPersentButton.isHidden = false
                firstSeporatorView.isHidden = false
            case 2:
                thirdPersentButton.setTitle("\(payout.profit)%", for: .normal)
                thirdPersentButton.isHidden = false
                secondSeporatorView.isHidden = false
            default:
                break
            }
        }
        let parseProfit: ((String) -> Void) = {[weak self] title in
            guard let `self` = self else { return }
            self.selectPayout = Array(payouts).filter { $0.profit.toString() == title }.first
            let amount = Float(self.selectPayout?.profit ?? 1)
            let loss = Float(self.selectPayout?.loss ?? 1)
            let payout = (amount * self.investment)/100.0 + self.investment
            let payoutSting = 2 << "\(payout)"
            self.payoutLabel.text = "$" + payoutSting
            self.payoutLabel.isHidden = false
            self.payout = payoutSting
            self.protectLabel.text = "$" + 2 << "\((self.investment * loss)/100)"
            self.protectLabel.isHidden = false
        }
        if let profit = profitSegmentControl.selectedButton()?.titleLabel?.text?.characters.dropLast() {
            parseProfit(String(profit))
        }
        profitSegmentControl.selectHalper = { button in
            if let profit = button?.titleLabel?.text?.characters.dropLast() {
                parseProfit(String(profit))
            }
        }
        chartView.data = nil
        self.spinner.startAnimating()
        currencyLayoutPrioritizer.setDefaultState(state: false, animated: true)
        
        self.listenSocket(with: asset)
        
        let regularGraphEntryParam = RegularGraphEntryParam(entryParameters: (baseURL: (MainURL.base(server: .prod).description, rule.id.toString()),
                                                                              headerParameters: ["x-api-token" : "\(token)"],
                                                                              bodyParameters: nil))
        UserRequest.getRegularGraph(regularGraphEntryParam, completion: { [weak self] json, success in
            self?.spinner.stopAnimating()
            guard let json = json, success == true, let `self` = self else { return }
            let dataGraph = json[rule.id.toString()].arrayValue
            guard dataGraph.count > 0 else { return }
            
            self.closeDatesList = dataGraph.map { $0["close"].doubleValue }
            self.datesList = dataGraph.map { $0["date"].stringValue.date()?.timeIntervalSince1970 ?? 0.0 }
            
            var dataEntries: [ChartDataEntry] = []
            for i in 0..<dataGraph.count {
                let dataEntry = ChartDataEntry(x: self.datesList[i], y: self.closeDatesList[i])
                dataEntries.append(dataEntry)
            }
            
            let lineChartDataSet = LineChartDataSet(values: dataEntries, label: "")
            let gradientColors = [UIColor.white.cgColor, UIColor.clear.cgColor]
            let colorLocations:[CGFloat] = [0.5, 0.0]
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors as CFArray, locations: colorLocations)
            lineChartDataSet.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0)
            lineChartDataSet.drawFilledEnabled = true
            lineChartDataSet.lineWidth = 0.0
            lineChartDataSet.drawValuesEnabled = false
            lineChartDataSet.drawCirclesEnabled = false
            lineChartDataSet.drawVerticalHighlightIndicatorEnabled = false
            lineChartDataSet.drawHorizontalHighlightIndicatorEnabled = false
            
            let lineChartData = LineChartData(dataSet: lineChartDataSet)
            self.chartView.data = lineChartData
        })
    }
    
    //MARK: Actions
    
    func gexExpireTime() {
        let rules:[TrendRule] = TrendRule().entries()
        popoverView.selectedItemBlock = { [weak self] time in
            self?.expirePositionTime = Double(time) ?? 60
            self?.expirePositionLabel.text = "\(time)s"
            if let assetName = self?.currentRule?.asset?.name {
                self?.currentRule = rules.filter { $0.optionDuration == Int(time) && ($0.asset?.name ?? "") == assetName }.first
            }
        }
        if let assetName = currentRule?.asset?.name {
            let expireTime = Set(rules.filter { ($0.asset?.name ?? "") == assetName }.flatMap { $0.optionDuration.toString() })
            popoverView.contentData = Array(expireTime).flatMap {Int($0)}.sorted().flatMap{$0.toString()}
            guard let expireSecond = popoverView.contentData.first?.toDouble() else { return }
            expirePositionTime = expireSecond
            expirePositionLabel.text = "\(expireSecond)s"
        }
    }
    
    @IBAction func expireRuleClick(sender: UIView) {
        popoverView.showInView(view, sourceView: sender)
    }
    
    @IBAction func putTrade(sender: Button) {
        checkBalance(direction:"put")
    }
    
    @IBAction func callTrade(sender: Button) {
        checkBalance(direction:"call")
    }
    
    @IBAction func showCurrency(sender: AnyObject?) {
        var asset = Set<Asset>()
        let trens: [TrendRule] = TrendRule().entries()
        _ = trens.map { asset.insert($0.asset ?? Asset()) }
        let groups = Set(asset.map { $0.group })
        currencyList = []
        for (_,  group) in groups.enumerated() {
            currencyList.append(CurrencyWrapper(title: group, asset: asset.filter({ $0.group == group })))
        }
        currencyDataSource?.items = currencyList.sorted { $0.title < $1.title }
        currencyLayoutPrioritizer.setDefaultState(state: !currencyLayoutPrioritizer.defaultState, animated: true)
    }
    
    @IBAction func swipe(sender: UIPanGestureRecognizer) {
        guard let contentView = sender.view else { return }
        let translation = sender.translation(in: contentView)
        let percentCompleted = abs(translation.y/contentView.height)
        if percentCompleted > 0.15 && sender.state == .ended {
            if translation.y > 0 {
                if movingViewState == .Middle {
                    updatePositionBlock?(false)
                }
                movingViewState.next()
            } else {
                if movingViewState == .Middle {
                    updatePositionBlock?(true)
                }
                movingViewState.previous()
            }
        }
    }
    
    @IBAction func investmentClick(sender: Button) {
        investmentTextField.becomeFirstResponder()
    }
    
    //MARK: Keyboard
    
    override func keyboardAdjustmentConstant(_ adjustment: KeyboardAdjustment, keyboard: Keyboard) -> CGFloat {
        return keyboard.height - 35
    }
    
    //MARK: UITextFieldDelegate
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return range.location != 0 && range.location < 9
    }
    
    func updatePayout() {
        let amount = Float(selectPayout?.profit ?? 1)
        let loss = Float(selectPayout?.loss ?? 1)
        let payout = (amount * investment)/100.0 + investment
        let payoutSting = 2 << "\(payout)"
        payoutLabel.text = "$" + payoutSting
        protectLabel.text = "$" + 2 << "\((self.investment * loss)/100)"
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text?.characters.removeFirst()
        guard let _investment = textField.text, let inv = Int(_investment), inv > 5 else {
            investment = 5
            textField.text = "$5"
            updatePayout()
            return
        }
        investment = Float(inv)
        textField.text = "$\(inv)"
        updatePayout()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if Keyboard.keyboard.isShown {
            view.endEditing(true)
            return
        }
    }
    
    func checkBalance(direction: String) {
        if Keyboard.keyboard.isShown {
            view.endEditing(true)
            return
        }
    
        guard let balance = CustomToken.currentToken?.balance, balance <= 0 else {
            if let rule = currentRule {
                guard let token = CustomToken.currentToken?.token,
                    let customerID = CustomToken.currentToken?.id,
                    let payoutID = selectPayout?.id,
                    let assetID = rule.asset?.id else { return }
                var newlyPositonID = ""
                let positionConfirmView = PositionConfirmView(entry: rule,
                                    investmentString: 2 << "\(investment)",
                    payoutString: payout)
                let createPositionEntryParam = CreatePositionEntryParam(entryParameters: (baseURL: (MainURL.base(server: .prod).description, nil),
                                                                                          headerParameters: ["x-api-token" : "\(token)"],
                                                                                          bodyParameters: (nil,["assetId" : assetID,
                                                                                                                "direction" : direction,
                                                                                                                "investment" :  "\(Int(investment))",
                                                                                            "payoutId" : payoutID,
                                                                                            "ruleId" : rule.id] )))
                UserRequest.makeCreatingPositions(createPositionEntryParam, completion: {[weak self] json, success in
                    guard let json = json, success == true, let `self` = self else {
                        positionConfirmView.hide()
                        return
                    }
                    newlyPositonID = json["id"].stringValue
                    guard let position: TemporaryTrendPosition = TemporaryTrendPosition.setupPosition(json: json, duration: self.expirePositionTime).first else { return }
                    self.positionItemsList.append(PositionItem.init(position))
                    self.positionDataSource?.items = self.positionItemsList
                    self.updateBadgeHandler?()
                    position.addGraphPoint(self.closeDatesList, date: self.datesList)
                })
                
               positionConfirmView.showInView(view, success: nil, cancel: {
                                        let closePositionEntryParam = ClosePositionEntryParam(entryParameters: (baseURL: (MainURL.base(server: .prod).description, newlyPositonID ),
                                                                                                                headerParameters: ["x-api-token" : "\(token)"],
                                                                                                                bodyParameters: (nil, [ "CustomerId" : customerID, "Type" : "Cancel" ] )))
                UserRequest.makeClosingPositions(closePositionEntryParam, completion: { [weak self] json, success in
                    guard let json = json, success == true, let `self` = self else { return }
                    let searchID = json["id"].intValue
                    guard let deletePositionItem = self.positionItemsList.first(where: { $0.position.id == searchID }) else { return }
                    deletePositionItem.prepareDelete() })
                                    })
            }
            
            return
        }
        
        TakeDepositConfirmView(balance: balance.toString(), depositHandler: { [weak self] in
            guard let controller = self?.embededView?.controller as? MainViewController, let segmentControl = controller.tabBarWrapper?.tabBar  else { return }
            if let control = segmentControl.controlForSegment(2) {
                control.sendActions(for: .touchUpInside)
            }
        }).showInView(view)
    }
    
    //MARK: SocketListener 
    
    func listenSocket(with asset: Asset) {
        var counter = 0
        socket.sendMessage(.chartSubscribe(assetID: asset.id.toString()) , messageHandler: {[weak self] close, time in
            guard let `self` = self else { return }
            counter += 1
            self.positionValue = close
            if counter >= 10 {
                if self.closeDatesList.isEmpty == false && self.datesList.isEmpty == false {
                    _ = self.closeDatesList.removeFirst()
                    _ = self.datesList.removeFirst()
                }
                self.closeDatesList.append(Double(close) ?? 0.0)
                self.datesList.append(TimeInterval(time))
                counter = 0
            }
            var dataEntries: [ChartDataEntry] = []
            for i in 0..<self.closeDatesList.count {
                let dataEntry = ChartDataEntry(x: self.datesList[i], y: self.closeDatesList[i])
                dataEntries.append(dataEntry)
            }
            
            let lineChartDataSet = LineChartDataSet(values: dataEntries, label: "")
            let gradientColors = [UIColor.white.cgColor, UIColor.clear.cgColor]
            let colorLocations:[CGFloat] = [0.5, 0.0]
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors as CFArray, locations: colorLocations)
            lineChartDataSet.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0)
            lineChartDataSet.drawFilledEnabled = true
            lineChartDataSet.lineWidth = 0.0
            lineChartDataSet.drawValuesEnabled = false
            lineChartDataSet.drawCirclesEnabled = false
            lineChartDataSet.drawVerticalHighlightIndicatorEnabled = false
            lineChartDataSet.drawHorizontalHighlightIndicatorEnabled = false
            
            let lineChartData = LineChartData(dataSet: lineChartDataSet)
            self.chartView.data = lineChartData
            
            guard var assets = self.assetDataSource?.items else { return }
            let date = Date.init(timeIntervalSince1970: TimeInterval(time)).stringWithFormat("hh:mm:ss")
            var direction = "call"
            if let lastAssetValue = assets.first?.value, let compareClose = Double(close), let value = Double(lastAssetValue) {
                direction = value < compareClose ? "call" : "put"
            }
            assets.insert(AssetPoint(direction: direction, value: close, time: date), at: 0)
            self.assetDataSource?.items = assets
        })
    }
    
    //MARK: SearchHandler
    
    func searchTextChanged(sender: UITextField) {
        if let text = sender.text {
            if text.isEmpty {
                currencyDataSource?.items = currencyList
            } else {
                var _currencyList = [CurrencyWrapper]()
                for currencyWrapper in currencyList {
                    let assets = currencyWrapper.asset.filter{ $0.name.lowercased().range(of: text, options: .caseInsensitive, range: nil, locale: nil) != nil }
                    _currencyList.append(CurrencyWrapper(title: (assets.first?.group ?? "") , asset: assets))
                }
                currencyDataSource?.items = _currencyList
            }
        }
    }
}

extension TrendViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let translation = panGestureRecognizer.translation(in: panGestureRecognizer.view)
        return abs(translation.y) > abs(translation.x)
    }
}
