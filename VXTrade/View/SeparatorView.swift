//
//  SeparatorView.swift
//  BinarySwipe
//
//  Created by Macostik on 5/25/16.
//  Copyright © 2016 EasternPeak. All rights reserved.
//

import Foundation
import UIKit

class SeparatorView: UIView {
    
    convenience init(color: UIColor, contentMode: UIViewContentMode = .bottom) {
        self.init()
        backgroundColor = UIColor.clear
        self.contentMode = contentMode
        self.color = color
    }
    
    @IBInspectable var color: UIColor?
    
    override func draw(_ rect: CGRect) {
        if let color = color {
            let path = UIBezierPath()
            switch contentMode {
            case .top:
                path.move(0 ^ 0).line(frame.width ^ 0)
            case .left:
                path.move(0 ^ 0).line(0 ^ frame.height)
            case .right:
                path.move(frame.width ^ 0).line(frame.width ^ frame.height)
            default:
                path.move(0 ^ frame.height).line(frame.width ^ frame.height)
            }
            color.setStroke()
            path.lineWidth = 1.0 / max(2, UIScreen.main.scale)
            path.stroke()
        }
    }
}
