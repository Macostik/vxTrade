//
//  UIColor+Ext.swift
//  BinarySwipe
//
//  Created by Yuriy on 6/14/16.
//  Copyright © 2016 EasternPeak. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255
        let green = CGFloat((hex & 0x00FF00) >> 8) / 255
        let blue = CGFloat(hex & 0x0000FF) / 255
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

struct Color {
    static let darkBlue = UIColor(hex: 0x0d1c38)
    static let darkGray = UIColor(hex: 0x414656)
    static let gray = UIColor(hex: 0xbababc)
    static let green = UIColor(hex: 0x6AB439)
    static let caral = UIColor(hex: 0xdf2126)
    static let red = UIColor(hex: 0xD9292B)
}
