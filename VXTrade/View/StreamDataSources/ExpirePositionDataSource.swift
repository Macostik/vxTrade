//
//  ExpirePositionDataSource.swift
//  VXTrade
//
//  Created by Yuriy on 2/1/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import Foundation

final class PositionDataSource: StreamDataSource<[PositionWrapper]> {
    
    let headerMetrics = StreamMetrics<PositionItemHeader>(size: 28)
    let positionMetrics = StreamMetrics<PositionCell<Position>>(size: 70)
    
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
        return (items?[section].positions.count ?? 0)
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
            return self?.items?[position.section].positions[position.index]
        }
    }
}

struct PositionWrapper {
    var title = ""
    var positions = [Position]()
}
