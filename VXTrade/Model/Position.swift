//
//  Position.swift
//  VXTrade
//
//  Created by Yuriy on 1/19/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class Position: Object {
    
    dynamic var id = 0
    dynamic var ruleId = 0
    dynamic var refPayoutId = 0
    dynamic var payout = 0.0
    dynamic var expiryDate = 0.0
    dynamic var marketExpiryRate = 0.0
    dynamic var assetId = 0
    dynamic var baseCurrencyInvestment = 0.0
    dynamic var investment = 0.0
    dynamic var pricedEntryRate = 0.0
    dynamic var marketEntryRate = 0.0
    dynamic var direction = ""
    dynamic var status = ""
    dynamic var discriminator = ""

    dynamic var graphData: GraphData?
    dynamic var expiry = 0.0
    
    var isOpen = false
    
    static let notifier = BlockNotifier<Position>()
    
    @discardableResult static func setupPosition<T: Position>(json: JSON, duration: Double = 30.0) -> [T] {
        var positions = [T]()
        
        let realm = try! Realm()
        
        try! realm.write {
            if let positionsList = json.array {
                for  position in positionsList {
                    let position = realm.create(T.self, value: position.object, update: true)
                    position.expiry = duration
                    positions.append(position)
                }
            } else {
                let position = realm.create(T.self, value: json.object, update: true)
                position.expiry = duration
                positions.append(position)
            }
        }
        
        return positions
    }
    
    func getSocketData() {
        
    }
    
    func delete() {
        let realm = try! Realm()
        try! realm.write {
            if let graphData = self.graphData {
                realm.delete(graphData) 
            }
            realm.delete(self)
        }
    }
    
    func prepareDelete() {
          Position.notifier.notify(self)
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func addGraphPoint(_ close:[Double], date: [TimeInterval]) {
        guard let rule = getRealmEntry(type(of: self) , by: self.id), date.count == close.count else { return }
        
        let realm = try! Realm()
        try! realm.write {
            rule.graphData = GraphData.setupGraphData(close: close, date: date)
            realm.add(rule, update: true)
        }
    }
    
    func payoutValue() -> String {
        let payoutID = self.refPayoutId
        let payout = getRealmEntry(Payout.self, by: payoutID)
        let investment = Float(self.baseCurrencyInvestment)
        let profit = Float(payout?.profit ?? 1)
        let payoutValue = (profit * investment)/100 + investment
        return 3 << payoutValue.toString()
    }
    
    func assetName() -> String {
        let asset = getRealmEntry(Asset.self, by: self.assetId)
        return asset?.name ?? ""
    }
}

class Asset : Object {
    
    dynamic var id = 0
    dynamic var name = ""
    dynamic var status = ""
    dynamic var group = ""
    dynamic var precision = 0
    var tradingPeriods = RealmSwift.List<TradingPeriod>()
    
    func getRegularRule() -> RegularRule? {
        let rules: [RegularRule] = RegularRule().entries()
        let rule = rules.filter( { $0.asset?.id == id } ).first
        return rule
    }
    
    func getTrendRule() -> TrendRule? {
        let rules: [TrendRule] = TrendRule().entries()
        let rule = rules.filter( { $0.asset?.id == id } ).first
        return rule
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class TradingPeriod: Object {
    
    dynamic var id = 0
    dynamic var startTime = ""
    dynamic var duration = 0
//    var days = RealmSwift.List<Day>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class Rollover: Object {
    dynamic var id = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class Day: Object {
    dynamic var id = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class GroupPayouts: Object {
    dynamic var groupId = 0
    var payouts = RealmSwift.List<Payout>()
    
    override static func primaryKey() -> String? {
        return "groupId"
    }
}

class Payout: Object {
    dynamic var id = 0
    dynamic var profit = 0
    dynamic var loss = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class OpenPosition: Position {}
class ExpirePosition: Position {}
class TemporaryRegularPosition: Position {}
class TemporaryTrendPosition: Position {}

class GraphData: Object {
    dynamic var id = 0
    dynamic var close = ""
    dynamic var date = ""
    
    @discardableResult static func setupGraphData(close: [Double], date: [TimeInterval]) -> GraphData  {
        
        let id = Date().hashValue
        let _close = close.map{"\($0)"}.joined(separator: " ")
        let _date = date.map{"\($0)"}.joined(separator:" ")
        let grapData = GraphData(value: ["id": id, "close" : _close, "date" : _date] )
        
        return grapData
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
