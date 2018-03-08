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
    var name : String
    var password : String
    var email : String
    var pph : Double
    var sickTime : Double
    var vacayTime : Double
    var admin : Bool
    var toWork : String
    var history : String
    var numDaysScheduled : Int
    var numPeriods : Int
    
    init (name: String, password: String, email: String, payPerHour pph: Double, sickTime: Double, vacayTime: Double, admin: Bool, scheduledWork toWork: String, numDays numDaysScheduled: Int, payPeriodHistory history: String, numPayPeriods numPeriods: Int) {
        self.name = name
        self.password = password
        self.email = email
        self.pph = pph
        self.sickTime = sickTime
        self.vacayTime = vacayTime
        self.admin = admin
        self.toWork = toWork
        self.numDaysScheduled = numDaysScheduled
        self.history = history
        self.numPeriods = numPeriods
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
        toWork = val ["scheduledToWork"] as! String
        numDaysScheduled = val ["numDays"] as! Int
        history = val ["payPeriodHistory"] as! String
        numPeriods = val ["numPeriods"] as! Int
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
        case numDaysScheduled = "numDays"
        case history = "payPeriodHistory"
        case numPeriods
    }
    
    func toAnyObject () -> Any {
        let df = DateFormatter.init()
        df.dateStyle = .medium
        
        return [
            "name" : name,
            "password" : password,
            "email" : email,
            "pph" : pph,
            "sickTime" : sickTime,
            "vacationTime" : vacayTime,
            "admin" : admin,
            "scheduledToWork" : toWork,
            "numDays" : numDaysScheduled,
            "payPeriodHistory" : history,
            "numPeriods" : numPeriods ]
    }
}
