//
//  SupportViewController.swift
//  VXTrade
//
//  Created by Yuriy on 2/2/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import UIKit
import MessageUI

class SupportViewController: BaseViewController, MFMailComposeViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
   
    
    //MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func writeToSupport(sender: Button) {
        sendMessage()
    }
    
    func sendMessage(body: String? = nil, recipients: [String]? = nil) {
        if MFMailComposeViewController.canSendMail() {
            let mailComposeVC = MFMailComposeViewController()
            mailComposeVC.mailComposeDelegate = self
            mailComposeVC.setToRecipients(recipients)
            mailComposeVC.setMessageBody(body ?? "", isHTML: false)
            UINavigationController.main.present(mailComposeVC, animated: true, completion: nil)
        }
    }

}
