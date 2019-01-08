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
    var city : String
    var jobs : String
    var numJobs : Int
    
    init (address: String, city: String, jobs: String, numJobs: Int) {
        self.address = address
        self.jobs = jobs
        self.numJobs = numJobs
        self.city = city
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
        numJobs = val ["numJobs"] as! Int
        city = val["city"] as! String
    }
    
    private enum CodingKeys: String, CodingKey {
        case address
        case jobs
        case numJobs
        case city
    }
    
    func toAnyObject () -> Any {
        return [
            "address" : address,
            "city" : city,
            "jobs" : jobs,
            "numJobs" : numJobs]
    }
    
    func toString () -> String {
        var retString : String = "Address: " + address
        retString += "\nCity: " + city
        retString += "\nJobs: " + jobs
        retString += "\nNumJobs: " + numJobs.description
        
        return retString
    }
}
