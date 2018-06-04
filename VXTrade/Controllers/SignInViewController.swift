//
//  SignInViewController.swift
//  VXTrade
//
//  Created by Yuriy on 12/23/16.
//  Copyright © 2016 VXmarkets. All rights reserved.
//

import UIKit

class SignInViewController: BaseViewController {
    
    @IBOutlet var validationViews: [ValidationView]!
    @IBOutlet var singInButton: Button!
    var loginToken = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loginEntry = LoginEntryParams(entryParameters: (baseURL: (MainURL.proftit.description, nil),
                                                            headerParameters: nil,
                                                            bodyParameters: (nil, ["username":"adminSuper9","password":"adminSuper9"])))
        
        UserRequest.createUser(loginEntry) { [weak self] json, success in
            guard success == true, let json = json, let loginToken = json["jwt"].string else { return }
            self?.loginToken = loginToken
        }
        let countryEntry = CountryEntryParam(entryParameters: (baseURL: (MainURL.proftit.description, nil),
                                                               headerParameters: nil,
                                                               bodyParameters: nil))
        UserRequest.getCountries(countryEntry, completion: { json, success in
            guard success == true, let json = json else { return }
            Country.setupCountries(json: json)
        })
    }
    
    @IBAction func keepSignInClick(_ sender: Button) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func signInClick(_ sender: Button) {
        guard let email = validationViews.first?.textField.text,
            let password = validationViews.last?.textField.text,
            email.isEmpty == false && password.isEmpty == false else { return }
        
        sender.loading = true
        
        
        
        let proftitToken = ProftitTokenEntryParams(entryParameters: (baseURL: (MainURL.proftit.description, nil),
                                                                     headerParameters: nil,
                                                                     bodyParameters: (nil,  ["email": email, "password" : password,  "brandId" : "6"])))
        UserRequest.getProftitToken(proftitToken) { [weak self] json, success in
            sender.loading = false
            guard success == true, let json = json,
                let _ = try? User.setupUser(json: json),
                let loginToken = self?.loginToken else { return }
            ProftitToken.setupToken(json: json)
            let cusotomerID = json["id"].stringValue
            let tradingAccountEntry = TrandingAccountEntryParam(entryParameters: (baseURL: (MainURL.proftit.description, cusotomerID),
                                                                                  headerParameters: ["Authorization": loginToken],
                                                                                  bodyParameters: nil))
            
            UserRequest.getTradingAccount(tradingAccountEntry) { json, success in
                guard success == true, let json = json?.arrayValue.first else { return }
                if json["platform"]["code"].stringValue == "BNR" {
                    let syncRemoteID = json["syncRemoteId"].intValue.toString()
                    User.setLoginToken(loginToken, syncRemoteID: syncRemoteID)
                    UINavigationController.main.viewControllers = [UIStoryboard.main["container"]!]
                }
            }
        }
    }
    
    
    //MARK: UITextFieldDelegate
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let _ = validationViews.filter { $0.tag < textField.tag }.map { $0.checkValidatationField() }
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        guard let validationView = self.validationViews.filter({ $0.tag == textField.tag + 1 }).first else  {
            validationViews.last?.checkValidatationField()
            return true
        }
        validationView.textField.becomeFirstResponder()
        return true
    }
    
    @IBAction func editTextField(sender: TextField) {
        sender.textColor = UIColor.white
    }
    
    
    @IBAction func signUpClick(_ sender: Any) {
        UINavigationController.main.pushViewController(Storyboard.SignUp.instantiate(), animated: true);
    }
    
    //MARK: KeyboardHandler
    
    override func keyboardAdjustmentConstant(_ adjustment: KeyboardAdjustment, keyboard: Keyboard) -> CGFloat {
        return adjustment.defaultConstant - 10
    }
}
