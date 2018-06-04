//
//  StreamItem.swift
//  VXTrade
//
//  Created by Yuriy Granchenko on 1/9/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import Foundation
import UIKit

final class StreamItem {
    
    var frame = CGRect.zero
    var visible = false
    let position: StreamPosition
    let metrics: StreamMetricsProtocol
    var entryBlock: ((StreamItem) -> Any?)?
    
    init(metrics: StreamMetricsProtocol, position: StreamPosition) {
        self.metrics = metrics
        self.position = position
        hidden = metrics.hidden
        size = metrics.size
        insets = metrics.insets
        ratio = metrics.ratio
    }
    
    lazy var entry: Any? = self.entryBlock?(self)
    
    weak var view: StreamReusableView? {
        willSet { newValue?.selected = selected }
    }
    
    var selected: Bool = false {
        willSet { view?.selected = newValue }
    }
    
    weak var previous: StreamItem?
    weak var next: StreamItem?
    
    var column: Int = 0
    var hidden: Bool = false
    var size: CGFloat = 0
    var insets: CGRect = CGRect.zero
    var ratio: CGFloat = 0
}

func ==(lhs: StreamPosition, rhs: StreamPosition) -> Bool {
    return lhs.section == rhs.section && lhs.index == rhs.index
}

struct StreamPosition: Equatable {
    let section: Int
    let index: Int
    static let zero = StreamPosition(section: 0, index: 0)
}

