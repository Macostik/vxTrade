//
//  LogoutViewController.swift
//  VXTrade
//
//  Created by Yuriy on 2/2/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import UIKit

class LogoutViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let token = User.currentUser?.token else { return }
        let logoutEntryParams = LogoutEntryParams(entryParameters: (baseURL: (MainURL.proftit.description, nil),
                                                                    headerParameters: ["Authorization" : "Bearer \(token)"],
                                                                    bodyParameters: nil))
        UserRequest.logoutUser(logoutEntryParams, completion: { _, success in
            if success == true {
                User.currentUser?.deleteUser()
                UINavigationController.main.viewControllers = [Storyboard.SignIn.instantiate()]
            }
        })
    }
}
