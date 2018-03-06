//
//  User.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 2/21/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import Foundation
import FirebaseDatabase

class User: Codable {
    var name: String
    var password: String
    var email: String
    var pph: Double
    var sickTime: Double
    var vacayTime: Double
    var admin: Bool
    var toWork: [String]?
    var history: [PayPeriod]?
    
    init (name: String, password: String, email: String, payPerHour pph: Double, sickTime: Double, vacayTime: Double, admin: Bool, scheduledWork toWork: [String]?, payPeriodHistory history: [Any]?) {
        self.name = name
        self.password = password
        self.email = email
        self.pph = pph
        self.sickTime = sickTime
        self.vacayTime = vacayTime
        self.admin = admin
        self.toWork = toWork
        self.history = (history as? [PayPeriod])
    }
    
    init (key: String, snapshot: DataSnapshot) {
        name = key
        
        let temp = snapshot.value as! [String : AnyObject]
        let val = temp [key] as! [String : AnyObject]
        
        password = val ["password"] as! String
        email = val ["email"] as! String
        pph = val ["pph"] as! Double
        sickTime = val ["sickTime"] as! Double
        vacayTime = val ["vacationTime"] as! Double
        admin = val ["admin"] as! Bool
        toWork = val ["scheduledToWork"] as? [String]
        history = val ["payPeriodHistory"] as? [PayPeriod]
    }
    
    private enum CodingKeys: String, CodingKey {
        case name
        case password
        case email
        case pph
        case sickTime
        case vacayTime = "vacationTime"
        case admin
        case toWork = "scheduledToWork"
        case history = "payPeriodHistory"
    }
    
    func toAnyObject (withRef ref : DatabaseReference) -> Any {
        let df = DateFormatter.init()
        df.dateStyle = .medium
        let tempRef = ref.child("payPeriodHistory")
        
        if history != nil {
            var tempArr = [Any]()
            for period in history! {
                tempArr.append(period.toAnyObject(withRef: tempRef))
            }
            
            tempRef.setValue(tempArr)
        }
        else {
            tempRef.setValue("")
        }
        
        return [
            "name" : name,
            "password" : password,
            "email" : email,
            "pph" : pph,
            "sickTime" : sickTime,
            "vacationTime" : vacayTime,
            "admin" : admin,
            "scheduledToWork" : toWork ?? ""
        ]
    }
}
