//
//  PositionItem.swift
//  VXTrade
//
//  Created by Yura Granchenko on 3/15/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import Foundation
import UIKit

class PositionItem: NSObject {
    let position: Position
    private let assetSocket = SocketManager()
    private let sellRateSocket = SocketManager()
    private var timer: Timer?
    var dispatchTimer: DispatchSourceTimer?
    var progress: CGFloat = 0.0
    fileprivate var previousPositionValue = ""
    
    var arrivedAssetRateData: ((Bool, String)->Void)?
    var arrivedSellRateData: ((String)->Void)?
    
    init (_ position: Position) {
        self.position = position
        super.init()
        assetSocket.sendMessage(.chartSubscribe(assetID: position.assetId.toString()), messageHandler: { [weak self] close, _ in
            guard let `self` = self else { return }
            let closeValue = self.positionValue(isCall: close)
            self.arrivedAssetRateData?(closeValue.0, closeValue.1)
        })
        if let customerID = CustomToken.currentToken?.id {
            sellRateSocket.sendMessage(.sellRate(customerID: customerID.toString(), positionID: position.id.toString()), messageHandler: { [weak self] value, _ in
                guard let `self` = self else { return }
                self.arrivedSellRateData?(value)
            })
        }
        
       
        timer = Timer.scheduledTimer(timeInterval: position.expiry,
                                     target: self,
                                     selector: #selector(PositionItem.prepareDelete),
                                     userInfo: nil,
                                     repeats: false)
    }
    
    
    func positionValue(isCall value: String) -> (Bool, String) {
        let isCall = previousPositionValue > value
        previousPositionValue = value
        return (isCall, value)
    }
    
    func prepareDelete() {
        position.prepareDelete()
        deletePosition()
    }
    
    func deletePosition() {
        assetSocket.unsibsribeAsset(from: position.assetId.toString())
        sellRateSocket.unsibsribeSellRate(for: position.id.toString())
        position.delete()
        timer?.invalidate()
        timer = nil
        progress = 0
    }
}

extension PositionItem {
    
    func handleProgress(for circleView: CircleProgressView) {
        self.progress = 0.0
        let expiry = CGFloat(self.position.expiry)
        dispatchTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
        dispatchTimer?.scheduleRepeating(deadline: .now(), interval: .seconds(1))
        dispatchTimer?.setEventHandler { [weak self] in
            self?.progress += 1.0
            circleView._duration = expiry
            circleView.updateProgress((self?.progress ?? 1)/expiry)
        }
        dispatchTimer?.resume()
    }
}

