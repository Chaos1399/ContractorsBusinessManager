//
//  Job.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 2/21/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Job : Codable {
    var type : String
    var startDate : Date
    var endDate : Date
    var details : String?
    
    init (type: String, start: Date, end: Date, details: String?) {
        self.type = type
        self.startDate = start
        self.endDate = end
        self.details = details
    }
    
    init(key: Int, snapshot: DataSnapshot) {
        let temp = snapshot.value as! [AnyObject]
        let val = temp [key] as! [String : AnyObject]
        
        let df = DateFormatter ()
        df.timeStyle = .none
        df.dateFormat = "MM-dd-yy"
        
        type = val ["type"] as! String
        startDate = df.date(from: (val ["start"] as! String))!
        endDate = df.date(from: (val ["end"] as! String))!
        details = val ["details"] as? String
    }
    
    private enum CodingKeys: String, CodingKey {
        case type
        case startDate = "start"
        case endDate = "end"
        case details
    }
    
    func toAnyObject () -> Any {
        let df = DateFormatter.init()
        df.timeStyle = .none
        df.dateFormat = "MM-dd-yy"
        
        return [
            "type" : type,
            "start" : df.string(from: startDate),
            "end" : df.string(from: endDate),
            "details" : details
        ]
    }
}
