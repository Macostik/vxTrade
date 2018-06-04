//
//  EntryParamsPresentring.swift
//  VXTrade
//
//  Created by Yuriy on 12/29/16.
//  Copyright © 2016 VXmarkets. All rights reserved.
//

import UIKit
import Alamofire

typealias URLParameters = (url: String, addition: String?)
typealias Body = (path: String?, parameters: Parameters)
typealias EntryParameters = (URLParameters?, HTTPHeaders?, Body?)

protocol EntryParametersPresentable {}

protocol EntryParametersPresenting {
    var entryParameters: EntryParameters { get set }
    init(entryParameters: EntryParameters)
    func parameters() -> EntryParameters
}

extension EntryParametersPresenting where Self: EntryParametersPresentable {
    init(entryParameters: EntryParameters) {
        self.init(entryParameters: entryParameters)
    }
    func parameters() -> EntryParameters {
        return entryParameters
    }
}

struct LoginEntryParams: EntryParametersPresenting, EntryParametersPresentable {
    internal var entryParameters: EntryParameters
}

struct LogoutEntryParams: EntryParametersPresenting, EntryParametersPresentable {
    internal var entryParameters: EntryParameters
}

struct ProftitTokenEntryParams: EntryParametersPresenting, EntryParametersPresentable {
    internal var entryParameters: EntryParameters
}

struct CustomTokenEntryParams: EntryParametersPresenting, EntryParametersPresentable {
    internal var entryParameters: EntryParameters
}

struct OpenRulesEntryParam: EntryParametersPresenting, EntryParametersPresentable {
    internal var entryParameters: EntryParameters
}

struct OpenPositionEntryParam: EntryParametersPresenting, EntryParametersPresentable {
    internal var entryParameters: EntryParameters
}

struct ExpirePositionEntryParam: EntryParametersPresenting, EntryParametersPresentable {
    internal var entryParameters: EntryParameters
}

struct CreatePositionEntryParam: EntryParametersPresenting, EntryParametersPresentable {
    internal var entryParameters: EntryParameters
}

struct ClosePositionEntryParam: EntryParametersPresenting, EntryParametersPresentable {
    internal var entryParameters: EntryParameters
}

struct RolloverPositionEntryParam: EntryParametersPresenting, EntryParametersPresentable {
    internal var entryParameters: EntryParameters
}

struct CardEntryParam: EntryParametersPresenting, EntryParametersPresentable {
    internal var entryParameters: EntryParameters
}

struct DepositEntryParam: EntryParametersPresenting, EntryParametersPresentable {
    internal var entryParameters: EntryParameters
}

struct CountryEntryParam: EntryParametersPresenting, EntryParametersPresentable {
    internal var entryParameters: EntryParameters
}

struct UserProfileEntryParam: EntryParametersPresenting, EntryParametersPresentable {
    internal var entryParameters: EntryParameters
}

struct UpdateUserProfileEntryParam: EntryParametersPresenting, EntryParametersPresentable {
    internal var entryParameters: EntryParameters
}

struct RegularGraphEntryParam: EntryParametersPresenting, EntryParametersPresentable {
    internal var entryParameters: EntryParameters
}

struct PositionGraphEntryParam: EntryParametersPresenting, EntryParametersPresentable {
    internal var entryParameters: EntryParameters
}

struct BootEntryParam: EntryParametersPresenting, EntryParametersPresentable {
    internal var entryParameters: EntryParameters
}

struct TrandingAccountEntryParam: EntryParametersPresenting, EntryParametersPresentable {
    internal var entryParameters: EntryParameters
}
