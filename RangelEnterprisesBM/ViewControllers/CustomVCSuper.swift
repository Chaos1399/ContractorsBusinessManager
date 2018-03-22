//
//  CustomVCSuper.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 2/27/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import UIKit
import FirebaseDatabase

class CustomVCSuper: UIViewController {
    var user : User?
    var clientList : [String] = []
    var employeeList : [String] = []
    static let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let clientURL = documentsDirectory.appendingPathComponent("Client List")
    static let employeeURL = documentsDirectory.appendingPathComponent("Employee List")
    var theDefaults = UserDefaults.standard
    var clientBase : DatabaseReference?
    var locationBase : DatabaseReference?
    var jobBase : DatabaseReference?
    var userBase : DatabaseReference?
    var workdayBase : DatabaseReference?
    var historyBase : DatabaseReference?
    var scheduleBase : DatabaseReference?
    let hiPri = DispatchQueue.global(qos: .userInitiated)
    let fetchGroup = DispatchGroup ()
    let df = DateFormatter ()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clientBase = Database.database().reference().child ("Clients")
        locationBase = Database.database().reference().child ("Locations")
        jobBase = Database.database().reference().child ("Jobs")
        userBase = Database.database().reference().child ("Users")
        workdayBase = Database.database().reference().child ("Workdays")
        historyBase = Database.database().reference().child ("Pay Period Histories")
        scheduleBase = Database.database().reference().child ("Schedules")
        
        if clientList.count == 0 {
            hiPri.async {
                self.clientListInit()
            }
        }
        if employeeList.count == 0 {
            hiPri.async {
                self.employeeListInit()
            }
        }
        
        df.timeStyle = .none
        df.dateFormat = "MM-dd-yy"
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func presentAlert (alertTitle: String, alertMessage: String, actionTitle: String, cancelTitle: String?, actionHandler: ((UIAlertAction) -> Void)?, cancelHandler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController (title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let action = UIAlertAction (title: actionTitle, style: .default, handler: actionHandler)
        
        alert.addAction(action)
        if cancelTitle != nil {
            let cancel = UIAlertAction (title: cancelTitle, style: .cancel, handler: cancelHandler)
            alert.addAction(cancel)
        }
        self.present (alert, animated: true, completion: nil)
    }
    
    
    func clientListInit () {
        if clientList.count == 0 {
            let persistenceRef = Database.database().reference().child("PersistenceStartup")
            var clientNum : Int = -1
            
            self.fetchGroup.enter()
            persistenceRef.queryOrderedByKey().queryEqual(toValue: "ClientSize").observeSingleEvent(of: .value, with: { (sizeSnap) in
                if sizeSnap.exists() {
                    let temp = sizeSnap.value as! [String : Int]
                    
                    clientNum = temp ["ClientSize"] as Int!
                }
                self.fetchGroup.leave()
            })
            
            self.fetchGroup.wait()
            for i in 0..<clientNum {
                self.fetchGroup.enter()
                persistenceRef.queryOrderedByKey().queryEqual(toValue: "Clients").observeSingleEvent(of: .value, with: { (clistSnap) in
                    if clistSnap.exists() {
                        self.decodePersistenceStartup(forKey: i, withSnapshot: clistSnap, forClientList: true)
                    }
                    self.fetchGroup.leave()
                })
            }
        } else {
            if theDefaults.object(forKey: "lastUpdate") as? Date != nil {
                do {
                    let data = try Data(contentsOf: CustomVCSuper.clientURL)
                    let decoder = JSONDecoder()
                    let tempArr = try decoder.decode([String].self, from: data)
                    self.clientList = tempArr
                } catch {
                    print(error)
                }
            }
        }
    }
    func employeeListInit () {
        if employeeList.count == 0 {
            let persistenceRef = Database.database().reference().child("PersistenceStartup")
            var empNum : Int = -1
            
            self.fetchGroup.enter()
            persistenceRef.queryOrderedByKey().queryEqual(toValue: "EmployeeSize").observeSingleEvent(of: .value, with: { (sizeSnap) in
                if sizeSnap.exists() {
                    let temp = sizeSnap.value as! [String : Int]
                    
                    empNum = temp ["EmployeeSize"] as Int!
                }
                self.fetchGroup.leave()
            })
            
            self.fetchGroup.wait()
            for i in 0..<empNum {
                self.fetchGroup.enter()
                persistenceRef.queryOrderedByKey().queryEqual(toValue: "Employees").observeSingleEvent(of: .value, with: { (clistSnap) in
                    if clistSnap.exists() {
                        self.decodePersistenceStartup(forKey: i, withSnapshot: clistSnap, forClientList: false)
                    }
                    self.fetchGroup.leave()
                })
            }
        } else {
            if theDefaults.object(forKey: "lastUpdate") as? Date != nil {
                do {
                    let data = try Data(contentsOf: CustomVCSuper.employeeURL)
                    let decoder = JSONDecoder()
                    let tempArr = try decoder.decode([String].self, from: data)
                    employeeList = tempArr
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func decodePersistenceStartup (forKey key: Int, withSnapshot snap: DataSnapshot, forClientList: Bool) {
        var val : String
        
        if let wholesnap = snap.value as? [AnyObject] {
            let temp = wholesnap [key] as! [String]
            val = temp [key]
        } else {
            let wholesnap = snap.value as! [String : AnyObject]
            if forClientList {
                let temp = wholesnap ["Clients"] as! [String]
                val = temp [key]
            } else {
                let temp = wholesnap ["Employees"] as! [String]
                val = temp [key]
            }
        }
        
        if forClientList {
            if key >= clientList.count {
                clientList.append(val)
            } else {
                clientList [key] = val
            }
        } else {
            if key >= employeeList.count {
                employeeList.append(val)
            } else {
                employeeList [key] = val
            }
        }
    }
    
    
    func updatePersistentStorage(setClient: Bool) {
        let encoder = JSONEncoder()
        do {
            if setClient {
                let jsonData = try encoder.encode(clientList)
                try jsonData.write(to: CustomVCSuper.clientURL)
            } else {
                let jsonData = try encoder.encode(employeeList)
                try jsonData.write(to: CustomVCSuper.employeeURL)
            }
            
            // timestamp last update
            theDefaults.set(Date(), forKey: "lastUpdate")
        } catch {
            print(error)
        }
    }
}
