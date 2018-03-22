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
    var jobs : String
    var numJobs : Int
    
    init (address: String, jobs: String, numJobs: Int) {
        self.address = address
        self.jobs = jobs
        self.numJobs = numJobs
    }
    init (key: Int, snapshot: DataSnapshot) {
        var val : [String : AnyObject]
        
        if let temp = snapshot.value as? [AnyObject] {
            val = temp [key] as! [String : AnyObject]
        } else {
            let temp = snapshot.value as! [String : AnyObject]
            val = temp [key.description] as! [String : AnyObject]
        }
        
        address = val ["address"] as! String
        jobs = val ["jobs"] as! String
        numJobs = val ["size"] as! Int
    }
    
    private enum CodingKeys: String, CodingKey {
        case address
        case jobs
        case numJobs = "size"
    }
    
    func toAnyObject () -> Any {
        return [
            "address" : address,
            "jobs" : jobs,
            "size" : numJobs]
    }
}
