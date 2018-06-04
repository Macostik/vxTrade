//
//  EditProfileViewController.swift
//  VXTrade
//
//  Created by Yuriy on 2/6/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import UIKit

class EditProfileViewController: BaseViewController, UIPickerViewDelegate, UIPickerViewDataSource  {
    
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var phoneTextField: UITextField!
    @IBOutlet var countryTextField: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet var pickerViewLayoutPrioritizer: LayoutPrioritizer!
    var countries = [String]()
    var editCompletion: Block? = nil
    
    @IBOutlet var validationViews: [ValidationView]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let user = User.currentUser else { return }
        firstNameTextField.text = user.firstName
        lastNameTextField.text = user.lastName
        emailTextField.text = user.email
        passwordTextField.text = ""
        phoneTextField.text = user.phone
        countryTextField.text = user.country?.name
        
        let countries: [Country] = Country().entries()
        self.countries = countries.flatMap { $0.name }
    }


    @IBAction func saveClick(_ sender: Any) {
        let countries: [Country] = Country().entries()
        guard let loginToken = User.currentUser?.loginToken else { return }
        guard let firstName = firstNameTextField.text,
            let lastName = lastNameTextField.text,
            let email = emailTextField.text, let phone = phoneTextField.text,
            let countryName = countryTextField.text,
            let country = countries.filter({ $0.name == countryName }).first,
            true == isValid(validationViews) else { return }
        let userProfile = UpdateUserProfileEntryParam(entryParameters: (baseURL: (MainURL.proftit.description, nil),
                                                                        headerParameters: ["Authorization" : "\(loginToken)"],
                                                                        bodyParameters: (nil, ["firstName": firstName,
                                                                                               "lastName": lastName,
                                                                                               "email": email,
                                                                                               "phone": phone,
                                                                                               "countryId": country.id])))
        UserRequest.makeUpdateUserProfile(userProfile) { [weak self] json, success in
            guard success == true, let json = json else { return }
            User.updateProfile(json)
            self?.editCompletion?()
        }
    }
    
    //MARK: KeyboardHandler
    
    override func keyboardAdjustmentConstant(_ adjustment: KeyboardAdjustment, keyboard: Keyboard) -> CGFloat {
        return adjustment.defaultConstant
    }

    //MARK: UITextFieldDelegate
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let _ = validationViews.filter { $0.tag < textField.tag }.map { $0.checkValidatationField() }
        if textField.tag != 6 {
            return true
        } else {
            view.endEditing(true)
            pickerViewLayoutPrioritizer.setDefaultState(state: true, animated: true)
            return false
        }
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        guard let validationView = self.validationViews.filter({ $0.tag == textField.tag + 1 }).first else  { return true }
        validationView.textField.becomeFirstResponder()
        return true
    }
    
    @IBAction func editTextField(sender: TextField) {
        sender.textColor = UIColor.white
    }
    
    //MARK: UIPickerViewDelegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent compoent: Int) -> Int {
        return countries.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString.init(string: countries[row], attributes: [NSForegroundColorAttributeName: UIColor.white])
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        countryTextField.text = countries[row]
    }
    
    //MARK: PickerViewHandler
    
    @IBAction func cancelClick(_ sender: Any) {
        countryTextField.text = ""
        pickerViewLayoutPrioritizer.setDefaultState(state: false, animated: true)
        guard let validationView = self.validationViews.filter({ $0.tag == 6 }).first else { return }
        let _ = validationView.checkValidatationField()
    }
    
    @IBAction func doneClick(_ sender: Any) {
        pickerViewLayoutPrioritizer.setDefaultState(state: false, animated: true)
        guard let validationView = self.validationViews.filter({ $0.tag == 6 }).first else { return }
        let _ = validationView.checkValidatationField()
    }
}
