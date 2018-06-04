//
//  MainViewController.swift
//  VXTrade
//
//  Created by Yuriy on 12/27/16.
//  Copyright © 2016 VXmarkets. All rights reserved.
//

import UIKit
import SnapKit
import RealmSwift

enum SegmentTab: Int, CustomStringConvertible {
    case creditCard, wireTransfer, skrill, wireCard
}

enum TabBar: Int, CustomStringConvertible {
    case trade, positions, deposit
}

extension CustomStringConvertible where Self: RawRepresentable {
    var description: String {
        return "\(self.rawValue)"
    }
}

class SegmentControlWrapper: NSObject, SegmentedControlDelegate  {
    
    @IBOutlet var segmentedCotrol: SegmentedControl!
    fileprivate var container = [String: BaseViewController]()
    var embededView: EmbededValue? = nil
    
    func setup(_ viewControllers: [BaseViewController]) {
        guard let segmentedControl = segmentedCotrol else { return }
        segmentedControl.delegate = self
        for (index, value) in viewControllers.enumerated() {
            self.container[SegmentTab(rawValue: index)?.description ?? ""] = value
            value.embededView = embededView
        }
    }
    
    func viewController(_ segmentTab: SegmentTab) -> BaseViewController? {
        return container[segmentTab.rawValue.description]
    }
    
    //MARK: SegmentedControlDelegate
    
    func segmentedControl(_ control: SegmentedControl, didSelectSegment segment: Int) {
        guard let controller = viewController(SegmentTab(rawValue: segment)!) else { return }
        controller.select()
    }
}

class TabBarWrapper: NSObject, SegmentedControlDelegate {
    
    @IBOutlet weak var tabBar: SegmentedControl!

    fileprivate var container = [String: UIViewController]()
    fileprivate var selectedControl: ((UIViewController) -> Void)?
    
    func setup(_ viewControllers: [SegmentedContainerViewController], selectedControl: @escaping ((UIViewController) -> Void)) {
        
        for (index, value) in viewControllers.enumerated() {
            self.container[TabBar.init(rawValue: index)?.description ?? ""] = value
        }
       
        tabBar?.delegate = self
        self.selectedControl = selectedControl
        guard let controller = viewController(TabBar.init(rawValue: 0)!) else { return }
        selectedControl(controller)
    }
    
    func viewController(_ segmentTab: TabBar) -> UIViewController? {
        switch segmentTab {
        case .trade: return container[TabBar.trade.description]
        case .positions: return container[TabBar.positions.description]
        case .deposit: return container[TabBar.deposit.description]
        }
    }
    
    //MARK: SegmentedControlDelegate
    
    func segmentedControl(_ control: SegmentedControl, didSelectSegment segment: Int) {
        guard let controller = viewController(TabBar(rawValue: segment)!) else { return }
        selectedControl?(controller)
    }
}

class MainViewController: BaseViewController {

    @IBOutlet var tabBarWrapper: TabBarWrapper?
    @IBOutlet var headerContainer: UIView?
    @IBOutlet weak var containerView: UIView?
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        NotificationConfirmView().showInView(view)
        
        tabBarWrapper?.setup([Storyboard.TradeHeader.instantiate(), Storyboard.PositionsHeader.instantiate(), Storyboard.DepositHeader.instantiate()],
                             selectedControl: { [weak self] viewController in
                                guard let weakSelf = self else { return }
                                viewController.embededViewController(to: self?.headerContainer ?? UIView(), parent: weakSelf)
        })
    }
    
    @IBAction func menuClick(_ sender: AnyObject) {
        guard let containerViewController = UINavigationController.main.topViewController as? ContainerViewController else { return }
        containerViewController.showMenu(!containerViewController.showingMenu, animated: true)
    }
}


class SegmentedContainerViewController: MainViewController {
    @IBOutlet var segmentControllWrapper: SegmentControlWrapper?
    @IBOutlet var balanceLabel: UILabel?
    var notificationToken: NotificationToken? = nil

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let realm = try! Realm()
        let results = realm.objects(CustomToken.self)
        
        notificationToken = results.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            switch changes {
            case .initial, .update:
                if let customToken: CustomToken = CustomToken().entries().first {
                    self?.balanceLabel?.text = customToken.balance.toString()
                }
                break
            default: break
            }
        }
        
        var segment = self.segmentControllWrapper?.segmentedCotrol.selectedSegment
        if segment == NSNotFound {
            segment = 0
        }
        if let control = self.segmentControllWrapper?.segmentedCotrol.controlForSegment(segment ?? 0) {
             control.sendActions(for: .touchUpInside)
        }
        if let controller = segmentControllWrapper?.viewController(SegmentTab(rawValue: segment ?? 0)!) {
              controller.select()
        }
    }
}

extension SegmentedContainerViewController {
    override func embededViewController(to containerView: UIView, parent: UIViewController) {
        if let mainVC = parent as? MainViewController, let segment = segmentControllWrapper {
            segment.embededView = (mainVC.containerView, mainVC)
        }
        super.embededViewController(to: containerView, parent: parent)
    }
}


class TradeHeaderViewController: SegmentedContainerViewController {
    @IBOutlet var badgeLabel: BadgeLabel?
    let regularVC = Storyboard.Regular.instantiate()
    let trandVC = Storyboard.Trand.instantiate()
    
    override func viewDidLoad() {
        badgeLabel?.value = 0
        segmentControllWrapper?.setup([regularVC, trandVC])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let updateBadgeHandler: Block = { [weak self] _ in
            Dispatch.mainQueue.async {
                let regularPosition: [TemporaryRegularPosition] = TemporaryRegularPosition().entries()
                let trendPosition: [TemporaryTrendPosition] = TemporaryTrendPosition().entries()
                self?.badgeLabel?.value = regularPosition.count + trendPosition.count
            }
        }
        let updatePositionBlock: BooleanBlock = { [weak self] show in
            guard let mainVC = self?.segmentControllWrapper?.embededView?.controller as? MainViewController,
                let tabBar = mainVC.tabBarWrapper?.tabBar else { return }
            UIView.animate(withDuration: 1.0, animations: {
                tabBar.y = show ? mainVC.view.height - tabBar.height : mainVC.view.height 
            })
        }
        regularVC.updateBadgeHandler  = updateBadgeHandler
        trandVC.updateBadgeHandler    = updateBadgeHandler
        regularVC.updatePositionBlock = updatePositionBlock
        trandVC.updatePositionBlock   = updatePositionBlock
    }
    
    
    @IBAction func showPosition(sender: AnyObject) {
        if badgeLabel?.isHidden == false {
            if let control = segmentControllWrapper?.segmentedCotrol.controlForSegment(1) {
                control.sendActions(for: .touchUpInside)
                trandVC.movingViewState = .Middle
            }
        }
    }
}

class PositionsHeaderViewController: SegmentedContainerViewController {
    @IBOutlet var calendar: Button!
    let positionOpenVC = Storyboard.PositionsOpen.instantiate()
    let positionExpireVC = Storyboard.PositionsExpire.instantiate()
    
    override func viewDidLoad() {
        segmentControllWrapper?.setup([positionOpenVC, positionExpireVC])
        positionOpenVC.calendar = calendar
        positionExpireVC.calendar = calendar
    }
    
    @IBAction func calendarClick(sender: Button) {
        positionOpenVC.dateShow = true
        positionExpireVC.dateShow = true
    }
}

class DepositHeaderViewController: SegmentedContainerViewController {
        
        override func viewDidLoad() {
            
            segmentControllWrapper?.setup([
                Storyboard.CreditCard.instantiate(),
                Storyboard.WireTransfer.instantiate(),
                Storyboard.Skrill.instantiate(),
                Storyboard.WireCard.instantiate()])
        }
}

class HistoryHeaderViewController: SegmentedContainerViewController {
    
    override func viewDidLoad() {
        
        segmentControllWrapper?.setup([
            Storyboard.DepositList.instantiate(),
            Storyboard.WithdarawalList.instantiate()
            ])
    }
}

class TransactionsHeaderViewController: SegmentedContainerViewController {
    
    override func viewDidLoad() {
        
        segmentControllWrapper?.setup([])
    }
}

class WithdrawalHeaderViewController: SegmentedContainerViewController {
    
    override func viewDidLoad() {
        
        segmentControllWrapper?.setup([
            Storyboard.CreditCard.instantiate(),
            Storyboard.Withdrawal.instantiate()])
    }
}

class ProfileHeaderViewController: SegmentedContainerViewController {
    
    override func viewDidLoad() {
        
       guard let segmentControllWrapper = segmentControllWrapper else { return }
        let editProfile = Storyboard.EditProfile.instantiate()
        editProfile.editCompletion = { [weak self] in
            if let control = self?.segmentControllWrapper?.segmentedCotrol.controlForSegment(0) {
                control.sendActions(for: .touchUpInside)
            }
        }
        segmentControllWrapper.setup([
            Storyboard.Profile.instantiate(),
            editProfile])
    }
    
}

class SupportHeaderViewController: SegmentedContainerViewController {
    
    override func viewDidLoad() {
        
        segmentControllWrapper?.setup([
            Storyboard.Support.instantiate()])
    }
}

class LogoutHeaderViewController: SegmentedContainerViewController {
    
    override func viewDidLoad() {
        
        segmentControllWrapper?.setup([
            Storyboard.Logout.instantiate()])
    }
}
