//
//  ContainerViewController.swift
//  VXTrade
//
//  Created by Yuriy on 12/27/16.
//  Copyright © 2016 VXmarkets. All rights reserved.
//

import UIKit

//struct MenuRepresentable: ExpressibleByStringLiteral, ExpressibleByDictionaryLiteral {
//    var _string: String
//    var _dictionary: Dictionary<String, Any>
//    
//    init(stringLiteral value: MenuRepresentable.StringLiteralType) {
//        self._string = value
//    }
//    
//    init(unicodeScalarLiteral value: MenuRepresentable.UnicodeScalarLiteralType)  {
//        self._string = value
//    }
//    
//    init(extendedGraphemeClusterLiteral value: MenuRepresentable.ExtendedGraphemeClusterLiteralType) {
//        self._string = value
//    }
//    
//    init(dictionaryLiteral elements: (MenuRepresentable.Key, Self.Value)...) {
//        self._dictionary = elements
//    }
//    
//}

protocol MenuDelegate: class {
    func menu(_ menu: Menu, didToggle isShow: Bool, animated: Bool)
    func menu(_ menu: Menu, didPresenting viewController: UIViewController)
}

enum MenuOptions: String {
    case profile, transactions, support, logout
}

class ContainerViewController: BaseViewController, MenuDelegate {
    
    @IBOutlet weak var menuContainerView: Menu!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var showingMenu = false
    
    func mainViewController () -> MainViewController? {
        guard let mainViewController = self.childViewControllers.first as? MainViewController else { return nil }
        return mainViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuContainerView.setup()
        menuContainerView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showMenu(showingMenu, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        menuContainerView.layer.anchorPoint = CGPoint(x: 1.0, y: 0.5)
    }
    
    func showMenu(_ show: Bool, animated: Bool) {
        DispatchQueue.main.async {
            let xOffset = self.menuContainerView.bounds.width
            self.scrollView.setContentOffset(show ? CGPoint.zero : CGPoint(x: xOffset, y: 0), animated: animated)
            self.showingMenu = show
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let multiplier = 1.0 / menuContainerView.bounds.width
        let offset = scrollView.contentOffset.x * multiplier
        let fraction = 1.0 - offset
        menuContainerView.layer.transform = transformForFraction(fraction)
        menuContainerView.alpha = fraction
        
        scrollView.isPagingEnabled = scrollView.contentOffset.x < (scrollView.contentSize.width - scrollView.frame.width)
        
        let menuOffset = menuContainerView.bounds.width
        showingMenu = !CGPoint(x: menuOffset, y: 0).equalTo(scrollView.contentOffset)
    }
    
    func transformForFraction(_ fraction:CGFloat) -> CATransform3D {
        var identity = CATransform3DIdentity
        identity.m34 = -1.0 / 1000.0;
        let angle = Double(1.0 - fraction) * -M_PI_2
        let xOffset = menuContainerView.bounds.width * 0.5
        let rotateTransform = CATransform3DRotate(identity, CGFloat(angle), 0.0, 1.0, 0.0)
        let translateTransform = CATransform3DMakeTranslation(xOffset, 0.0, 0.0)
        return CATransform3DConcat(rotateTransform, translateTransform)
    }
    
    //MARK: MenuDelegate 
    func menu(_ menu: Menu, didToggle isShow: Bool, animated: Bool) {
        showMenu(isShow, animated: animated)
    }
 
    
    func menu(_ menu: Menu, didPresenting viewController: UIViewController) {
        guard let mainViewController = mainViewController(),
            let headerContainer = mainViewController.headerContainer else { return }
        showMenu(false, animated: true)
        viewController.embededViewController(to: headerContainer, parent: mainViewController)
    }
}

class Menu: UIView, StreamViewDataSource, MultiMenuCellDelegate {
    
    @IBOutlet var streamView: StreamView?
    private lazy var openedRows = [StreamPosition]()
    var entries = [MenuOptions.profile.rawValue ,
                   MenuOptions.transactions.rawValue,
                   MenuOptions.support.rawValue,
                   MenuOptions.logout.rawValue]
    var dataSource: StreamDataSource<[String]>?
    private var menuMetrics: StreamMetrics<SingleMenuCell>!
    private var multipleMetrics: StreamMetrics<MultiMenuCell>!
    
    weak var delegate: MenuDelegate?
    
    func setup() {
        streamView?.dataSource = self
        let profileVC = Storyboard.ProfileHeader.instantiate()
        let supportVC = Storyboard.SupportHeader.instantiate()
        let logoutVC = Storyboard.LogoutHeader.instantiate()
        menuMetrics = specify(StreamMetrics<SingleMenuCell>(), {
            $0.modifyItem = { item in
                item.size = 70.0
            }
            $0.selection = { [weak self] view in
                guard let `self` = self else { return }
                var viewController = UIViewController()
                if view.entry == MenuOptions.profile.rawValue {
                    viewController = profileVC
                } else if view.entry == MenuOptions.support.rawValue {
                    viewController = supportVC
                } else if view.entry == MenuOptions.logout.rawValue {
                    viewController = logoutVC
                }
                self.delegate?.menu(self, didPresenting: viewController)
            }
        })
        multipleMetrics = specify(StreamMetrics<MultiMenuCell>(), { [weak self] metrics in
            metrics.modifyItem = { (item) in
                item.size = self?.openedPosition(position: item.position) != nil ? 180 : 70
            }
            metrics.finalizeAppearing = { item, view in
                view.delegate = self
                view.opened = !view.opened
            }
        })

        streamView?.reload()
    }
    
    func openedPosition(position: StreamPosition) -> StreamPosition? {
        return openedRows[{ $0 == position }]
    }
    
    //MARK: - MultiMenuCellDelegate

    func cell(cell: MultiMenuCell, didToggle viewController: UIViewController?) {
        if let position = cell.item?.position {
            if let index = openedRows.index(where: { $0 == position }) {
                openedRows.remove(at: index)
            } else {
                openedRows.append(position)
            }
            streamView?.reload()
            guard let viewController = viewController else { return }
            self.delegate?.menu(self, didPresenting: viewController)
        }
    }
    
    //MARK: - StreamViewDataSource
    
    func numberOfItemsIn(section: Int) -> Int {
        return entries.count
    }
    
    func entryBlockForItem(item: StreamItem) -> ((StreamItem) -> Any?)? {
        return { [weak self] (item) in
            return self?.entries[safe: item.position.index]
        }
    }
    
    func metricsAt(position: StreamPosition) -> [StreamMetricsProtocol] {
        return [entries[safe: position.index] == "transactions" ? multipleMetrics : menuMetrics]
    }
}
