//
//  Date+Utils.swift
//  Work It
//
//  Created by Jorge Acosta on 15-01-21.
//  Copyright © 2021 qw. All rights reserved.
//

import Foundation

extension Date {
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }

    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
   
    func convertToLocalTime(_ timeZoneAbbreviation: String) -> Date? {
            if let timeZone = TimeZone(abbreviation: timeZoneAbbreviation) {
                let targetOffset = TimeInterval(timeZone.secondsFromGMT(for: self))
                let localOffeset = TimeInterval(TimeZone.autoupdatingCurrent.secondsFromGMT(for: self))

                return self.addingTimeInterval(targetOffset - localOffeset)
            }

            return nil
        }
    
    func formatWithZoneTime() -> Date{
        let timezoneOffset =  TimeZone.current.secondsFromGMT()
        let epochDate = self.timeIntervalSince1970
        let timezoneEpochOffset = (epochDate + Double(timezoneOffset))
        return Date(timeIntervalSince1970: timezoneEpochOffset)
    }
    
    public func setTime(hour: Int, min: Int, sec: Int, timeZoneAbbrev: String = "UTC") -> Date? {
            let x: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
            let cal = Calendar.current
            var components = cal.dateComponents(x, from: self)

            components.timeZone = TimeZone(abbreviation: timeZoneAbbrev)
            components.hour = hour
            components.minute = min
            components.second = sec

            return cal.date(from: components)
        }
}
