//
//  GridLayout.swift
//  VXTrade
//
//  Created by Yuriy Granchenko on 1/9/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import Foundation
import UIKit

class GridLayout: StreamLayout {
    
    var numberOfColumns: Int = 1
    var spacing: CGFloat = 0
    var columnSize: CGFloat = 0
    
    var offsets = [CGFloat]()
    
    override func contentSize(item: StreamItem, streamView: StreamView) -> CGSize {
        return CGSize(width: streamView.width, height: offsets.max() ?? 0)
    }
    
    func position(column: Int) -> CGFloat {
        return CGFloat(column) * columnSize
    }
    
    override func prepareLayout(streamView sv: StreamView) {
        offsets = Array(repeating: offset, count: numberOfColumns)
        if columnSize == 0 {
            columnSize = 1/CGFloat(numberOfColumns)
        }
    }
    
    override func frameForItem(item: StreamItem, streamView: StreamView) -> CGRect {
        let ratio = item.ratio
        let offset = offsets.min() ?? 0
        let column = offsets.index(of: offset) ?? 0
        let x = position(column: column) * streamView.frame.width
        let size = columnSize * streamView.frame.width
        
        let spacing_2 = spacing/2.0
        var frame = CGRect.zero
        frame.origin.y = offset
        frame.size.height = size / ratio - spacing
        if (column == 0) {
            frame.origin.x = x + spacing;
            frame.size.width = size - (spacing + spacing_2)
            
        } else if (column == numberOfColumns - 1) {
            frame.origin.x = x + spacing_2
            frame.size.width = size - (spacing + spacing_2)
        } else {
            frame.origin.x = x + spacing_2
            frame.size.width = size - spacing
        }
        offsets[column] = frame.maxY + spacing;
        return frame
    }
    
    func flatten() {
        let offset = offsets.max() ?? 0
        for i in 0..<offsets.count {
            offsets[i] = offset
        }
    }
    
    override func prepareForNextSection() {
        flatten()
    }
}

class HorizontalGridLayout: GridLayout {
    
    override var horizontal: Bool { return true }
    
    override func contentSize(item: StreamItem, streamView: StreamView) -> CGSize {
        return CGSize.init(width: offsets.max() ?? 0, height: streamView.height)
    }
    
    override func frameForItem(item: StreamItem, streamView: StreamView) -> CGRect {
        
        let ratio = item.ratio
        
        let offset = offsets.min() ?? 0
        let column = offsets.index(of: offset) ?? 0
        let y = position(column: column) * streamView.frame.height
        let size = columnSize * streamView.frame.height
        
        let spacing_2 = spacing/2.0
        var frame = CGRect.zero
        frame.origin.x = offset
        frame.size.width = size / ratio - spacing
        if (column == 0) {
            frame.origin.y = y + spacing
            frame.size.height = size - (spacing + spacing_2)
        } else if (column == numberOfColumns - 1) {
            frame.origin.y = y + spacing_2;
            frame.size.height = size - (spacing + spacing_2)
        } else {
            frame.origin.y = y + spacing_2;
            frame.size.height = size - spacing
        }
        offsets[column] = frame.maxX + spacing
        return frame
    }
}
