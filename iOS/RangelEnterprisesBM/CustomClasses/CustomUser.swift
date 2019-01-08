//
//  CustomUser.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 2/21/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import Foundation
import FirebaseDatabase

class CustomUser: Codable {
    var name : String
    var email : String
    var pph : Double
    var sickTime : Double
    var vacayTime : Double
    var admin : Bool
    var toWork : String
    var history : String
    var numDaysScheduled : Int
    var numPeriods : Int
    
    init (name: String, email: String, payPerHour pph: Double, sickTime: Double, vacayTime: Double, admin: Bool, scheduledWork toWork: String, numDays numDaysScheduled: Int, payPeriodHistory history: String, numPayPeriods numPeriods: Int) {
        self.name = name
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
        let temp = snapshot.value as! [String : AnyObject]
        let val = temp [key] as! [String : AnyObject]
        
        name = val ["name"] as! String
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
