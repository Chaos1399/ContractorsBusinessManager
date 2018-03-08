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
    var date : Date
    
    init (client: String, loc: String, job: String, date: Date) {
        self.client = client
        self.location = loc
        self.job = job
        self.date = date
    }
    
    init (key: Int, snapshot: DataSnapshot) {
        let temp = snapshot.value as! [AnyObject]
        let val = temp [key] as! [String : AnyObject]
        
        let df = DateFormatter ()
        df.timeStyle = .none
        df.dateFormat = "MM-dd-yy"
        
        client = val ["client"] as! String
        location = val ["location"] as! String
        job = val ["job"] as! String
        date = df.date (from: val ["date"] as! String)!
    }
    
    private enum CodingKeys: String, CodingKey {
        case client
        case location
        case job
        case date
    }
    
    func toAnyObject () -> Any {
        let df = DateFormatter ()
        df.timeStyle = .none
        df.dateFormat = "MM/dd/yy"
        
        return [
            "date" : df.string(from: date),
            "client" : client,
            "location" : location,
            "job" : job ]
    }
}
