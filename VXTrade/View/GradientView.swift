//
//  GradientView.swift
//  BinarySwipe
//
//  Created by Macostik on 5/23/16.
//  Copyright © 2016 EasternPeak. All rights reserved.
//

import Foundation
import UIKit

class GradientView: UIView {
    
    convenience init(startColor: UIColor, endColor: UIColor? = nil, contentMode: UIViewContentMode = .bottom) {
        self.init(frame: CGRect.zero)
        self.contentMode = contentMode
        self.startColor = startColor
        self.endColor = endColor
        updateColors()
        updateContentMode()
    }
    
    @IBInspectable var startColor: UIColor? {
        didSet { updateColors() }
    }
    
    @IBInspectable var endColor: UIColor? {
        didSet { updateColors() }
    }
    
    @IBInspectable var startLocation: Float = 0 {
        didSet { updateLocations() }
    }
    
    @IBInspectable var endLocation: Float = 1 {
        didSet { updateLocations() }
    }
    
    override class var layerClass : AnyClass {
        return CAGradientLayer.self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        awake()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        awake()
    }
    
    fileprivate func awake() {
        updateColors()
        updateLocations()
        let layer = self.layer as! CAGradientLayer
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    
    fileprivate func updateColors() {
        guard let startColor = startColor else { return }
        let layer = self.layer as! CAGradientLayer
        layer.colors = [startColor.cgColor, (endColor ?? startColor.withAlphaComponent(0)).cgColor]
    }
    
    fileprivate func updateLocations() {
        let layer = self.layer as! CAGradientLayer
        layer.locations = [NSNumber(value: startLocation), NSNumber(value: endLocation)]
    }
    
    fileprivate func updateContentMode() {
        let layer = self.layer as! CAGradientLayer
        switch contentMode {
        case .top:
            layer.startPoint = CGPoint(x: 0.5, y: 0);
            layer.endPoint = CGPoint(x: 0.5, y: 1);
        case .left:
            layer.startPoint = CGPoint(x: 0, y: 0.5);
            layer.endPoint = CGPoint(x: 1, y: 0.5);
        case .right:
            layer.startPoint = CGPoint(x: 1, y: 0.5);
            layer.endPoint = CGPoint(x: 0, y: 0.5);
        default:
            layer.startPoint = CGPoint(x: 0.5, y: 1);
            layer.endPoint = CGPoint(x: 0.5, y: 0);
        }
    }
    
    override var contentMode: UIViewContentMode {
        didSet {
            updateContentMode()
        }
    }
}

