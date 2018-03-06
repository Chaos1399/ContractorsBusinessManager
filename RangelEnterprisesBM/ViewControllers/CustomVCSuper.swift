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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clientListInit()
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
