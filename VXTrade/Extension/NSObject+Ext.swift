//
//  NSObject+Ext.swift
//  BinarySwipe
//
//  Created by Yuriy on 6/8/16.
//  Copyright © 2016 EasternPeak. All rights reserved.
//

import Foundation

func loadFromNib<T>(_ name: String, owner: AnyObject? = nil) -> T? {
    let objects = Bundle.main.loadNibNamed(name, owner: owner, options: nil)
    for object in objects! {
        if let object = object as? T {
            return object
        }
    }
    return nil
}

extension NSObject {
    
    func enqueueSelector(_ selector: Selector, argument: AnyObject? = nil, delay: TimeInterval = 0.5) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: selector, object: argument)
        perform(selector, with: argument, afterDelay: delay)
    }
}
