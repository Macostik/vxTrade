//
//  Rule.swift
//  VXTrade
//
//  Created by Yuriy on 2/14/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class Rule: Object {
    
    dynamic var id = 0
    dynamic var duration = ""
    dynamic var tradingTimeSpan = ""
    dynamic var optionDuration = 0
    dynamic var optionInterval = 0
    dynamic var tradingTime = 0
    dynamic var ruleDuration = 0
    dynamic var status = ""
    dynamic var startTime = ""
    dynamic var type = ""
    dynamic var asset: Asset?
    var groupPayouts = RealmSwift.List<GroupPayouts>()
    
    
    @discardableResult static func setupRule<T: Rule>(json: JSON) -> [T] {
        var ruleList = [T]()
        let format = "HH:mm:ss"
        guard let now = Date().stringWithFormat(format).dateWithFormat(format)?.timeIntervalSince1970, let dayOfWeek = Date().getDayOfWeekForVXMarket() else { return ruleList }
        
        let rules = json.reversed().filter {
                $1["days"].arrayValue.contains(JSON(dayOfWeek)) &&
                $1["asset"]["status"] == "active" &&
                ($1["startTime"].stringValue.dateWithFormat(format)?.timeIntervalSince1970 ?? 0.0) < now &&
                now < (($1["startTime"].stringValue.dateWithFormat(format)?.timeIntervalSince1970 ?? 0.0) + ($1["ruleDuration"].doubleValue * 60)) }

        let realm = try! Realm()
        
        try! realm.write {
            for (_, rule) in rules {
                let rule = realm.create(T.self, value: rule.object, update: true)
                ruleList.append(rule)
            }
        }

        return ruleList
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class RegularRule: Rule {}
class TrendRule: Rule {}
