//
//  ValidationView.swift
//  VXTrade
//
//  Created by Yuriy on 12/26/16.
//  Copyright © 2016 VXmarkets. All rights reserved.
//

import UIKit

enum Validness {
    case firstName (name: String)
    case lastName (name: String)
    case email (email: String)
    case password (password: String)
    case phone (phone: String)
    case country (country: String)
    
    func isValid() -> Bool {
        switch self {
        case let .firstName(name), let .lastName(name):
            return name.isEmpty == false && name.characters.count > 6
        case let .email(email):
            return email.isEmpty == false && email.isValidEmail
        case let .password(password):
            return password.isEmpty == false && password.characters.count > 5
        case let .phone(phone):
            return phone.isEmpty == false && phone.isValidPhone
        case let .country(country):
            return country.isEmpty == false
        }
    }
}

func isValid(_ views: [ValidationView]) -> Bool {
   return (views.map{ $0.checkValidatationField() }.filter { $0 == false }.count == 0)
}

class ValidationView: UIView {

    @IBOutlet var validationLabel: UILabel!
    @IBOutlet var textField: TextField!
    @IBOutlet var imageLabel: Label!
    @IBOutlet var separatorView: UIView!
    
    @discardableResult func checkValidatationField() -> Bool {
        var isValid = false;
        validationLabel.isHidden = false;
        switch textField.tag {
        case 1:
           isValid = Validness.firstName(name: textField.text ?? "").isValid()
        case 2:
            isValid = Validness.lastName(name: textField.text ?? "").isValid()
        case 3:
            isValid = Validness.email(email: textField.text ?? "").isValid()
        case 4:
            isValid = Validness.password(password: textField.text ?? "").isValid()
        case 5:
            isValid = Validness.phone(phone: textField.text ?? "").isValid()
        case 6:
            isValid = Validness.country(country: textField.text ?? "").isValid()
        default: break
        }
        if isValid  {
            validationLabel.textColor = Color.green
            textField.textColor = UIColor.white
            imageLabel.textColor = UIColor.lightGray
            separatorView.backgroundColor = UIColor.darkGray
        } else {
            validationLabel.textColor = Color.red
            textField.textColor = Color.red
            imageLabel.textColor = Color.red
            separatorView.backgroundColor = Color.red
        }
        
        return isValid
    }
}
