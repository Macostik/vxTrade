//
//  StreamView.swift
//  VXTrade
//
//  Created by Yuriy Granchenko on 1/9/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import Foundation
import UIKit

enum ScrollDirection {
    case Unknown, Up, Down
}

typealias ScrollDirectionHandler = (_ isUp: Bool) -> ()

var StreamViewCommonLocksChanged: String = "StreamViewCommonLocksChanged"

protocol StreamViewDataSource: class {
    func numberOfSections() -> Int
    func numberOfItemsIn(section: Int) -> Int
    func metricsAt(position: StreamPosition) -> [StreamMetricsProtocol]
    func didLayoutItem(item: StreamItem)
    func entryBlockForItem(item: StreamItem) -> ((StreamItem) -> Any?)?
    func didChangeContentSize(oldContentSize: CGSize)
    func didLayout()
    func headerMetricsIn(section: Int) -> [StreamMetricsProtocol]
    func footerMetricsIn(section: Int) -> [StreamMetricsProtocol]
}

extension StreamViewDataSource {
    func numberOfSections() -> Int { return 1 }
    func didLayoutItem(item: StreamItem) { }
    func entryBlockForItem(item: StreamItem) -> ((StreamItem) -> Any?)? { return nil }
    func didChangeContentSize(oldContentSize: CGSize) { }
    func didLayout() { }
    func headerMetricsIn(section: Int) -> [StreamMetricsProtocol] { return [] }
    func footerMetricsIn(section: Int) -> [StreamMetricsProtocol] { return [] }
}


class StreamViewLayer: CALayer {
    
    var didChangeBounds: (() -> ())?
    
    override var bounds: CGRect {
        didSet {
            didChangeBounds?()
        }
    }
}

final class StreamView: UIScrollView {
    
    override class var layerClass: AnyClass {
        return StreamViewLayer.self
    }
    
    var layout: StreamLayout = StreamLayout()
    
    private var reloadAfterUnlock = false
    
    var locked = false
    
    static var locked = false
    
    private var items = [StreamItem]()
    
    weak var dataSource: StreamViewDataSource?
    
    private weak var placeholderView: PlaceholderView? {
        willSet {
            newValue?.isHidden = isHidden
        }
    }
    
    override var isHidden: Bool {
        didSet {
            placeholderView?.isHidden = isHidden
        }
    }
    
    var placeholderViewBlock: (() -> PlaceholderView)?
    
    override var contentInset: UIEdgeInsets  {
        didSet {
            if oldValue != contentInset && items.count == 1 && layout.finalized {
                reload()
            }
        }
    }
    
    deinit {
        delegate = nil
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: StreamViewCommonLocksChanged), object:nil)
    }
    
    private func setup() {
        (layer as! StreamViewLayer).didChangeBounds = { [unowned self] _ in
            self.didChangeBounds()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(StreamView.locksChanged), name: NSNotification.Name(rawValue: StreamViewCommonLocksChanged), object: nil)
    }
    
    var scrollDirectionChanged: ScrollDirectionHandler = { _ in }
    
    var trackScrollDirection = false
    
    var direction: ScrollDirection = .Unknown {
        didSet {
            if direction != oldValue {
                scrollDirectionChanged(direction == .Up)
            }
        }
    }
    
    func didChangeBounds() {
        if trackScrollDirection && isTracking && (contentSize.height > height || direction == .Up) {
            direction = panGestureRecognizer.translation(in: self).y > 0 ? .Down : .Up
        }
        if layout.finalized {
            updateVisibility()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func clear() {
        placeholderView?.removeFromSuperview()
        for item in items {
            if let view = item.view {
                view.isHidden = true
                item.metrics.enqueueView(view: view)
            }
        }
        items.removeAll()
    }
    
    static func lock() {
        locked = true
    }
    
    static func unlock() {
        if locked {
            locked = false
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: StreamViewCommonLocksChanged), object: nil)
        }
    }
    
    func locksChanged() {
        if !locked && !StreamView.locked && reloadAfterUnlock {
            reloadAfterUnlock = false
            reload()
        }
    }
    
    func lock() {
        locked = true
    }
    
    func unlock() {
        if locked {
            locked = false
            locksChanged()
        }
    }
    
    func reload() {
        
        if locked || StreamView.locked {
            reloadAfterUnlock = true
            return
        }
        
        clear()
        
        layout.prepareLayout(streamView: self)
        
        addItems()
        
        if let item = items.last {
            changeContentSize(newContentSize: layout.contentSize(item: item, streamView: self))
        } else {
            if layout.horizontal {
                changeContentSize(newContentSize: CGSize.init(width: 0, height: height))
            } else {
                changeContentSize(newContentSize: CGSize.init(width: width, height: 0))
            }
        }
        
        layout.finalizeLayout()
        
        _layoutSize = layoutSize(rect: layer.bounds)
        
        dataSource?.didLayout()
        
        updateVisibility()
    }
    
    private func changeContentSize(newContentSize: CGSize) {
        let oldContentSize = contentSize
        if newContentSize != oldContentSize {
            contentSize = newContentSize
            dataSource?.didChangeContentSize(oldContentSize: oldContentSize)
        }
    }
    
    private func addItems() {
        
        guard let dataSource = dataSource else { return }
        let layout = self.layout
        
        for section in 0..<dataSource.numberOfSections() {
            
            let position = StreamPosition(section: section, index: 0)
            for header in dataSource.headerMetricsIn(section: section) {
               _ = addItem(metrics: header, position: position)
            }
            
            for i in 0..<dataSource.numberOfItemsIn(section: section) {
                let position = StreamPosition(section: section, index: i);
                for metrics in dataSource.metricsAt(position: position) {
                    if let item = addItem(dataSource: dataSource, metrics: metrics, position: position) {
                        dataSource.didLayoutItem(item: item)
                    }
                }
            }
            
            for footer in dataSource.footerMetricsIn(section: section) {
                _ = addItem(metrics: footer, position: position)
            }
            
            layout.prepareForNextSection()
        }
        
        if items.isEmpty, let placeholder = placeholderViewBlock {
            let placeholderView = placeholder()
            placeholderView.layoutInStreamView(streamView: self)
            self.placeholderView = placeholderView
        }
    }
    
    private func addItem(dataSource: StreamViewDataSource? = nil, metrics: StreamMetricsProtocol, position: StreamPosition) -> StreamItem? {
        let item = StreamItem(metrics: metrics, position: position)
        item.entryBlock = dataSource?.entryBlockForItem(item: item)
        metrics.modifyItem?(item)
        guard !item.hidden else { return nil }
        if let currentItem = items.last {
            item.previous = currentItem
            currentItem.next = item
        }
        layout.layoutItem(item: item, streamView: self)
        items.append(item)
        return item
    }
    
    private func updateVisibility() {
        updateVisibility(withRect: layer.bounds)
    }
    
    private var _layoutSize: CGFloat = 0
    
    private func layoutSize(rect: CGRect) -> CGFloat {
        return layout.horizontal ? rect.height : rect.width
    }
    
    private func reloadIfNeeded(rect: CGRect) -> Bool {
        let size = layoutSize(rect: rect)
        if abs(_layoutSize - size) >= 1 {
            reload()
            return true
        } else {
            return false
        }
    }
    
    private func updateVisibility(withRect rect: CGRect) {
        guard !reloadIfNeeded(rect: rect) else { return }
        for item in items {
            let visible = item.frame.intersects(rect)
            if item.visible != visible {
                item.visible = visible
                if visible {
                    let view = item.metrics.dequeueViewWithItem(item: item)
                    if view.superview != self {
                        insertSubview(view, at: 0)
                    }
                    view.isHidden = false
                } else if let view = item.view {
                    item.metrics.enqueueView(view: view)
                    view.isHidden = true
                    item.view = nil
                }
            }
        }
    }
    
    // MARK: - User Actions
    
    func visibleItems() -> [StreamItem] {
        return itemsPassingTest { $0.visible }
    }
    
    func selectedItems() -> [StreamItem] {
        return itemsPassingTest { $0.selected }
    }
    
    var selectedItem: StreamItem? {
        return itemPassingTest { $0.selected }
    }
    
    func itemPassingTest(test: (StreamItem) -> Bool) -> StreamItem? {
        for item in items where test(item) {
            return item
        }
        return nil
    }
    
    func itemsPassingTest(test: (StreamItem) -> Bool) -> [StreamItem] {
        return items.filter(test)
    }
    
    func scrollToItemPassingTest( test: (StreamItem) -> Bool, animated: Bool) -> StreamItem? {
        let item = itemPassingTest(test: test)
        scrollToItem(item: item, animated: animated)
        return item
    }
    
    func scrollToItem(item: StreamItem?, animated: Bool)  {
        guard let item = item else { return }
        let minOffset = minimumContentOffset
        let maxOffset = maximumContentOffset
        if layout.horizontal {
            let offset = (item.frame.origin.x - contentInset.right) - fittingContentWidth / 2 + item.frame.size.width / 2
            if offset < minOffset.x {
                setContentOffset(minOffset, animated: animated)
            } else if offset > maxOffset.x {
                setContentOffset(maxOffset, animated: animated)
            } else {
                setContentOffset(CGPoint.init(x: offset, y: 0), animated: animated)
            }
        } else {
            let offset = (item.frame.origin.y - contentInset.top) - fittingContentHeight / 2 + item.frame.size.height / 2
            if offset < minOffset.y {
                setContentOffset(minOffset, animated: animated)
            } else if offset > maxOffset.y {
                setContentOffset(maxOffset, animated: animated)
            } else {
                setContentOffset(CGPoint.init(x: 0, y: offset), animated: animated)
            }
        }
    }
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        return true
    }
}
