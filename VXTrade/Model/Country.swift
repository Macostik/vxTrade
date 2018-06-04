//
//  Country.swift
//  VXTrade
//
//  Created by Yuriy on 2/6/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class Country: Object {
    
    dynamic var id = 0
    dynamic var name = ""
    dynamic var capital = ""
    dynamic var alpha2Code = ""
    dynamic var alpha3Code = ""
    dynamic var gmtTimezone = 0
    dynamic var numericCode = 0
    dynamic var phoneCode = ""
    dynamic var currencyCode = ""
    dynamic var domain = ""
    dynamic var isHasStates = false
    
    @discardableResult static func setupCountries(json: JSON) -> [Country] {
        var countryList = [Country]()
      
        let realm = try! Realm()
        
        try! realm.write {
            for (_, country) in json {
                let country = realm.create(Country.self, value: country.object, update: true)
                countryList.append(country)
            }
        }
        
        return countryList
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
