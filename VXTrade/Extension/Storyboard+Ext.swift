//
//  Storyboard+Ext.swift
//  BinarySwipe
//
//  Created by Macostik on 5/23/16.
//  Copyright © 2016 EasternPeak. All rights reserved.
//

import Foundation
import UIKit

func specify<T>(_ object: T, _ specify: (T) -> Void) -> T {
    specify(object)
    return object
}

func specify(_ object: UILabel, fontSize: CGFloat = 13.0, textColor: UIColor = Color.gray, _ specify: ((UILabel) -> Void)? = nil) -> UILabel  {
    object.font = UIFont.systemFont(ofSize: fontSize)
    object.textColor = textColor
    specify?(object)
    return object
}

struct StoryboardObject<T: UIViewController> {
    let identifier: String
    var storyboard: UIStoryboard
    init(_ identifier: String, _ storyboard: UIStoryboard = UIStoryboard.main) {
        self.identifier = identifier
        self.storyboard = storyboard
    }
    func instantiate() -> T {
        return storyboard.instantiateViewController(withIdentifier: identifier) as! T
    }
    func instantiate(_ block: (T) -> Void) -> T {
        let controller = instantiate()
        block(controller)
        return controller
    }
}

extension UIStoryboard {
    
    @nonobjc static let main = UIStoryboard(name: "Main", bundle: nil)
    @nonobjc static let login = UIStoryboard(name: "Login", bundle: nil)
    
    func present(_ animated: Bool) {
        UINavigationController.main.viewControllers = [instantiateInitialViewController()!]
    }
    
    subscript(key: String) -> UIViewController? {
        return instantiateViewController(withIdentifier: key)
    }
}

extension UIWindow {
    @nonobjc static let mainWindow = UIApplication.shared.windows.first ?? UIWindow(frame: UIScreen.main.bounds)
}


extension UINavigationController {
    
    @nonobjc static let main = specify(UINavigationController()) {
        UIWindow.mainWindow.rootViewController = $0
        $0.isNavigationBarHidden = true
    }
    
    open override var shouldAutorotate : Bool {
        return topViewController?.shouldAutorotate ?? super.shouldAutorotate
    }
    
    open override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return topViewController?.supportedInterfaceOrientations ?? super.supportedInterfaceOrientations
    }
}

struct Storyboard {
    static let SignIn = StoryboardObject<SignInViewController>("signin", UIStoryboard.login)
    static let SignUp = StoryboardObject<SignUpViewController>("signup", UIStoryboard.login)
    
    static let Container = StoryboardObject<ContainerViewController>("container")
    static let Main = StoryboardObject<MainViewController>("main")
    
    static let TradeHeader = StoryboardObject<TradeHeaderViewController>("tradeHeader")
    static let PositionsHeader = StoryboardObject<PositionsHeaderViewController>("positionsHeader")
    static let DepositHeader = StoryboardObject<DepositHeaderViewController>("depositHeader")
    static let HistroryHeader = StoryboardObject<HistoryHeaderViewController>("historyHeader")
    static let TransactionsHeader = StoryboardObject<TransactionsHeaderViewController>("transactionsHeader")
    static let WithdrawalHeader = StoryboardObject<WithdrawalHeaderViewController>("withdrawalHeader")
    static let ProfileHeader = StoryboardObject<ProfileHeaderViewController>("profiletHeader")
    static let SupportHeader = StoryboardObject<SupportHeaderViewController>("supportHeader")
    static let LogoutHeader = StoryboardObject<LogoutHeaderViewController>("logoutHeader")
    
    //Trade
    static let Regular = StoryboardObject<RegularViewController>("regular")
    static let Trand = StoryboardObject<TrendViewController>("trend")
    
    //Position
    static let PositionsOpen = StoryboardObject<PositionsOpenViewController>("positionsOpen")
    static let PositionsExpire = StoryboardObject<PositionsExpireViewController>("positionsExpire")
    
    //Deposit
    static let EditCreditCard = StoryboardObject<EditCardViewController>("editCard")
    static let CreditCard = StoryboardObject<CreditCardViewController>("сreditCard")
    static let WireTransfer = StoryboardObject<WireTransferViewController>("wireTransfer")
    static let Skrill = StoryboardObject<SkrillViewController>("skrill")
    static let WireCard = StoryboardObject<WireCardViewController>("wireCard")
    static let ChooseCreditCard = StoryboardObject<ChooseCreditCardViewController>("chooseCreditCard")
    static let Withdrawal = StoryboardObject<WithdrawalViewController>("withdrawal")
    static let Profile = StoryboardObject<ProfileViewController>("profile")
    static let Support = StoryboardObject<SupportViewController>("support")
    static let Logout = StoryboardObject<LogoutViewController>("logout")
    static let DepositList = StoryboardObject<DepositListViewController>("depositList")
    static let WithdarawalList = StoryboardObject<WithdrawalListViewController>("withdrawalList")
    static let EditProfile = StoryboardObject<EditProfileViewController>("editprofile")
}
