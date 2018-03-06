//
//  Location.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 2/21/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Location : Codable {
    var address : String
    var jobs : [Job]?
    
    init (address: String, jobs: [Any]) {
        self.address = address
        self.jobs = (jobs as? [Job])
    }
    
    init (key: String, object: AnyObject) {
        let val = object as! [String : AnyObject]
        
        address = val ["address"] as! String
        let tempJobs = val ["jobs"] as! [AnyObject]
        
        for i in 0...tempJobs.count {
            jobs?.append (Job.init(key: i.description, object: tempJobs [i]))
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case address
        case jobs
    }
    
    func toAnyObject () -> Any {
        var tempArr = [Any]()
        
        if jobs != nil {
            for job in jobs! {
                tempArr.append(job.toAnyObject())
            }
        }
        
        return [ "address" : address, "jobs" : tempArr ]
    }
}
