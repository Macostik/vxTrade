//
//  CurrencyDataSource.swift
//  VXTrade
//
//  Created by Yuriy on 2/15/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import Foundation

final class CurrencyDataSource: StreamDataSource<[CurrencyWrapper]> {
    
    let headerMetrics = StreamMetrics<CurrencyItemHeader>(size: 40)
    let positionMetrics = StreamMetrics<CurrencyCell<Asset>>(size: 70)
    
    required init(streamView: StreamView) {
        super.init(streamView: streamView)
        headerMetrics.finalizeAppearing = { [weak self] item, view in
            view.title = self?.items?[safe: item.position.section]?.title
        }
    }
    
    override func numberOfSections() -> Int {
        return (items?.count ?? 0)
    }
    
    override func numberOfItemsIn(section: Int) -> Int {
        return (items?[section].asset.count ?? 0)
    }
    
    override func metricsAt(position: StreamPosition) -> [StreamMetricsProtocol] {
        return [positionMetrics]
    }
    
    override func headerMetricsIn(section: Int) -> [StreamMetricsProtocol] {
        return [headerMetrics]
    }
    
    override func entryBlockForItem(item: StreamItem) -> ((StreamItem) -> Any?)? {
        let position = item.position
        return { [weak self] _ in
            return self?.items?[position.section].asset[position.index]
        }
    }
}

struct CurrencyWrapper {
    var title = ""
    var asset = [Asset]()
}
