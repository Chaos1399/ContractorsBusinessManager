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
    var number : Int
    var totalHours : Int
    var days : [Workday]
    
    init (start startDate: Date, end endDate: Date, period number: Int, hours totalHours: Int, days: [Any]) {
        self.startDate = startDate
        self.endDate = endDate
        self.number = number
        self.totalHours = totalHours
        self.days = days as! [Workday]
    }
    
    private enum CodingKeys: String, CodingKey {
        case startDate = "start"
        case endDate = "end"
        case number = "period"
        case totalHours = "hours"
        case days
    }
    
    func toAnyObject (withRef ref: DatabaseReference) -> Any {
        let df = DateFormatter.init()
        df.dateStyle = .medium
        
        let tempRef = ref.child("days")
        var tempArr = [Any]()
        for day in days {
            tempArr.append(day.toAnyObject())
        }
        
        tempRef.setValue(tempArr)
        
        return [
            "start" : df.string(from: startDate),
            "end" : df.string(from: endDate),
            "period" : number,
            "hours" : totalHours
        ]
    }
}
