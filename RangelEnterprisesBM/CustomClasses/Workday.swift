//
//  Workday.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 2/21/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Workday: Codable {
    var date : Date
    var hours : Double
    var clockedOut : Bool
    var client : String
    var location : String
    var job : String
    
    init (date: Date, hours: Double, done clockedOut: Bool, forClient client: String, atLocation location: String, doingJob job: String) {
        self.date = date
        self.hours = hours
        self.clockedOut = clockedOut
        self.client = client
        self.location = location
        self.job = job
    }
    
    init (key: Int, snapshot: DataSnapshot) {
        var val : [String : AnyObject]
        let df = DateFormatter ()
        df.dateFormat = "MM-dd-yy"
        
        if let temp = snapshot.value as? [AnyObject] {
            val = (temp [key] as! [String : AnyObject])
        } else {
            let temp = snapshot.value as! [String : AnyObject]
            val = (temp [key.description] as! [String : AnyObject])
        }
        
        date = df.date (from: val ["date"] as! String)!
        hours = val ["hours"] as! Double
        clockedOut = val ["done"] as! Bool
        client = val ["client"] as! String
        location = val ["location"] as! String
        job = val ["job"] as! String
    }
    
    private enum CodingKeys: String, CodingKey {
        case date
        case hours
        case clockedOut = "done"
        case client
        case location
        case job
    }
    
    func toAnyObject () -> Any {
        let df = DateFormatter ()
        df.timeStyle = .none
        df.dateFormat = "MM-dd-yy"
        
        return [
            "date" : df.string(from: date),
            "hours" : hours,
            "done" : clockedOut,
            "client" : client,
            "location" : location,
            "job" : job ]
    }
}
