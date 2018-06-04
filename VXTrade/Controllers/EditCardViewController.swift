
//
//  EditCardViewController.swift
//  VXTrade
//
//  Created by Yuriy on 1/10/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import UIKit

class EditCardViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cancelClick(sender: AnyObject) {
        SaveCardConfirmView(resultType: SaveResultType.failure).showInView(view, success: nil, cancel: nil)
    }
    @IBAction func saveClick(sender: AnyObject) {
         SaveCardConfirmView().showInView(view, success: nil, cancel: nil)
    }
}
