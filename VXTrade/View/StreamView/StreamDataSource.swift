//
//  StreamDataSource.swift
//  VXTrade
//
//  Created by Yuriy Granchenko on 1/9/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import Foundation
import UIKit

class StreamDataSource<T: BaseOrderedContainer>: NSObject, StreamViewDataSource, UIScrollViewDelegate where T.ElementType: Any {
    
    var streamView: StreamView
    
    var sectionHeaderMetrics = [StreamMetricsProtocol]()
    
    var metrics = [StreamMetricsProtocol]()
    
    var sectionFooterMetrics = [StreamMetricsProtocol]()
    
    deinit {
        if (streamView.delegate as? StreamDataSource) == self {
            streamView.delegate = nil
        }
    }
    
    var items: T? {
        didSet {
            didSetItems()
        }
    }
    
    func didSetItems() {
        reload()
    }
    
    func reload() {
        if streamView.dataSource as? StreamDataSource == self {
            streamView.reload()
        }
    }
    
    @discardableResult func addSectionHeaderMetrics<T: StreamMetricsProtocol>(metrics: T) -> T {
        sectionHeaderMetrics.append(metrics)
        return metrics
    }
    
    @discardableResult func addMetrics<T: StreamMetricsProtocol>(metrics: T) -> T {
        self.metrics.append(metrics)
        return metrics
    }
    
    @discardableResult func addSectionFooterMetrics<T: StreamMetricsProtocol>(metrics: T) -> T {
        sectionFooterMetrics.append(metrics)
        return metrics
    }
    
    required init(streamView: StreamView) {
        self.streamView = streamView
        super.init()
        self.streamView = streamView
        streamView.delegate = self
        streamView.dataSource = self
      
    }
    
    var numberOfItems: Int?
    
    var didLayoutItemBlock: ((StreamItem) -> Void)?
    
    private func entryForItem(item: StreamItem) -> Any? {
        return items?[safe: item.position.index]
    }
    
    func numberOfItemsIn(section: Int) -> Int {
        return numberOfItems ?? items?.count ?? 0
    }
    
    func metricsAt(position: StreamPosition) -> [StreamMetricsProtocol] {
        return metrics
    }
    
    func didLayoutItem(item: StreamItem) {
        didLayoutItemBlock?(item)
    }
    
    func entryBlockForItem(item: StreamItem) -> ((StreamItem) -> Any?)? {
        return { [weak self] item -> Any? in
            return self?.entryForItem(item: item)
        }
    }
    
    func didChangeContentSize(oldContentSize: CGSize) {}
    
    func didLayout() {}
    
    func headerMetricsIn(section: Int) -> [StreamMetricsProtocol] {
        return sectionHeaderMetrics
    }
    
    func footerMetricsIn(section: Int) -> [StreamMetricsProtocol] {
        return sectionFooterMetrics
    }
    
    func numberOfSections() -> Int {
        return 1
    }
    
    var didEndDecelerating: (() -> ())?
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            didEndDecelerating?()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        didEndDecelerating?()
    }
}
