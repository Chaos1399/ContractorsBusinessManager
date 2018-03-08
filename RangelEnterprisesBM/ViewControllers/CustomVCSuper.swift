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
    static let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let archiveURL = documentsDirectory.appendingPathComponent("Client List")
    var theDefaults = UserDefaults.standard
    var clientBase : DatabaseReference?
    var locationBase : DatabaseReference?
    var jobBase : DatabaseReference?
    var userBase : DatabaseReference?
    var workdayBase : DatabaseReference?
    var historyBase : DatabaseReference?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clientBase = Database.database().reference().child ("Clients")
        locationBase = Database.database().reference().child("Locations")
        jobBase = Database.database().reference().child("Jobs")
        userBase = Database.database().reference().child ("Users")
        workdayBase = Database.database().reference().child ("Workdays")
        historyBase = Database.database().reference().child ("Pay Period Histories")
        
        clientListInit()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func presentAlert (alertTitle: String, alertMessage: String, actionTitle: String, cancelTitle: String?) {
        let alert = UIAlertController (title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let action = UIAlertAction (title: actionTitle, style: .default, handler: nil)
        
        alert.addAction(action)
        if cancelTitle != nil {
            let cancel = UIAlertAction (title: cancelTitle, style: .cancel, handler: nil)
            alert.addAction(cancel)
        }
        self.present (alert, animated: true, completion: nil)
    }
    func clientListInit () {
        if theDefaults.object(forKey: "lastUpdate") as? Date != nil {
            do {
                let data = try Data(contentsOf: CustomVCSuper.archiveURL)
                let decoder = JSONDecoder()
                let tempArr = try decoder.decode([String].self, from: data)
                clientList = tempArr
            } catch {
                print(error)
            }
        }
    }
    func updatePersistentStorage() {
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(clientList)
            try jsonData.write(to: CustomVCSuper.archiveURL)
            
            // timestamp last update
            theDefaults.set(Date(), forKey: "lastUpdate")
        } catch {
            print(error)
        }
    }
}
