//
//  Workday.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 2/21/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import Foundation

class Workday: Codable {
    var date : Date
    var hours : Int
    var lunch : Bool
    var clockedOut : Bool
    
    init (date: Date, hours: Int, hadLunch lunch: Bool, done clockedOut: Bool) {
        self.date = date
        self.hours = hours
        self.lunch = lunch
        self.clockedOut = clockedOut
    }
    
    private enum CodingKeys: String, CodingKey {
        case date
        case hours
        case lunch = "hadLunch"
        case clockedOut = "done"
    }
    
    func toAnyObject () -> Any {
        return [
            "date" : DateFormatter.init().string(from: date),
            "hours" : hours,
            "hadLunch" : lunch,
            "done" : clockedOut
        ]
    }
}
