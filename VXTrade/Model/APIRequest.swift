//
//  APIRequest.swift
//  BinarySwipe
//
//  Created by Yuriy on 6/16/16.
//  Copyright © 2016 EasternPeak. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

enum MainURL: CustomStringConvertible {
    enum Server {
        case qa, prod
    }
    case base(server: Server), proftit
    
    var description: String {
        switch self {
        case .base(let server):
            if server == .qa {
                return "http://qa.binarytradingcore.com:8000/"
            } else {
                return "https://api.binarytradingcore.com/"
            }
        case .proftit:
            return "https://api.prod.proftit.com/api/"
        }
    }
}

func requestHandler(_ function: Any, urlRequest: URLRequestConvertible, completionHandler: @escaping (JSON?) -> Void) {
    Logger.log("\n\t url - \(function)", color: .Yellow)
    Alamofire.request(urlRequest)
        .validate()
        .responseJSON { response in
            var errorDescription = ""
            var errorReason = ""
            if case let .failure(error) = response.result {
                if let error = error as? AFError {
                    switch error {
                    case .invalidURL(let url):
                        errorReason = "Invalid URL: " + "\(url) - \(error.localizedDescription)"
                    case .parameterEncodingFailed(let reason):
                        errorDescription = "Parameter encoding failed: " + "\(error.localizedDescription)"
                        errorReason = "Failure Reason: " + "\(reason)"
                    case .multipartEncodingFailed(let reason):
                        errorDescription = "Multipart encoding failed: " + "\(error.localizedDescription)"
                        errorReason = "Failure Reason: " + "\(reason)"
                    case .responseValidationFailed(let reason):
                        errorDescription = "Response validation failed: " + "\(error.localizedDescription)"
                        errorReason = "Failure Reason: " + "\(reason)"
                        
                        switch reason {
                        case .dataFileNil, .dataFileReadFailed:
                            errorDescription = "Downloaded file could not be read"
                        case .missingContentType(let acceptableContentTypes):
                            errorDescription = "Content Type Missing: " + "\(acceptableContentTypes)"
                        case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                            errorDescription = "Response content type: " + "\(responseContentType) " + "was unacceptable: " + "\(acceptableContentTypes)"
                        case .unacceptableStatusCode(let code):
                            errorDescription = "Response status code was unacceptable: " + "\(code)"
                        }
                    case .responseSerializationFailed(let reason):
                        errorDescription = "Response serialization failed: " + "\(error.localizedDescription)"
                        errorReason = "Failure Reason: " + "\(reason)"
                    }
                    
                    errorDescription =  "Underlying error: " + "\(error.underlyingError)"
                } else if let error = error as? URLError {
                    errorDescription = "URLError occurred: " + "\(error)"
                } else {
                    errorDescription = "Unknown error: " + "\(error)"
                }
                Logger.log("\tAPI called function - \(function)\n\t" + errorDescription + errorReason, color: .Red)
                UIAlertController.alert(String(format: errorDescription), message: errorReason).show()
                completionHandler(nil)
            }
            
            if case let .success(value) = response.result {
                let json = JSON(value)
                Logger.log("\tAPI called function - \(function)\n\tRESPONSE - \(json)\n\tTIMELINE - \(response.timeline)", color: .Green)
                completionHandler(json)
            }
    }
}

func performRequest(_ function: Any, urlRequest: URLRequestConvertible, completion: @escaping (JSON?, Bool) -> Void) {
    requestHandler(function, urlRequest: urlRequest ) { json in
        guard json != nil else {
            completion(nil, false)
            return }
        completion(json, true)
    }
}

enum UserRequest: URLRequestConvertible {
    
    typealias T = EntryParametersPresenting
    
    case logIn(T)
    case logOut(T)
    case customToken(T)
    case proftitToken(T)
    case tradingAccount(T)
    case regularRule(T)
    case trendRule(T)
    case openPosition(T)
    case expirePosition(T)
    case createPosition(T)
    case closePosition(T)
    case rolloverPosition(T)
    case card(T)
    case depositList(T)
    case country(T)
    case userProfile(T)
    case updateUserProfile(T)
    case regularGraph(T)
    case boot(T)
    case positionGraph(T)
    
    func asURLRequest() throws -> URLRequest {
        
        var method: HTTPMethod {
            switch self {
            case .regularRule, .trendRule, .openPosition, .expirePosition, .card, .depositList, .country, .userProfile, .regularGraph, .boot, .tradingAccount, .positionGraph:
                return .get
            case .logIn, .customToken, .proftitToken, .createPosition:
                return .post
            case .closePosition, .rolloverPosition:
                return .put
            case .logOut:
                return .delete
            case .updateUserProfile:
                return .patch
            }
        }
        
        let headersParam: (HTTPHeaders?) = {
            switch self {
            case .logIn, .proftitToken, .country:
                return nil
            case .logOut(let newPost):
                return newPost.entryParameters.1
            case .customToken(let newPost):
                return newPost.entryParameters.1
            case .regularRule(let newPost):
                return newPost.entryParameters.1
            case .trendRule(let newPost):
                return newPost.entryParameters.1
            case .openPosition(let newPost):
                return newPost.entryParameters.1
            case .expirePosition(let newPost):
                return newPost.entryParameters.1
            case .createPosition(let newPost):
                return newPost.entryParameters.1
            case .closePosition(let newPost):
                return newPost.entryParameters.1
            case .rolloverPosition(let newPost):
                return newPost.entryParameters.1
            case .card(let newPost):
                return newPost.entryParameters.1
            case .depositList(let newPost):
                return newPost.entryParameters.1
            case .userProfile(let newPost):
                return newPost.entryParameters.1
            case .updateUserProfile(let newPost):
                return newPost.entryParameters.1
            case .regularGraph(let newPost):
                return newPost.entryParameters.1
            case .boot(let newPost):
                return newPost.entryParameters.1
            case .tradingAccount(let newPost):
                return newPost.entryParameters.1
            case .positionGraph(let newPost):
                return newPost.entryParameters.1
            }
        }()
        
        let url: URL = {
            var relativePath: String = ""
            switch self {
            case .logIn(let newPost):
                relativePath = (newPost.entryParameters.0?.0 ?? "") + "user/v1/tokens"
            case .logOut(let newPost):
                relativePath = (newPost.entryParameters.0?.0 ?? "") + "customer/v1/tokens/~"
            case .customToken(let newPost):
                relativePath = (newPost.entryParameters.0?.0 ?? "") + "Security/CustomerToken"
            case .proftitToken(let newPost):
                relativePath = (newPost.entryParameters.0?.0 ?? "") + "customer/v1/tokens"
            case .tradingAccount(let newPost):
                if let customerID = newPost.entryParameters.0?.1 {
                    relativePath = (newPost.entryParameters.0?.0 ?? "") + "user/v1/customers/\(customerID)/tradingAccounts?_expand[]=tradingAccountType&_expand[]=platform&_expand[]=currency"
                }
            case .regularRule(let newPost):
                if let dayOfWeek = Date().getDayOfWeekForVXMarket() {
                    if let boot = newPost.entryParameters.0?.1 {
                        relativePath = (newPost.entryParameters.0?.0 ?? "") + "Rules?query=%7B%22Query%22%3A%7B%22status%22%3A%22active%22%2C%22type%22%3A%22regular%22%2C%22days%22%3A%7B%22%24elemMatch%22%3A%7B%22%24or%22%3A%5B%7B%22dayNum%22%3A\(dayOfWeek)%7D%2C%7B%22dayNum%22%3A\(dayOfWeek + 1)%7D%5D%7D%7D%7D%2C%22includes%22%3A%5B%22GroupPayouts.Payouts%22%2C%22Asset%22%2C%22Asset.TradingPeriods%22%2C%22Asset.TradingPeriods.Days%22%2C%22Asset.RolloverPeriods%22%2C%22Days%22%5D%7D&lastSync=\(boot)"
                    }
                }
            case .trendRule(let newPost):
                if let dayOfWeek = Date().getDayOfWeekForVXMarket() {
                    if let boot = newPost.entryParameters.0?.1 {
                        relativePath = (newPost.entryParameters.0?.0 ?? "") + "Rules?query=%7B%22Query%22%3A%7B%22status%22%3A%22active%22%2C%22type%22%3A%22trend%22%2C%22days%22%3A%7B%22%24elemMatch%22%3A%7B%22%24or%22%3A%5B%7B%22dayNum%22%3A\(dayOfWeek)%7D%2C%7B%22dayNum%22%3A\(dayOfWeek + 1)%7D%5D%7D%7D%7D%2C%22includes%22%3A%5B%22GroupPayouts.Payouts%22%2C%22Asset%22%2C%22Asset.TradingPeriods%22%2C%22Asset.TradingPeriods.Days%22%2C%22Asset.RolloverPeriods%22%2C%22Days%22%5D%7D&lastSync=\(boot)"
                    }
                }
            case .openPosition(let newPost):
                relativePath = (newPost.entryParameters.0?.0 ?? "") + "Positions?query=%7B%22Query%22%3A%7B%22status%22%3A%22open%22%7D%2C%22includes%22%3A%5B%22Asset%22%2C%22Asset.TradingPeriods%22%2C%22Asset.TradingPeriods.Days%22%2C%22Asset.RolloverPeriods%22%2C%22Metadata%22%5D%7D&lastSync=1479990737000"
            case .expirePosition(let newPost):
                relativePath = (newPost.entryParameters.0?.0 ?? "") + "Positions?query=%7B%22Query%22%3A%7B%22status%22%3A%7B%22%24nin%22%3A%5B%22open%22%2C%22rollover%22%5D%7D%7D%2C%22includes%22%3A%5B%22Asset%22%5D%7D&lastSync=0"
            case .createPosition(let newPost):
                relativePath = (newPost.entryParameters.0?.0 ?? "") + "Positions"
            case .closePosition(let newPost):
                if let id = newPost.entryParameters.0?.1 {
                    relativePath = (newPost.entryParameters.0?.0 ?? "") + "Positions/\(id)"
                }
            case .rolloverPosition(let newPost):
                if let id = newPost.entryParameters.0?.1 {
                    relativePath = (newPost.entryParameters.0?.0 ?? "") + "Positions/\(id)"
                }
            case .card(let newPost):
                relativePath = (newPost.entryParameters.0?.0 ?? "") + "customer/v1/creditcards"
            case .depositList(let newPost):
                relativePath = (newPost.entryParameters.0?.0 ?? "") + "customer/v1/tradingAccounts/9/deposits?_expand=currency"
            case .country(let newPost):
                relativePath = (newPost.entryParameters.0?.0 ?? "") + "public/v1/countries"
            case .userProfile(let newPost):
                relativePath = (newPost.entryParameters.0?.0 ?? "") + "user/v1/customers/\((User.currentUser?.id ?? ""))?_expand=country"
            case .updateUserProfile(let newPost):
                relativePath = (newPost.entryParameters.0?.0 ?? "") + "user/v1/customers/\((User.currentUser?.id ?? ""))?_expand=country"
            case .regularGraph(let newPost):
                if let id = newPost.entryParameters.0?.1 {
                    relativePath = (newPost.entryParameters.0?.0 ?? "") + "Graphs?query=%7B%22graphType%22%3A%22ohlc%22%2C%22graphSource%22%3A%22priced%22%2C%22minimumDateTime%22%3A%22now-1h%22%2C%22maximumDateTime%22%3A%22now%22%2C%22period%22%3A30%2C%22ruleId%22%3A%5B\(id)%5D%7D&_=1481284729981"
                }
            case .positionGraph(let newPost):
                if let id = newPost.entryParameters.0?.1 {
                    relativePath = (newPost.entryParameters.0?.0 ?? "") + "Graphs?query=%7B%22graphSource%22%3A%22market%22%2C%22graphType%22%3A%22points%22%2C%22period%22%3A%2230%22%2C%22minimumDateTime%22%3A1491321300%2C%22maximumDateTime%22%3A1491321900%2C%22assetId%22%3A%5B\(id)%5D%7D&_=1491561523435"
                }
            case .boot(let newPost):
                relativePath = (newPost.entryParameters.0?.0 ?? "") + "Boot?"
            }

            return Foundation.URL(string: relativePath)!
        }()
        
        let bodyParams: Body? = {
            switch self {
            case .logIn(let newPost):
                return newPost.entryParameters.2
            case .customToken(let newPost):
                return newPost.entryParameters.2
            case .proftitToken(let newPost):
                return newPost.entryParameters.2
            case .depositList(let newPost):
                return newPost.entryParameters.2
            case .updateUserProfile(let newPost):
                return newPost.entryParameters.2
            case .createPosition(let newPost):
                return newPost.entryParameters.2
            case .closePosition(let newPost):
                return newPost.entryParameters.2
            case .rolloverPosition(let newPost):
                return newPost.entryParameters.2
            case .boot(let newPost):
                return newPost.entryParameters.2
            default: break
            }
            return nil
        }()
        
        Logger.log("API call\n\t url - \(url)\n\t method - \(method)\n\t headerParams - \(headersParam ?? ["":""])\n\t bodyParam - \(bodyParams?.1 ?? ["":""])", color: .Yellow)
        
        return Alamofire.request(url, method: method, parameters: bodyParams?.parameters,
                                 encoding: JSONEncoding.default, headers: headersParam).request!
    }
    
    static func createUser(_ entry: T, completion: @escaping (JSON?, Bool) -> Void) {
        performRequest(#function, urlRequest: logIn(entry), completion: completion)
    }
    
    static func getCustomToken(_ entry: T, completion: @escaping (JSON?, Bool) -> Void) {
        performRequest(#function, urlRequest: customToken(entry), completion: completion)
    }
    
    static func getProftitToken(_ entry: T, completion: @escaping (JSON?, Bool) -> Void) {
        performRequest(#function, urlRequest: proftitToken(entry), completion: completion)
    }
    
    static func logoutUser(_ entry: T, completion: @escaping (JSON?, Bool) -> Void) {
        performRequest(#function, urlRequest: logOut(entry), completion: completion)
    }
    
    static func getRegularRules(_ entry: T, completion: @escaping (JSON?, Bool) -> Void) {
        performRequest(#function, urlRequest: regularRule(entry), completion: completion)
    }
    
    static func getTrendRules(_ entry: T, completion: @escaping (JSON?, Bool) -> Void) {
        performRequest(#function, urlRequest: trendRule(entry), completion: completion)
    }
    
    static func getOpenPositions(_ entry: T, completion: @escaping (JSON?, Bool) -> Void) {
        performRequest(#function, urlRequest: openPosition(entry), completion: completion)
    }
    
    static func getExpirePositions(_ entry: T, completion: @escaping (JSON?, Bool) -> Void) {
        performRequest(#function, urlRequest: expirePosition(entry), completion: completion)
    }
    
    static func makeCreatingPositions(_ entry: T, completion: @escaping (JSON?, Bool) -> Void) {
        performRequest(#function, urlRequest: createPosition(entry), completion: completion)
    }
    
    static func makeClosingPositions(_ entry: T, completion: @escaping (JSON?, Bool) -> Void) {
        performRequest(#function, urlRequest: closePosition(entry), completion: completion)
    }
    
    static func makeRolloverPositions(_ entry: T, completion: @escaping (JSON?, Bool) -> Void) {
        performRequest(#function, urlRequest: rolloverPosition(entry), completion: completion)
    }
    
    static func getCreditCads(_ entry: T, completion: @escaping (JSON?, Bool) -> Void) {
        performRequest(#function, urlRequest: card(entry), completion: completion)
    }
    
    static func getDepositList(_ entry: T, completion: @escaping (JSON?, Bool) -> Void) {
        performRequest(#function, urlRequest: depositList(entry), completion: completion)
    }
    
    static func getCountries(_ entry: T, completion: @escaping (JSON?, Bool) -> Void) {
        performRequest(#function, urlRequest: country(entry), completion: completion)
    }
    
    static func getUserProfile(_ entry: T, completion: @escaping (JSON?, Bool) -> Void) {
        performRequest(#function, urlRequest: userProfile(entry), completion: completion)
    }
    
    static func makeUpdateUserProfile(_ entry: T, completion: @escaping (JSON?, Bool) -> Void) {
        performRequest(#function, urlRequest: updateUserProfile(entry), completion: completion)
    }
    
    static func getRegularGraph(_ entry: T, completion: @escaping (JSON?, Bool) -> Void) {
        performRequest(#function, urlRequest: regularGraph(entry), completion: completion)
    }
    
    static func getPositionGraph(_ entry: T, completion: @escaping (JSON?, Bool) -> Void) {
        performRequest(#function, urlRequest: positionGraph(entry), completion: completion)
    }
    
    static func getBoot(_ entry: T, completion: @escaping (JSON?, Bool) -> Void) {
        performRequest(#function, urlRequest: boot(entry), completion: completion)
    }
    static func getTradingAccount(_ entry: T, completion: @escaping (JSON?, Bool) -> Void) {
        performRequest(#function, urlRequest: tradingAccount(entry), completion: completion)
    }
}
