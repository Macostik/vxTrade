//
//  ShapeView.swift
//  VXTrade
//
//  Created by Yuriy on 1/23/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import Foundation
import UIKit

class ShapeView: UIView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath()
        defineShapePath(path: path, contentMode:contentMode)
        let shape = CAShapeLayer()
        shape.path = path.cgPath
        shape.frame = bounds
        layer.mask = shape
    }
    
    func defineShapePath(path: UIBezierPath, contentMode: UIViewContentMode) { }
}

class TriangleView: ShapeView {
    
    override func defineShapePath(path: UIBezierPath, contentMode: UIViewContentMode) {
        let r = bounds
        switch contentMode {
        case .top:
            path.move(r.minX ^ r.maxY).line(r.maxX ^ r.maxY).line(r.midX ^ r.minY).line(r.minX ^ r.maxY)
        case .left:
            path.move(r.minX ^ r.minY).line(r.minX ^ r.maxY).line(r.maxX ^ r.midY).line(r.minX ^ r.minY)
        case .right:
            path.move(r.maxX ^ r.minY).line(r.minX ^ r.midY).line(r.maxX ^ r.maxY).line(r.maxX ^ r.minY)
        case .bottom:
            path.move(r.minX ^ r.minY).line(r.maxX ^ r.minY).line(r.midX ^ r.maxY).line(r.minX ^ r.minY)
        default:
            path.move(r.minX ^ r.maxY).line(r.maxX ^ r.maxY).line(r.midX ^ r.minY).line(r.minX ^ r.maxY)
        }
    }
}

