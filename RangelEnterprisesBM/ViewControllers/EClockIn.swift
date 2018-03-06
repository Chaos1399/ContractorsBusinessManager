//
//  EClockIn.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 2/22/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import UIKit
import FirebaseDatabase

class EClockIn: CustomVCSuper, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var jobSelector: UIPickerView!
    @IBOutlet weak var clockInOut: UIButton!
    @IBOutlet weak var numHours: UILabel!
    var start : Date = Date.init()
    var end : Date = Date.init()
    var isIn : Bool = false
    var clientbase : DatabaseReference?
    var propertyList : [Location]?
    var jobList : [Job]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clientbase = Database.database().reference().child("Clients")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func hitClock(_ sender: UIButton) {
        if !isIn {
            start = Date.init()
            clockInOut.setTitle("Clock Out", for: .normal)
        }
        else {
            let df = DateFormatter()
            df.timeStyle = .medium
            df.dateStyle = .none
            
            end = Date.init()
            clockInOut.setTitle("Clock In", for: .normal)
            //Dividing by 60 to get minutes from seconds. Remember to change back to hours
            let time = (end.timeIntervalSince(start) / 60).rounded()
            numHours.text = time.description
        }
        isIn = !isIn
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return clientList.count
        } else if component == 1 {
            let selectedClientRow = pickerView.selectedRow(inComponent: 1)
            propertyList = fetchProperties (selectedClientRow)
            if propertyList != nil {
                return propertyList!.count
            } else {
                return 0
            }
        } else {
            let selectedClientRow = pickerView.selectedRow(inComponent: 1)
            let selectedLocRow = pickerView.selectedRow(inComponent: 1)
            jobList = fetchJobs(clientRow: selectedClientRow, locRow: selectedLocRow)
            if jobList != nil {
                return jobList!.count
            } else {
                return 0
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return clientList [row]
        }
        else if component == 1 {
            return propertyList? [row].address
        }
        else {
            return jobList? [row].type
        }
    }
    
    func fetchProperties (_ row: Int) -> [Location]? {
        var tempLocs : [Location]? = nil
        
        self.clientbase?.queryOrderedByKey().queryEqual(toValue: clientList [row]).observeSingleEvent(of: .value, with: { (snapshot) in
            let tempClient = Client.init(key: self.clientList [row], snapshot: snapshot)
            
            tempLocs = tempClient.properties
        })
        
        return tempLocs
    }
    
    func fetchJobs (clientRow: Int, locRow: Int) -> [Job]? {
        var tempJobs : [Job]? = nil
        
        self.clientbase?.queryOrderedByKey().queryEqual(toValue: clientList [clientRow]).observeSingleEvent(of: .value, with: { (snapshot) in
            let tempClient = Client.init(key: self.clientList [clientRow], snapshot: snapshot)
            
            tempJobs = tempClient.properties? [locRow].jobs
        })
        
        return tempJobs
    }
    
    @IBAction func didPressChangePage(_ sender: UIButton) {
        let actionSheet = UIAlertController (title: "Change Page", message: nil, preferredStyle: .actionSheet)
        let changeToMenu = UIAlertAction (title: "Menu", style: .default, handler: { (action : UIAlertAction) in
            self.tabBarController?.selectedIndex = 0
            })
        let changeToSchedule = UIAlertAction (title: "View Schedule", style: .default, handler:
        { (action : UIAlertAction) in
            self.tabBarController?.selectedIndex = 1
        })
        let changetoTimeBank = UIAlertAction (title: "Time Off", style: .default, handler:
        { (action : UIAlertAction) in
            self.tabBarController?.selectedIndex = 3
        })
        let changetoHistory = UIAlertAction (title: "Pay Period History", style: .default, handler:
        { (action : UIAlertAction) in
            self.tabBarController?.selectedIndex = 4
        })
        let cancelAction = UIAlertAction (title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction (changeToMenu)
        actionSheet.addAction (changeToSchedule)
        actionSheet.addAction (changetoTimeBank)
        actionSheet.addAction (changetoHistory)
        actionSheet.addAction (cancelAction)
        self.present (actionSheet, animated: true, completion: nil)
    }
}
