//
//  SignUpViewController.swift
//  VXTrade
//
//  Created by Yuriy on 12/26/16.
//  Copyright © 2016 VXmarkets. All rights reserved.
//

import UIKit

class SignUpViewController: BaseViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet var validationViews: [ValidationView]!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var countryTextField: TextField!
    @IBOutlet weak var containerPickerView: UIView!
    @IBOutlet var pickerViewLayoutPrioritizer: LayoutPrioritizer!
    var countries = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        let countries: [Country] = Country().entries()
        self.countries = countries.flatMap { $0.name }
    }

    @IBAction func agreeTermsClick(_ sender: Button) {
        sender.isSelected = !sender.isSelected
        
    }
    
    @IBAction func signUpClick(_ sender: Any) {
//        UINavigationController.main.pushViewController(Storyboard.Container.instantiate(), animated: true)
    }

    @IBAction func signInClick(_ sender: Any) {
         UINavigationController.main.popViewController(animated: true)
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
    
    //MARK: KeyboardHandler
    
    override func keyboardAdjustmentConstant(_ adjustment: KeyboardAdjustment, keyboard: Keyboard) -> CGFloat {
        return adjustment.defaultConstant 
    }
}



