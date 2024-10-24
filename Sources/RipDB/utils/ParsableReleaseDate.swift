import ArgumentParser
import Foundation

struct ParsableReleaseDate: ExpressibleByArgument {
    var year: UInt
    var month: UInt
    var day: UInt
    
    init(year: UInt, month: UInt, day: UInt) {
        self.year = year
        self.month = month
        self.day = day
    }
    
    init?(argument: String) {
        let pattern = /(?<year>[0-9]{4})-(?<month>[0-9]{2})-(?<day>[0-9]{2})/
        guard let match = try? pattern.wholeMatch(in: argument) else {
            return nil
        }
        
        guard let year = UInt(match.output.year), let month = UInt(match.output.month), let day = UInt(match.output.day) else {
            return nil
        }
        
        self.year = year
        self.month = month
        self.day = day
    }
}

extension ParsableReleaseDate {
    struct DateConversionError: Error, CustomStringConvertible {
        init() { }
        
        var description: String { "Invalid release date." }
    }
    
    init(date: Date, calendar: Calendar = .current) {
        self.year = UInt(calendar.component(.year, from: date))
        self.month = UInt(calendar.component(.month, from: date))
        self.day = UInt(calendar.component(.day, from: date))
    }
    
    func toDate() throws -> Date {
        if let date = Calendar.current.date(from: DateComponents(year: Int(year), month: Int(month), day: Int(day))) {
            return date
        }
        
        throw DateConversionError()
    }
}
