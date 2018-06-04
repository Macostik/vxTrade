//
//  ScrollView+Ext.swift
//  BinarySwipe
//
//  Created by Yuriy on 8/16/16.
//  Copyright © 2016 EasternPeak. All rights reserved.
//

import Foundation
import UIKit

extension UIScrollView {
    func setMinimumContentOffsetAnimated(_ animated: Bool) {
        setContentOffset(minimumContentOffset, animated: animated)
    }
    func setMaximumContentOffsetAnimated(_ animated: Bool) {
        setContentOffset(maximumContentOffset, animated: animated)
    }
    
    var minimumContentOffset: CGPoint {
        let insets = contentInset
        return CGPoint(x: -insets.left, y: -insets.top)
    }
    
    var maximumContentOffset: CGPoint {
        let insets = contentInset
        let width = contentSize.width - (frame.width - insets.right)
        let height = contentSize.height - (frame.height - insets.bottom)
        let x = (width > -insets.left) ? width : -insets.left
        let y = (height > -insets.top) ? height : -insets.top
        return CGPoint(x: round(x), y: round(y))
    }
    
    func isPossibleContentOffset(_ offset: CGPoint) -> Bool {
        let min = minimumContentOffset
        let max = maximumContentOffset
        return offset.x >= min.x && offset.x <= max.x && offset.y >= min.y && offset.y <= max.y
    }
    
    func trySetContentOffset(_ offset: CGPoint) {
        if isPossibleContentOffset(offset) {
            contentOffset = offset
        }
    }
    
    func trySetContentOffset(_ offset: CGPoint, animated: Bool) {
        if isPossibleContentOffset(offset) {
            setContentOffset(offset, animated: animated)
        }
    }
    
    var scrollable: Bool {
        return (contentSize.width > fittingContentWidth) || (contentSize.height > fittingContentHeight)
    }
    
    var verticalContentInsets: CGFloat {
        return contentInset.top + contentInset.bottom
    }
    
    var horizontalContentInsets: CGFloat {
        return contentInset.left + contentInset.right
    }
    
    var fittingContentSize: CGSize {
        return CGSize(width: fittingContentWidth, height: fittingContentHeight)
    }
    
    var fittingContentWidth: CGFloat {
        return frame.width - horizontalContentInsets
    }
    
    var fittingContentHeight: CGFloat {
        return frame.height - verticalContentInsets
    }
    
    func visibleRectOfRect(_ rect: CGRect) -> CGRect {
        return visibleRectOfRect(rect, offset:contentOffset)
    }
    
    func visibleRectOfRect(_ rect: CGRect, offset: CGPoint) -> CGRect {
        return CGRect(origin: offset, size: bounds.size).intersection(rect)
    }
    
    func keepContentOffset(_ block: () -> ()) {
        let height = self.height
        let offset = self.contentOffset.y
        block()
        self.contentOffset.y = smoothstep(self.minimumContentOffset.y, self.maximumContentOffset.y, offset + (height - self.height))
    }
}
