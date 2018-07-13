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
    var properties : String
    var numProps : Int
    
    init (name: String, billingAddress address: String, email: String, heldProperties properties: String, numProperties numProps: Int) {
        self.name = name
        self.address = address
        self.email = email
        self.properties = properties
        self.numProps = numProps
    }
    init (key: String, snapshot: DataSnapshot)
    {
        let temp = snapshot.value as! [String : AnyObject]
        let val = temp [key] as! [String : AnyObject]
        
        name = val ["name"] as! String
        address = val ["billingAddress"] as! String
        email = val ["email"] as! String
        properties = val ["heldProperties"] as! String
        numProps = val ["size"] as! Int
    }
    
    private enum CodingKeys: String, CodingKey {
        case name
        case address = "billingAddress"
        case email
        case properties = "heldProperties"
        case numProps = "size"
    }
    
    func toAnyObject () -> Any {
        return [
            "name" : name,
            "billingAddress" : address,
            "email" : email,
            "heldProperties" : properties,
            "size" : numProps ]
    }
}
