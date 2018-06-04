//
//  AppDelegate.swift
//  VXTrade
//
//  Created by Evgenii Kanivets on 12/21/16.
//  Copyright © 2016 VXmarkets. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let tempRegularPosition: [TemporaryRegularPosition] = TemporaryRegularPosition().entries()
        let tempTrendPosition: [TemporaryTrendPosition] = TemporaryTrendPosition().entries()
        let realm = try! Realm()
        try! realm.write {
            realm.delete(tempRegularPosition)
            realm.delete(tempTrendPosition)
        }
        
        _ = try? setupDataBase()
        
        if User.isAuthorized() {
            UINavigationController.main.viewControllers = [UIStoryboard.main["container"]!]
        } else {
            UIStoryboard.login.present(false)
        }
    
        return true
    }
    
    func setupDataBase() throws {
        let realm = try! Realm()
        if let url = realm.configuration.fileURL {
            Logger.log("FileURL of DataBase - \(url)", color: .Orange)
        } else {
            throw UserError.configDataBase
        }
    }

}

