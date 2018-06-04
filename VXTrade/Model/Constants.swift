//
//  Constants.swift
//  BinarySwipe
//
//  Created by Macostik on 5/23/16.
//  Copyright © 2016 EasternPeak. All rights reserved.
//

import Foundation
import UIKit
import Hiro

struct Constants {
    static let pixelSize: CGFloat = 1.0
    static let screenWidth: CGFloat = UIScreen.main.bounds.width
    static let screenHeight: CGFloat = UIScreen.main.bounds.height
    static let isPhone: Bool = UI_USER_INTERFACE_IDIOM() == .phone
    static let amountTitleArray = ["$25", "$50", "$75", "$100", "$200", "$500", "$750", "$1000"]
}

typealias Block = (Void) -> Void
typealias ObjectBlock = (AnyObject?) -> Void
typealias FailureBlock = (NSError?) -> Void
typealias BooleanBlock = (Bool) -> Void

extension URL {
    
    static func documents() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last ?? URL(fileURLWithPath: "")
    }
}

extension CustomStringConvertible {
    var description : String {
        var description = "***** \(type(of: self)) - <\(unsafeBitCast((self as AnyObject), to: Int.self)))>***** \n"
        let selfMirror = Mirror(reflecting: self)
        for child in selfMirror.children {
            if let propertyName = child.label {
                description += "\(propertyName): \(child.value)\n"
            }
        }
        return description
    }
}
