//
//  Card.swift
//  VXTrade
//
//  Created by Yuriy on 1/11/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class Card: Object {
    
    dynamic var id = ""
    dynamic var creditcardTypeId = ""
    dynamic var number = ""
    dynamic var cvv = ""
    dynamic var expireMonth = ""
    dynamic var expireYear = ""
    dynamic var email = ""
    dynamic var statusCode = ""
    dynamic var zipCode = ""
    dynamic var countryId = ""
    dynamic var stateId = ""
    dynamic var city = ""
    dynamic var address = ""
    dynamic var lastName = ""
    dynamic var firstName = ""
    dynamic var realCardNumber = ""
    dynamic var owner: User? = nil
    
    @discardableResult static func setupCard(json: JSON) -> [Card] {
        var positionContainer = [Card]()
        _ = json.map {
            let card = Card()
            card.id =                   $1["id"].stringValue
            card.creditcardTypeId =     $1["creditcardTypeId"].stringValue
            card.number =               $1["number"].stringValue
            card.cvv =                  $1["cvv"].stringValue
            card.expireMonth =          $1["expireMonth"].stringValue
            card.expireYear =           $1["expireYear"].stringValue
            card.email =                $1["email"].stringValue
            card.statusCode =           $1["statusCode"].stringValue
            card.zipCode =              $1["zipCode"].stringValue
            card.countryId =            $1["countryId"].stringValue
            card.stateId =              $1["stateId"].stringValue
            card.city =                 $1["city"].stringValue
            card.address =              $1["address"].stringValue
            card.lastName =             $1["lastName"].stringValue
            card.firstName =            $1["firstName"].stringValue
            card.realCardNumber =       $1["realCardNumber"].stringValue
            
            card.owner = User.currentUser
            let realm = try! Realm()
            try! realm.write {
                realm.add(card, update: true)
            }
            positionContainer.append(card)
        }
        return positionContainer
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
