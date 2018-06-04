//
//  RegularViewController.swift
//  VXTrade
//
//  Created by Yuriy on 2/13/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import UIKit
import Charts

class RegularViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet var chartView: LineChartView!
    @IBOutlet var currencyStreamView: StreamView!
    @IBOutlet var positonsStreamView: StreamView!
    @IBOutlet var currencyLayoutPrioritizer: LayoutPrioritizer!
    @IBOutlet var positionPrioritizer: LayoutPrioritizer!
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
    @IBOutlet var expirePositionLabel: UILabel!
    
    var updateBadgeHandler: Block?
    var updatePositionBlock: BooleanBlock?
    
    private var currencyDataSource: CurrencyDataSource?
    private var positionDataSource: StreamDataSource<[PositionItem]>?
    private var currentRule: RegularRule? = nil
    private let socket = SocketManager()
    private var selectPayout: Payout? = nil
    private var investment: Float = 25
    private var payout = ""
    private let date = Date().stringWithFormat("dd MMM")
    private let popoverView = PopoverView()
    private var timer: Timer? = nil
    
    private var closeDatesList = [Double]()
    private var datesList = [TimeInterval]()
    private var positionItemsList = [PositionItem]()
    
    private let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
    private var currencyList = [CurrencyWrapper]()
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
        chartView.dragEnabled = false
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
            guard let positonItem = item.entry as? PositionItem else { return }
            item.size = positonItem.position.isOpen == true ? 240 : 70
        }
        metrics.selection = { [weak self] view in
            guard let positionItem = view.item?.entry as? PositionItem else { return }
            positionItem.position.isOpen = !positionItem.position.isOpen
            self?.positionDataSource?.reload()
        }
    
        positionDataSource?.addMetrics(metrics: metrics)
        investmentTextField.text = "$\(Int(investment))"
        guard let id = User.currentUser?.syncRemoteID else { return }
        let tokenEntry = CustomTokenEntryParams(entryParameters: (baseURL: (MainURL.base(server: .prod).description, nil),
                                                                  headerParameters: ["x-api-username": "vxmarkets", "x-api-password": "123456"],
                                                                  bodyParameters: (nil, ["CustomerId":id])))
        UserRequest.getCustomToken(tokenEntry, completion: {  json, success in
            guard let json = json, success == true else { return }
            CustomToken.setupToken(json: json)
            let timeStamp = Date().timeIntervalSince1970.toString()
            guard let token = CustomToken.currentToken?.token  else { return }
            let bootEntry = BootEntryParam(entryParameters: (baseURL: (MainURL.base(server: .prod).description, nil),
                                                             headerParameters: ["x-api-token" : "\(token)"],
                                                             bodyParameters: (nil, ["_" : timeStamp])))
            UserRequest.getBoot(bootEntry, completion: { json, success in
                guard success == true, let json = json else { return }
                let boot = Boot.setupBoot(json: json)
                let openRulesEntryParam = OpenRulesEntryParam(entryParameters: (baseURL: (MainURL.base(server: .prod).description, boot.brandLastModified.toString()),
                                                                                headerParameters: ["x-api-token" : "\(token)"],
                                                                                bodyParameters: nil))
                UserRequest.getRegularRules(openRulesEntryParam, completion: { [weak self] json, success in
                    guard let json = json, success == true else { return }
                    let regularRule:[RegularRule] = RegularRule.setupRule(json: json)
                    self?.currentRule = regularRule.last
                    self?.figureOutExprieTime()
                    guard let asset = self?.currentRule?.asset else { return }
                    self?.handleGraph(with: asset)
                })
            })
        })
        
        let cards: [Card] = Card().entries()
        if cards.count == 0 {
            let backgroundQueue = DispatchQueue(label: "com.VXTrade.background", qos: .background)
            backgroundQueue.async {
                guard let token = ProftitToken().proftitToken()?.token  else { return }
                let cardEntryParam = CardEntryParam(entryParameters: (baseURL: (MainURL.proftit.description, nil),
                                                                      headerParameters: ["Authorization" : "Bearer \(token)"],
                                                                      bodyParameters: nil))
                UserRequest.getCreditCads(cardEntryParam, completion: { json, success in
                    guard success == true, let json = json else { return }
                    Card.setupCard(json: json)
                })
            }
        }
        
        currencyDataSource = CurrencyDataSource(streamView: currencyStreamView)
        searchTextField?.addTarget(self, action: #selector(self.searchTextChanged(sender:)), for: .editingChanged)
        currencyDataSource?.positionMetrics.selection = { [weak self] view in
            self?.view.endEditing(true)
            guard let assetID = self?.currentRule?.asset?.id else { return }
            self?.socket.unsibsribeAsset(from: assetID.toString())
            guard let asset = view.item?.entry as? Asset else { return }
            self?.currentRule = asset.getRegularRule()
            self?.handleGraph(with: asset)
            self?.figureOutExprieTime()
        }
        
        Position.notifier.subscribe(self, block: { [weak self] _, position in
            if let deletePositionItem = self?.positionItemsList.first(where: { $0.position == position }) {
                self?.positionItemsList.remove(deletePositionItem)
            }
            self?.positionDataSource?.items = self?.positionItemsList
            self?.updateBadgeHandler?()
            if self?.positionItemsList.count == 0 {
                self?.positionPrioritizer.setDefaultState(state: false, animated: true)
                self?.updatePositionBlock?(true)
            }
        })
        if #available(iOS 10.0, *) {
            timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true, block: { [weak self] _ in
                Dispatch.mainQueue.async {
                     self?.figureOutExprieTime()
                }
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        positionPrioritizer.setDefaultState(state: false, animated: false)
        updatePositionBlock?(true)
    }
    
    func handleGraph(with asset: Asset) {
        guard let token = CustomToken.currentToken?.token,
        let rule = asset.getRegularRule(),
        let payouts = rule.groupPayouts.first?.payouts else { return }
        assetNameLabel.text = asset.name
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
            
            let closesList = dataGraph.map { $0["close"].doubleValue }
            let datesList = dataGraph.map { $0["date"].stringValue.date()?.timeIntervalSince1970 ?? 0.0 }
            self.closeDatesList = closesList
            self.datesList = datesList
            
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
    
    func figureOutExprieTime() {
        let rules:[RegularRule] = RegularRule().entries()
        var timeList = [String]()
        popoverView.contentData = []
        if let assetName = currentRule?.asset?.name {
            let expireTime = Set(rules.filter { ($0.asset?.name ?? "") == assetName })
            for rule in expireTime {
                let startTime = rule.startTime.toString()
                let duration = Double(rule.optionInterval)
                let timeInterval = (startTime.dateWithFormat("hh:mm:ss")?.timeIntervalSince1970 ?? 0.0)
                var time = Date().stringWithFormat("HH:mm")
                let minutes = Date().stringWithFormat("mm")
                let compareMinutes = Date(timeIntervalSince1970: timeInterval).stringWithFormat("mm")
                if duration <= 60 {
                    if minutes > compareMinutes {
                        let hour = (Int(Date().stringWithFormat("HH")) ?? 0) + 1
                        time = "\(hour):" + compareMinutes
                    } else {
                        time = time.substring(to: time.index(time.endIndex, offsetBy: -2)) + compareMinutes
                    }
                } else {
                    time = Date(timeIntervalSince1970: (timeInterval + (duration * 60))).stringWithFormat("HH:mm")
                }
                
                let text = time + ", " + date
                timeList.append(text)
            }
            
            popoverView.contentData = timeList.sorted {$0 < $1}
            expirePositionLabel.text = popoverView.contentData.first
        }
    }
    
    //MARK: Actikons
    
    @IBAction func expireRuleClick(sender: UIView) {
        popoverView.selectedItemBlock = { [weak self] time in
            self?.expirePositionLabel.text = "\(time)"
        }
        popoverView.showInView(view, sourceView: sender)
    }
    
    @IBAction func putTrade(sender: Button) {
        checkBalance(direction:"put")
    }
    
    @IBAction func callTrade(sender: Button) {
        checkBalance(direction:"call")
    }
    
    @IBAction func showCurrency(sender: AnyObject?) {
        let asset: [Asset] = Asset().entries()
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
            positionPrioritizer.setDefaultState(state: !positionPrioritizer.defaultState, animated: true)
            updatePositionBlock?(!positionPrioritizer.defaultState)
        }
    }
    
    @IBAction func investmentClick(sender: Button) {
        investmentTextField.becomeFirstResponder()
    }
    
    //MARK: Keyboard
    
    override func keyboardAdjustmentConstant(_ adjustment: KeyboardAdjustment, keyboard: Keyboard) -> CGFloat {
       return keyboard.height - chartView.height - 10
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
        if textField.text?.isEmpty == false {
            textField.text?.characters.removeFirst()
        }
        guard let _investment = textField.text, let inv = Int(_investment), inv > 25 else {
            investment = 25
            textField.text = "$25"
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
                                          "investment" : "\(Int(investment))",
                                          "payoutId" : payoutID,
                                          "ruleId" : rule.id] )))
                UserRequest.makeCreatingPositions(createPositionEntryParam, completion: { [weak self] json, success in
                    guard let json = json, success == true, let `self` = self else {
                        positionConfirmView.hide()
                        return }
                    newlyPositonID = json["id"].stringValue
                    guard let expirePositionDuration = self.expirePositionLabel.text?.dateWithFormat("HH:mm, dd MMM")?.timeIntervalSince1970,
                        let timeIntervalForNow = Date().stringWithFormat("HH:mm, dd MMM").dateWithFormat("HH:mm, dd MMM")?.timeIntervalSince1970 else { return }
                    let differenInterval = expirePositionDuration - timeIntervalForNow
                    guard let position: TemporaryRegularPosition = TemporaryRegularPosition.setupPosition(json: json, duration: differenInterval).first else { return }
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
                        deletePositionItem.prepareDelete()
                    })
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

class XAxisValueFormatter: NSObject, IAxisValueFormatter {
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return Date.init(timeIntervalSince1970: value).stringWithFormat("HH:mm")
    }
}
