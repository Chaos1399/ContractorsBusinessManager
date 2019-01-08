//
//  CustomVCSuper.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 2/27/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class CustomVCSuper: UIViewController {
    var user : CustomUser?
    var clientNameList : [String] = []
    var employeeUidList : [String] = []
    var employeeNameList : [String] = []
    static let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let clientURL = documentsDirectory.appendingPathComponent("Client List")
    static let employeeURL = documentsDirectory.appendingPathComponent("Employee List")
    let theDefaults = UserDefaults.standard
    var dbroot : DatabaseReference?
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
        
        dbroot = Database.database().reference()
        clientBase = dbroot!.child("Clients")
        locationBase = dbroot!.child("Locations")
        jobBase = dbroot!.child("Jobs")
        userBase = dbroot!.child("Users")
        workdayBase = dbroot!.child("Workdays")
        historyBase = dbroot!.child("PayPeriodHistories")
        scheduleBase = dbroot!.child("Schedules")
        
        if clientNameList.count == 0 && Auth.auth().currentUser != nil {
            hiPri.async {
                self.clientListInit()
            }
        }
        if employeeNameList.count == 0 && Auth.auth().currentUser != nil {
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
        self.fetchGroup.enter()
        if clientNameList.count == 0 {
            let persistenceRef = Database.database().reference().child("PersistenceStartup")
            
            persistenceRef.queryOrderedByKey().queryEqual(toValue: "Clients").observeSingleEvent(of: .value, with: { (clistSnap) in
                if clistSnap.exists() {
                    for ind in clistSnap.children {
                        let snap = ind as! DataSnapshot
                        self.decodePersistenceStartup(withSnapshot: snap, mode: 0)
                    }
                }
            })
        } else {
            if theDefaults.object(forKey: "lastUpdate") as? Date != nil {
                do {
                    let data = try Data(contentsOf: CustomVCSuper.clientURL)
                    let decoder = JSONDecoder()
                    let tempArr = try decoder.decode([String].self, from: data)
                    self.clientNameList = tempArr
                } catch {
                    print(error)
                }
            }
        }
        self.fetchGroup.leave()
    }
    func employeeListInit () {
        self.fetchGroup.enter()
        if employeeNameList.count == 0 {
            let persistenceRef = Database.database().reference().child("PersistenceStartup")
            
            // Setup employeeNameList
            persistenceRef.queryOrderedByKey().queryEqual(toValue: "Employees").observeSingleEvent(of: .value, with: { (elistSnap) in
                if elistSnap.exists() {
                    for ind in elistSnap.children {
                        let snap = ind as! DataSnapshot
                        self.decodePersistenceStartup(withSnapshot: snap, mode: 1)
                    }
                }
            })
            
            // Setup employeeUidList
            persistenceRef.queryOrderedByKey().queryEqual(toValue: "EIDs").observeSingleEvent(of: .value, with: { (uidSnap) in
                if uidSnap.exists() {
                    for ind in uidSnap.children {
                        let snap = ind as! DataSnapshot
                        self.decodePersistenceStartup(withSnapshot: snap, mode: 2)
                    }
                }
            })
        } else {
            if theDefaults.object(forKey: "lastUpdate") as? Date != nil {
                do {
                    let data = try Data(contentsOf: CustomVCSuper.employeeURL)
                    let decoder = JSONDecoder()
                    let tempArr = try decoder.decode([String].self, from: data)
                    employeeNameList = tempArr
                } catch {
                    print(error)
                }
            }
        }
        self.fetchGroup.leave()
    }
    
    func decodePersistenceStartup (withSnapshot snap: DataSnapshot, mode: Int) {
        var val : [String]
        
        if let wholesnap = snap.value as? [AnyObject] {
            let temp = wholesnap as! [String]
            val = temp
        } else {
            let wholesnap = snap.value as! [String : AnyObject]
            if mode == 0 {
                let temp = wholesnap ["Clients"] as! [String]
                val = temp
            } else if mode == 1 {
                let temp = wholesnap ["Employees"] as! [String]
                val = temp
            } else {
                let temp = wholesnap ["EIDs"] as! [String]
                val = temp
            }
        }
        
        if mode == 0 {
            for key in 0..<val.count {
                if key >= clientNameList.count {
                    clientNameList.append(val [key])
                } else {
                    clientNameList [key] = val [key]
                }
            }
        } else if mode == 1 {
            for key in 0..<val.count {
                if key >= employeeNameList.count {
                    employeeNameList.append(val [key])
                } else {
                    employeeNameList [key] = val [key]
                }
            }
        } else {
            for key in 0..<val.count {
                if key >= employeeUidList.count {
                    employeeUidList.append(val [key])
                } else {
                    employeeUidList [key] = val [key]
                }
            }
        }
    }
    
    
    func updatePersistentStorage(setClient: Bool) {
        let encoder = JSONEncoder()
        do {
            if setClient {
                let jsonData = try encoder.encode(clientNameList)
                try jsonData.write(to: CustomVCSuper.clientURL)
            } else {
                let jsonData = try encoder.encode(employeeNameList)
                try jsonData.write(to: CustomVCSuper.employeeURL)
            }
            
            // timestamp last update
            theDefaults.set(Date(), forKey: "lastUpdate")
        } catch {
            print(error)
        }
    }
    
    func numMonthDays(month: Int) -> Int {
        switch (month) {
        case 1:
            return 31;
        case 2:
            return 28;
        case 3:
            return 31;
        case 4:
            return 30;
        case 5:
            return 31;
        case 6:
            return 30;
        case 7:
            return 31;
        case 8:
            return 31;
        case 9:
            return 30;
        case 10:
            return 31;
        case 11:
            return 30;
        case 12:
            return 31;
        default:
            return -1;
        }
    }
}
