//
//  ProfileViewController.swift
//  VXTrade
//
//  Created by Yuriy on 2/2/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import UIKit
import RealmSwift

class ProfileViewController: BaseViewController {
    @IBOutlet var firstNameLabel: UITextField!
    @IBOutlet var lastNameLabel: UITextField!
    @IBOutlet var emailLabel: UITextField!
    @IBOutlet var phoneLabel: UITextField!
    @IBOutlet var countryLabel: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let loginToken = User.currentUser?.loginToken else { return }
        let userProfile = UserProfileEntryParam(entryParameters: (baseURL: (MainURL.proftit.description, nil),
                                                                  headerParameters: ["Authorization" : "\(loginToken)"],
                                                                  bodyParameters: nil))
        UserRequest.getUserProfile(userProfile) { [weak self] json, success in
            guard success == true, let json = json else { return }
            User.updateProfile(json)
            guard let user = User.currentUser, let `self` = self else { return }
            self.firstNameLabel.text = user.firstName
            self.lastNameLabel.text = user.lastName
            self.emailLabel.text = user.email
            self.phoneLabel.text = user.phone
            self.countryLabel.text = user.country?.name
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let user = User.currentUser else { return }
        firstNameLabel.text = user.firstName
        lastNameLabel.text = user.lastName
        emailLabel.text = user.email
        phoneLabel.text = user.phone
        countryLabel.text = user.country?.name
    }
}


