//
//  List.swift
//  VXTrade
//
//  Created by Macostik on 1/9/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import Foundation
import UIKit

class List<T: Equatable> {
    
    var sorter: (_ lhs: T, _ rhs: T) -> Bool = { _ in return true }
    
    convenience init(sorter: @escaping (_ lhs: T, _ rhs: T) -> Bool) {
        self.init()
        self.sorter = sorter
    }
    
    var entries = [T]()
    
    let didChangeNotifier = BlockNotifier<List<T>>()
    
    internal func _add(entry: T) -> Bool {
        if !entries.contains(entry) {
            entries.append(entry)
            return true
        } else {
            return false
        }
    }
    
    func add(entry: T) {
        if _add(entry: entry) {
            sort()
        }
    }
    
    func addEntries<S: Sequence>(entries: S) where S.Iterator.Element == T {
        let count = self.entries.count
        for entry in entries {
            let _ = _add(entry: entry)
        }
        if count != self.entries.count {
            sort()
        }
    }
    
    func sort(entry: T) {
       let _ = _add(entry: entry)
        sort()
    }
    
    func sort() {
        entries = entries.sorted(by: sorter)
        didChange()
    }
    
    func remove(entry: T) {
        if let index = entries.index(of: entry) {
            entries.remove(at: index)
            didChange()
        }
    }
    
    internal func didChange() {
        didChangeNotifier.notify(self)
    }
    
    subscript(index: Int) -> T? {
        return (index >= 0 && index < count) ? entries[index] : nil
    }
}

protocol BaseOrderedContainer {
    associatedtype ElementType
    var count: Int { get }
    subscript (safe index: Int) -> ElementType? { get }
}

extension Array: BaseOrderedContainer {}

extension List: BaseOrderedContainer {
    var count: Int { return entries.count }
    subscript (safe index: Int) -> T? {
        return entries[safe: index]
    }
}
