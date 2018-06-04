//
//  Label.swift
//  BinarySwipe
//
//  Created by Macostik on 5/23/16.
//  Copyright © 2016 EasternPeak. All rights reserved.
//

import Foundation
import UIKit

class Label: UILabel {
    
    convenience init(icon: String, size: CGFloat = UIFont.systemFontSize, textColor: UIColor = UIColor.white) {
        self.init()
        font = UIFont.vxmarket(size)
        text = icon
        self.textColor = textColor
    }

    @IBInspectable var localize: Bool = false {
        willSet {
            if newValue {
                text = text?.ls
                layoutIfNeeded()
            }
        }
    }
    
    @IBInspectable var insets: CGSize = CGSize.zero
    
    override open var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize.init(width: size.width + insets.width, height: size.height + insets.height)
    }
    
    @IBInspectable var rotate: Bool = false {
        willSet {
            if newValue == true {
                switch contentMode {
                case .bottom:
                    transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
                case .left:
                    transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI_2))
                case .right:
                    transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2))
                default:
                    transform = CGAffineTransform.identity
                }
            }
        }
    }
}

final class BadgeLabel: Label {
    
    var value = 0 {
        willSet {
            text = String(newValue)
            isHidden = newValue == -1
            cornerRadius = height/2
            textAlignment = .center
            clipsToBounds = true
        }
    }
    
    override open var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size = CGSize.init(width:size.width + 5, height: size.height + 5)
        layer.cornerRadius = size.height/2
        return size
    }
}
