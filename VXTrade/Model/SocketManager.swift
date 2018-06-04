//
//  SocketManager.swift
//  VXTrade
//
//  Created by Yura Granchenko on 2/27/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import Foundation
import UIKit
import SwiftWebSocket

enum TypeMessage {
    case balance (customerID: String)
    case sellRate (customerID: String, positionID: String)
    case positionUpdate (customerID: String, positionID: String)
    case chartSubscribe (assetID: String)
}

class SocketManager: NSObject {
    var timer: Timer? = nil
    var counter = 0
    var previousValue = ""
    lazy var ws: WebSocket = {
        guard let token = CustomToken.currentToken?.token  else { return WebSocket() }
        return WebSocket("wss://streamer.binarytradingcore.com/socket.io/?token=\(token)&transport=websocket")
    }()
    
    func sendMessage(_ type: TypeMessage, messageHandler: @escaping (String, Double) -> Void) {
       
        ws.event.open = { [weak self] in
            Logger.log("Socket opened", color: .Orange)
            self?.ws.send("2probe")
            self?.ws.send("5")
        }
        ws.event.close = { _ in
            Logger.log("Socket closed", color: .Orange)
        }
        ws.event.error = {
            print (">>socket got error - \($0)<<")
        }

        let messageBlock: ((TypeMessage) -> (String)) = { [weak self] type in
            guard let `self` = self else { return "" }
            var message = ""
            switch type {
            case .balance (let customerID):
                message = "42[\"customer." + customerID + ".balance:read\",{\"id\":" + customerID + "}]"
            case .sellRate (let customerID, let positionID):
                message = "42\(self.counter)[\"customer." + customerID + ".position." + positionID + ".sellRate:read\",{\"id\":" + positionID + "}]"
            case .positionUpdate (let customerID, let positionID):
                message = "42[\"customer." + customerID + ".position." + positionID + ":read\",{\"id\":" + positionID + ",\"status\":null,\"payout\":null,\"marketExpiryRate\":null,\"redisCache\":true}]"
            case .chartSubscribe (let asseetID):
                message = "42\(self.counter)[\"feed.expiry.asset." + asseetID + ".period.30:read\",{\"id\":" + asseetID + ",\"assetId\":null,\"brandId\":null,\"date\":null,\"lastTime\":null,\"close\":null,\"open\":null,\"low\":null,\"high\":null,\"feedDelta\":null,\"period\":null}]"
            }

            self.counter += 1
            return message
        }
        
        if #available(iOS 10.0, *) {
            timer = Timer.scheduledTimer(withTimeInterval: 20.0, repeats: true, block: { [weak self] _ in
                self?.ws.send("2")
            })
        }
        ws.event.message = { message in
            func getValue(from message: String, by range: Range<String.Index>) -> String {
                var message = message
                var value: Double = 0.0
                message = message.substring(with: Range(uncheckedBounds: (range.upperBound, message.endIndex)))
                let assetScanner = Scanner(string: message)
                assetScanner.scanDouble(&value)
                return "\(value)"
            }
            
            func getLastTime(from message: String, by range: Range<String.Index>) -> Double {
                let date = message.substring(with: Range(uncheckedBounds: (range.upperBound, message.index(range.upperBound, offsetBy: 19))))
                return date.date()?.timeIntervalSince1970 ?? 0.0
            }
            
            guard let message = message as? String else { return }
            switch type {
            
            case .balance:
                guard let range = message.range(of: "total\\\":") else { break }
                let value = getValue(from: message, by: range)
                messageHandler(value, 0.0)
                break
            case .sellRate:
                if message.contains("Subscribed") { messageHandler(3 << "0.0", 0.0) }
                guard let range = message.range(of: "value\\\":") else { break }
                let value = 3 << getValue(from: message, by: range)
                messageHandler(value, 0.0)
                break
                
            case .positionUpdate:
                guard let range = message.range(of: "payout\\\":") else { break }
                let value = getValue(from: message, by: range)
                messageHandler(value, 0.0)
                break
                
            case .chartSubscribe:
                guard let range = message.range(of: "close\\\":") else { break }
                let value = getValue(from: message, by: range)
                guard let timeRange = message.range(of: "lastTime\\\":\\\"") else { break }
                let timestamp = getLastTime(from: message, by: timeRange)
                messageHandler(value, timestamp)
                break
            }
        }
    
        let m = messageBlock(type)
        ws.send(m)
    }
    
    func unsibsribeAsset(from assetID: String){
        timer?.invalidate()
        
        let  message = "42[\"feed.expiry.asset." + assetID + ".period.30:delete\",{\"id\":" + assetID + ",\"assetId\":null,\"brandId\":null,\"date\":null,\"lastTime\":null,\"close\":null,\"open\":null,\"low\":null,\"high\":null,\"feedDelta\":null,\"period\":null}]"
        ws.send(message)
    }
    
    func unsibsribeSellRate(for positionID: String){
        timer?.invalidate()
        guard let cusomerID = CustomToken.currentToken?.id.toString() else { return }
        let  message = "420[\"customer." + cusomerID + ".position." + positionID + ".sellRate:delete\",\"{\"redisCache\" : false}\"]"
        ws.send(message)
    }
}

