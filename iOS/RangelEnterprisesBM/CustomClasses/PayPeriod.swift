//
//  PayPeriod.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 2/21/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import Foundation
import FirebaseDatabase

class PayPeriod: Codable {
    var startDate : Date
    var endDate : Date
    var totalHours : Double
    var days : String
    var numDays : Int
    
    init (start startDate: Date, end endDate: Date, hours totalHours: Double, days: String, numDays: Int) {
        self.startDate = startDate
        self.endDate = endDate
        self.totalHours = totalHours
        self.days = days
        self.numDays = numDays
    }
    
    init (key: Int, snapshot: DataSnapshot) {
        var val : [String : AnyObject]
        
        if let temp = snapshot.value as? [AnyObject] {
            val = temp [key] as! [String : AnyObject]
        } else {
            let temp = snapshot.value as! [String : AnyObject]
            val = temp [key.description] as! [String : AnyObject]
        }
        
        let df = DateFormatter ()
        df.timeStyle = .none
        df.dateFormat = "MM-dd-yy"
        
        startDate = df.date(from: val ["start"] as! String)!
        endDate = df.date (from: val ["end"] as! String)!
        totalHours = val ["hours"] as! Double
        days = val ["days"] as! String
        numDays = val ["numDays"] as! Int
    }
    
    private enum CodingKeys: String, CodingKey {
        case startDate = "start"
        case endDate = "end"
        case totalHours = "hours"
        case days
        case numDays
    }
    
    func toAnyObject () -> Any {
        let df = DateFormatter.init()
        df.locale = Locale (identifier: "en_US")
        df.dateFormat = "MM-dd-yy"
        
        return [
            "start" : df.string(from: startDate),
            "end" : df.string(from: endDate),
            "hours" : totalHours,
            "days" : days,
            "numDays" : numDays
        ]
    }
    
    func toString () -> String {
        let df = DateFormatter.init()
        df.locale = Locale (identifier: "en_US")
        df.dateFormat = "MM-dd-yy"
        var retString = "Start: " + df.string(from: startDate)
        retString += "\nEnd: " + df.string(from: endDate)
        retString += "\nHours: " + totalHours.description
        retString += "\nDays: " + days
        retString += "\nNumDays: " + numDays.description
        
        return retString
    }
}
