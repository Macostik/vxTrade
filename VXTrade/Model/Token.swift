//
//  Token.swift
//  VXTrade
//
//  Created by Yuriy on 1/18/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

class CustomToken: Object {
        
    dynamic var id = 0
    dynamic var token = ""
    dynamic var tokenExpiry = 0
    dynamic var groupId = 0
    dynamic var lastActivity = 0
    dynamic var riskFreeCredit = 0
    dynamic var balance = 0.0
    
    static func setupToken(json: JSON) {
        let realm = try! Realm()
        try! realm.write {
            realm.create(CustomToken.self, value: json.object, update: true)
        }
    }
    
    static func setupCustomToken() {
        let tokenData: Dictionary = ["id"               : "1",
                                     "token"            : "b18f5c18-6c27-4489-a1b8-04ec5840b0ca",
                                     "tokenExpiry"      : "",
                                     "groupId"          : "1",
                                     "lastActivity"     : "",
                                     "riskFreeCredit"   : "",
                                     "balance"          : "2342.57"]
        let token = CustomToken(value:  tokenData)
        let realm = try! Realm()
        try! realm.write {
            realm.add(token, update: true)
        }
    }
    
    static var currentToken: CustomToken? = {
        let realm = try! Realm()
        guard let token = realm.objects(CustomToken.self).first else { return nil }
        return token
    }()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}


class ProftitToken: Object {
    
    dynamic var id = 0
    dynamic var firstName = ""
    dynamic var lastName = ""
    dynamic var email = ""
    dynamic var brandId = 0
    dynamic var countryId = 0
    dynamic var token = ""
    dynamic var tokenExpirationTime = ""
    dynamic var owner: User? = nil
    
    @discardableResult static func setupToken(json: JSON) {
        let realm = try! Realm()
        try! realm.write {
            let proftitToken = realm.create(ProftitToken.self, value: json.object, update: true)
            proftitToken.owner = User.currentUser
        }
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func proftitToken() -> ProftitToken? {
        let realm = try! Realm()
        return realm.objects(ProftitToken.self).first
    }
}
