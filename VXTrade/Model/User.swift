//
//  User.swift
//  Mandarin
//
//  Created by Macostik on 12/3/16.
//  Copyright © 2016 Oleg. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

var notifierToken: NotificationToken?

enum UserError: Error {
    case createUser (description: String)
    case saveUser
    case writeTransaction
    case configDataBase
}

class User: Object {
    
    dynamic var id = ""
    dynamic var firstName = ""
    dynamic var lastName = ""
    dynamic var isLead = false
    dynamic var phone = ""
    dynamic var email = ""
    dynamic var gender = ""
    dynamic var city = ""
    dynamic var address = ""
    dynamic var token = ""
    dynamic var loginToken = ""
    dynamic var syncRemoteID = ""
    dynamic var tokenExpirationTime = ""
    dynamic var stateId = ""
    dynamic var zipCode = ""
    dynamic var countryId = ""
    dynamic var country: Country? = nil
    dynamic var preferedAmountTrade = Constants.amountTitleArray.first

    override static func primaryKey() -> String? {
        return "id"
    }
    
    deinit {
        notifierToken?.stop()
    }
    
    static let notifier = BlockNotifier<User>()
    
    static func updateProfile(_ json: JSON) {
        guard let user = User.currentUser else { return }
      
        let realm = try! Realm()
        try! realm.write {
            user.firstName = json["firstName"].stringValue
            user.lastName = json["lastName"].stringValue
            user.isLead = json["isLead"].boolValue
            user.email = json["email"].stringValue
            user.phone = json["phone"].stringValue
            if let country = json["country"].dictionary, let countryID = country["id"]?.stringValue {
                user.country = getRealmEntry(Country.self, by: countryID)
            }
            
            realm.add(user, update: true)
        }
    }
    
    static func setLoginToken(_ token: String, syncRemoteID: String) {
        guard let user = User.currentUser else { return }
        let realm = try! Realm()
        try! realm.write {
            user.loginToken = token
            user.syncRemoteID = syncRemoteID
            realm.add(user, update: true)
        }
    }
    
   static func setupUser(json: JSON) throws {
        do {
            let userData: Dictionary = [
                "id"                    : json["id"].stringValue,
                "firstName"             : json["firstName"].stringValue,
                "lastName"              : json["lastName"].stringValue,
                "email"                 : json["email"].stringValue,
                "gender"                : json["gender"].stringValue,
                "city"                  : json["city"].stringValue,
                "address"               : json["address"].stringValue,
                "token"                 : json["token"].stringValue,
                "tokenExpirationTime"   : json["tokenExpirationTime"].stringValue,
                "stateId"               : json["stateId"].stringValue,
                "zipCode"               : json["zipCode"].stringValue,
                "countryId"             : json["countryId"].stringValue
            ]
        try writeUserData(userData)
        } catch UserError.configDataBase {
            Logger.log("DataBase setup incorrectly", color: .Orange)
        } catch UserError.createUser(let error) {
            Logger.log("User wasn't created by reason - \(error)", color: .Orange)
        } catch UserError.writeTransaction {
            Logger.log("Write transaction was failed", color: .Orange)
    }
    }
    
    class func writeUserData(_ userData: Dictionary<String, Any>) throws {
        let user = User(value: userData)
        
        let realm = try! Realm()
        do {
            try realm.write {
                realm.add(user, update: true)
            }
        } catch let error {
            throw UserError.createUser(description: "\(error)" )
        }
    }
    
    static var currentUser: User? = {
        let realm = try! Realm()
        guard let user = realm.objects(User.self).first else { return nil }
        
        notifierToken = realm.addNotificationBlock { (changes: Realm.Notification, realm: Realm) in
            switch changes {
            case .didChange:
                User.notifier.notify(user)
                break
            case .refreshRequired:
                break
            }
        }
        
        return user
    }()
    
    class func isAuthorized() -> Bool {
        let realm = try! Realm()
        
        guard let user = realm.objects(User.self).first, user.token.isEmpty == false else { return false }
        return true
    }
    
    func deleteUser() {
        let realm = try! Realm()
        guard let user = realm.objects(User.self).first else { return }
        
        try! realm.write {
            user.token = ""
        }
    }
    
    func fullName() -> String {
        return firstName  + " " + lastName
    }
    
    func save() throws {
        let realm = try! Realm()
        
        do {
            try realm.write {
                realm.add(User.currentUser ?? User(), update: true)
            }
        } catch _ {
            throw UserError.saveUser
        }
    }
    
    func setupPreferedAmountTrade(_ amount: String) {
        let _amount = amount.substring(from: amount.characters.index(amount.startIndex, offsetBy: 1))
        let realm = try! Realm()
        try! realm.write {
            self.preferedAmountTrade = _amount
        }
    }
}

class Boot: Object {
    dynamic var brandLastModified = 0
    dynamic var time = 0
    dynamic var customerLastActivity = 0
    
    @discardableResult static func setupBoot(json: JSON) -> Boot {
        var boot = Boot()
        let realm = try! Realm()
        
        try! realm.write {
            boot = realm.create(Boot.self, value: json.object, update: true)
        }
        
        return boot
    }
    
    override static func primaryKey() -> String? {
        return "time"
    }
    
    static func boot() -> Boot? {
        let realm = try! Realm()
        guard let boot = realm.objects(Boot.self).first else { return nil }
        return boot
    }
}

