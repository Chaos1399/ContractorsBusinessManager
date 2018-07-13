//
//  ScheduledWorkday.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 3/7/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import Foundation
import FirebaseDatabase

class ScheduledWorkday: Codable {
    var client : String
    var location : String
    var job : String
    var startDate : Date
    var endDate : Date
    
    init (client: String, loc: String, job: String, startDate: Date, endDate: Date) {
        self.client = client
        self.location = loc
        self.job = job
        self.startDate = startDate
        self.endDate = endDate
    }
    
    init (key: Int, snapshot: DataSnapshot) {
        var val : [String : AnyObject]
        let df = DateFormatter ()
        df.dateFormat = "MM-dd-yy"
        
        if let temp = snapshot.value as? [AnyObject] {
            val = temp [key] as! [String : AnyObject]
        } else {
            let temp = snapshot.value as! [String : AnyObject]
            val = temp [key.description] as! [String : AnyObject]
        }
        
        client = val ["client"] as! String
        location = val ["location"] as! String
        job = val ["job"] as! String
        startDate = df.date (from: val ["start"] as! String)!
        endDate = df.date (from: val ["end"] as! String)!
    }
    
    private enum CodingKeys: String, CodingKey {
        case client
        case location
        case job
        case startDate = "start"
        case endDate = "end"
    }
    
    func toAnyObject () -> Any {
        let df = DateFormatter ()
        df.dateFormat = "MM-dd-yy"
        
        return [
            "start" : df.string(from: startDate),
            "end" : df.string(from: endDate),
            "client" : client,
            "location" : location,
            "job" : job ]
    }
}
