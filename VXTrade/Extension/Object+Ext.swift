//
//  Object+Ext.swift
//  VXTrade
//
//  Created by Yuriy on 1/19/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import Foundation
import RealmSwift

func getRealmEntry<T: RealmSwift.Object, U: Hashable>(_ type: T.Type, by id: U) -> T? {
    let realm = try! Realm()
    return realm.objects(type).filter("id = \(id)").first
}

extension Object {
    func entries<T: Object>() -> [T] {
        let realm = try! Realm()
        return realm.objects(T.self).array()
    }
    
   

//    func getEntry<T>() -> T? {
//        let realm = try! Realm()
//        guard let firstEntry = realm.objects(Object.self).first as? T else { return nil }
//        return firstEntry
//    }
}

extension Results {
    typealias T = Results.Generator.Element
    func array() -> [T] {
        return flatMap{ $0 }
    }
}

public extension Sequence {
    func find(predicate: (Iterator.Element) throws -> Bool) rethrows -> Iterator.Element? {
        for element in self {
            if try predicate(element) {
                return element
            }
        }
        return nil
    }
}
