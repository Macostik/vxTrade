//
//  CGPoint+Ext.swift
//  BinarySwipe
//
//  Created by Yuriy on 8/16/16.
//  Copyright © 2016 EasternPeak. All rights reserved.
//

import Foundation
import UIKit

extension CGSize {
    
    func fit(_ size: CGSize) -> CGSize {
        let scale = min(width / size.width, height / size.height)
        return CGSize(width: size.width * scale, height: size.height * scale)
    }
    
    func fill(_ size: CGSize) -> CGSize {
        let scale = max(width / size.width, height / size.height)
        return CGSize(width: size.width * scale, height: size.height * scale)
    }
    
    func rectCenteredInSize(_ size: CGSize) -> CGRect {
        return CGRect(origin: CGPoint(x: (size.width - width)/2, y: (size.height - height)/2), size: self)
    }
}

func smoothstep(_ _min: CGFloat = 0, _ _max: CGFloat = 1, _ value: CGFloat) -> CGFloat {
    return max(_min, min(_max, value))
}

extension CGPoint {
    
    func offset(_ x: CGFloat, y: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + x, y: self.y + y)
    }
}
