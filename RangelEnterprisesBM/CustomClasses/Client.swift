//
//  Client.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 2/21/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Client: Codable {
    var name : String
    var address : String
    var email : String
    var properties : [Location]?
    
    init (name: String, billingAddress address: String, email: String, heldProperties properties: [Any]?) {
        self.name = name
        self.address = address
        self.email = email
        self.properties = (properties as? [Location])
    }
    init (key: String, snapshot: DataSnapshot)
    {
        name = key
        
        let temp = snapshot.value as! [String : AnyObject]
        let val = temp [key] as! [String : AnyObject]
        
        address = val ["billingAddress"] as! String
        email = val ["email"] as! String
        let tempProp = val ["heldProperties"] as! [AnyObject]
        for i in 0...tempProp.count {
            properties?.append (Location.init (key: i.description, object: tempProp [i]))
        }
        
        
    }
    
    private enum CodingKeys: String, CodingKey {
        case name
        case address = "billingAddress"
        case email
        case properties = "heldProperties"
    }
    
    func toAnyObject () -> Any {
        var tempArr = [Any]()
        
        if properties != nil {
            for loc in properties! {
                tempArr.append(loc.toAnyObject())
            }
        }
        
        return [
            "name" : name,
            "billingAddress" : address,
            "email" : email,
            "heldProperties" : tempArr
        ]
    }
}
