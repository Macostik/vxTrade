//
//  Transaction.swift
//  VXTrade
//
//  Created by Yuriy on 2/3/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class Transaction: Object {
    
    dynamic var id = ""
    dynamic var amountRequested = ""
    dynamic var amountApproved = ""
    dynamic var amountWithdrawable = ""
    dynamic var transferMethodTypeCode = ""
    dynamic var transactionStatusCode = ""
    dynamic var transactionTransferCreditCardId = ""
    dynamic var transactionTransferWireId = ""
    dynamic var ewalletTransactionId = ""
    dynamic var bonusTransactionId = ""
    dynamic var userId = ""
    dynamic var requestedAt = ""
    dynamic var receivedDate = ""
    dynamic var rejectionReason = ""
    dynamic var html3d = ""
    dynamic var is3dSale = ""
    dynamic var currency: Currency? = nil
    
    @discardableResult static func setupList<T: Transaction>(json: JSON) -> [T] {
        var transactionList = [T]()
        _ = json.map {
            let transaction = T()
            transaction.id =                                $1["id"].stringValue
            transaction.amountRequested =                   $1["amountRequested"].stringValue
            transaction.amountApproved =                    $1["amountApproved"].stringValue
            transaction.amountWithdrawable =                $1["amountWithdrawable"].stringValue
            transaction.transferMethodTypeCode =            $1["transferMethodTypeCode"].stringValue
            transaction.transactionStatusCode =             $1["transactionStatusCode"].stringValue
            transaction.transactionTransferCreditCardId =   $1["transactionTransferCreditCardId"].stringValue
            transaction.transactionTransferWireId =         $1["transactionTransferWireId"].stringValue
            transaction.ewalletTransactionId =              $1["ewalletTransactionId"].stringValue
            transaction.bonusTransactionId =                $1["bonusTransactionId"].stringValue
            transaction.userId =                            $1["userId"].stringValue
            transaction.requestedAt =                       $1["requestedAt"].stringValue
            transaction.receivedDate =                      $1["receivedDate"].stringValue
            transaction.rejectionReason =                   $1["rejectionReason"].stringValue
            transaction.html3d =                            $1["html3d"].stringValue
            transaction.is3dSale =                          $1["is3dSale"].stringValue
            transaction.currency = Currency.setupCurrency(json: $1["currency"])
            let realm = try! Realm()
            try! realm.write {
                realm.add(transaction, update: true)
            }
            transactionList.append(transaction)
        }
        return transactionList
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class Currency: Object {
    
    dynamic var id = ""
    dynamic var code = ""
    dynamic var name = ""
    dynamic var number = ""
    dynamic var decimals = ""
    
    @discardableResult static func setupCurrency(json: JSON) -> Currency  {
        let entryData: Dictionary<String, Any> = ["id"                                  : json["id"].stringValue,
                                                  "code"                                : json["code"].stringValue,
                                                  "name"                                : json["name"].stringValue,
                                                  "number"                              : json["number"].stringValue,
                                                  "decimals"                            : json["decimals"].stringValue]
        
        let currency = Currency(value:  entryData)
        let realm = try! Realm()
        try! realm.write {
            realm.add(currency, update: true)
        }
        return currency
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class Withdrawal: Transaction {}
class Deposit: Transaction {}

