//
//  NSDate+Formatter.swift
//  BinarySwipe
//
//  Created by Yuriy on 7/29/16.
//  Copyright © 2016 EasternPeak. All rights reserved.
//

import Foundation

var defaultFormat = "yyyy-MM-dd HH:mm:ss"
private var _formatters = [String:DateFormatter]()

extension DateFormatter {
    
    class func formatter() -> DateFormatter {
        return formatterWithDateFormat(defaultFormat)
    }
    
    class func formatterWithDateFormat(_ format: String) -> DateFormatter {
        var formatters = _formatters
        if let formatter = formatters[format] {
            return formatter
        }
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        _formatters[format] = formatter
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSSystemTimeZoneDidChange, object: nil, queue: nil, using: { (n) -> Void in
            formatter.timeZone = TimeZone.current
        })
        return formatter
    }
    
    class func formatterWithDateStyle(_ dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> DateFormatter {
        return formatterWithDateStyle(dateStyle, timeStyle: timeStyle, relative: false)
    }
    
    class func formatterWithDateStyle(_ dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style, relative: Bool) -> DateFormatter {
        var formatters = _formatters
        let key = "\(dateStyle.rawValue)-\(timeStyle.rawValue)-\(relative)"
        if let formatter = formatters[key] {
            return formatter
        }
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        formatter.doesRelativeDateFormatting = relative
        _formatters[key] = formatter
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSSystemTimeZoneDidChange, object: nil, queue: nil, using: { (n) -> Void in
            formatter.timeZone = TimeZone.current
        })
        return formatter
    }
    
}

extension Date {
    
    var startOfDay : Date {
        let calendar = Calendar.current
        let unitFlags = Set<Calendar.Component>([.year, .month, .day])
        let components = calendar.dateComponents(unitFlags, from: self)
        return calendar.date(from: components)!
    }
    
    var endOfDay : Date {
        var components = DateComponents()
        components.day = 1
        let date = Calendar.current.date(byAdding: components, to: self.startOfDay)
        return (date?.addingTimeInterval(-1))!
    }
}

extension Date {
    func stringWithFormat(_ format: String) -> String {
        return DateFormatter.formatterWithDateFormat(format).string(from: self)
    }
    func string() -> String {
        return DateFormatter.formatter().string(from: self)
    }
    func stringWithTimeStyle(_ timeStyle: DateFormatter.Style) -> String {
        return DateFormatter.formatterWithDateStyle(.none, timeStyle: timeStyle).string(from: self)
    }
    func stringWithDateStyle(_ dateStyle: DateFormatter.Style) -> String {
        return DateFormatter.formatterWithDateStyle(dateStyle, timeStyle: .none).string(from: self)
    }
    func stringWithDateStyle(_ dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> String {
        return DateFormatter.formatterWithDateStyle(dateStyle, timeStyle: timeStyle).string(from: self)
    }
    func stringWithDateStyle(_ dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style, relative: Bool) -> String {
        return DateFormatter.formatterWithDateStyle(dateStyle, timeStyle: timeStyle, relative: relative).string(from: self)
    }

    func dayNumberOfWeek() -> Int {
            return Calendar.current.dateComponents([.weekday], from: self).weekday ?? 0
    }
    
    //MARK: just for VXMarket
    func getDayOfWeekForVXMarket() -> Int? {
        switch dayNumberOfWeek() {
        case 1:
            return 7
        case 2:
            return 1
        case 3:
            return 2
        case 4:
            return 3
        case 5:
            return 4
        case 6:
            return 5
        case 7:
            return 6
        default:
            return nil
        }
    }
}

extension NSString {
    func dateWithFormat(_ format: String) -> Date? {
        return DateFormatter.formatterWithDateFormat(format).date(from: self as String)
    }
    func date() -> Date? {
        return DateFormatter.formatter().date(from: self as String)
    }
}

extension String {
    func serverTime() -> Date? {
        return trackServerTimeFormatter.date(from: self)
    }
}

private var trackServerTimeFormatter = specify(DateFormatter()) {
    $0.timeZone = TimeZone(identifier: "UTC")
    $0.dateFormat = defaultFormat
}

extension TimeInterval {
    static func convertMillisecond(date: String?) -> TimeInterval {
        return TimeInterval((Float(date ?? "") ?? 0.0)/1000)
    }
}
