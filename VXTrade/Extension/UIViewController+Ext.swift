//
//  UIViewController+Ext.swift
//  VXTrade
//
//  Created by Yuriy on 1/16/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

extension UIViewController {
    
    func embededViewController(to containerView: UIView, parent: UIViewController) {
        containerView.subviews.all({ $0.removeFromSuperview() })
        parent.childViewControllers.all { $0.removeFromParentViewController() }
        parent.addChildViewController(self)
        containerView.add(view) { $0.edges.equalTo(containerView) }
        didMove(toParentViewController: parent)
        view.layoutIfNeeded()
    }
    
    func removeEmbededViewController() {
        willMove(toParentViewController: nil)
        view.removeFromSuperview()
        removeFromParentViewController()
        view.layoutIfNeeded()
    }
    
    func modalPresentation(controller: UIViewController, animated: Bool, completion: (() -> Void)?) {
        controller.modalPresentationStyle = .overCurrentContext
        controller.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.present(controller, animated: animated, completion: completion)
    }
    
    func recursivePresentedViewController() -> UIViewController {
        return presentedViewController?.recursivePresentedViewController() ?? self
    }
    
    var isTopViewController: Bool {
        return navigationController?.topViewController == self
    }
}
