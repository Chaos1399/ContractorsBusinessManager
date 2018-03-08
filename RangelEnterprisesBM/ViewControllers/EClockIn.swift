//
//  EClockIn.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 2/22/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import UIKit
import FirebaseDatabase

// duplicates location list, doesnt show all clients, there is an issue with third job getting messed up, turned into a dictionary instead of an array

class EClockIn: CustomVCSuper, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var jobSelector: UIPickerView!
    @IBOutlet weak var clockInOut: UIButton!
    @IBOutlet weak var numHours: UILabel!
    // Placeholder inits
    var start : Date = Date.init()
    var end : Date = Date.init()
    var isIn : Bool = false
    
    let cal = Calendar.init(identifier: .gregorian)
    let hiPri = DispatchQueue.global(qos: .userInitiated)
    let fetchGroup = DispatchGroup ()
    var propertyList : [Location] = []
    var jobList : [Job] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hiPri.async {
            self.initialPickerSetup()
        }
        self.fetchGroup.wait()
        jobSelector.reloadAllComponents()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func hitClock(_ sender: UIButton) {
        var newDay : Workday
        
        if !isIn {
            start = Date.init()
            clockInOut.setTitle("Clock Out", for: .normal)
        }
        else {
            let df = DateFormatter()
            df.locale = Locale (identifier: "en_Us")
            df.timeStyle = .medium
            df.dateStyle = .none
            
            end = Date.init()
            clockInOut.setTitle("Clock In", for: .normal)
            //Dividing by 60 to get minutes from seconds. Remember to change back to hours
            let time = (end.timeIntervalSince(start) / 60).rounded()
            numHours.text = time.description
            var done : Bool
            if  (time / 8) >= 1 {
                done = true
            } else {
                done = false
            }
            
            if (propertyList.count > 0) && (jobList.count > 0) {
                newDay = Workday.init(date: start, hours: time, done: done, forClient: clientList [jobSelector.selectedRow(inComponent: 0)], atLocation: propertyList [jobSelector.selectedRow(inComponent: 1)].address, doingJob: jobList [jobSelector.selectedRow(inComponent: 2)].type)
            } else {
                newDay = Workday.init(date: start, hours: time, done: done, forClient: clientList [jobSelector.selectedRow(inComponent: 0)], atLocation: "60 Casa", doingJob: "Painting Doors")
            }
            
            hiPri.async {
                self.addDay (newDay)
            }
            self.fetchGroup.wait()
        }
        isIn = !isIn
    }
    
    // TableView things
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return clientList.count
        } else if component == 1 {
            return propertyList.count
        } else {
            return jobList.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return clientList [row]
        }
        else if component == 1 {
            if propertyList.count > row {
                return propertyList [row].address
            } else {
                return nil
            }
        }
        else {
            return jobList [row].type
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            hiPri.async {
                self.propertyList = []
                self.jobList = []
                self.fetchProperties(row)
                self.fetchGroup.wait()
                self.fetchJobs(clientRow: row, locRow: 0)
            }
            self.fetchGroup.wait()
        } else if component == 1 {
            let clientrow = pickerView.selectedRow(inComponent: 0)
            hiPri.async {
                self.jobList = []
                self.fetchJobs(clientRow: clientrow, locRow: row)
                
            }
        }
        self.fetchGroup.wait()
        pickerView.reloadAllComponents()
    }
    
    // Custom functions
    func fetchProperties (_ row: Int) {
        self.fetchGroup.enter()
        
        self.clientBase!.queryOrderedByKey().queryEqual(toValue: clientList [row]).observeSingleEvent(of: .value, with: { (snapshot) in
            let client = Client.init(key: self.clientList [row], snapshot: snapshot)

            let locRef = Database.database().reference (fromURL: client.properties)
            
            for i in 0..<client.numProps {
                self.fetchGroup.enter()
                locRef.queryOrderedByKey().queryEqual(toValue: i.description).observeSingleEvent(of: .value, with: { (locSnap) in
                    if snapshot.exists() {
                        self.propertyList.append (Location.init(key: i, snapshot: locSnap))
                    }
                    self.fetchGroup.leave()
                })
            }
            self.fetchGroup.leave()
        })
    }
    func fetchJobs (clientRow: Int, locRow: Int) {
        self.fetchGroup.enter()
        
        self.clientBase!.queryOrderedByKey().queryEqual(toValue: clientList [clientRow]).observeSingleEvent(of: .value, with: { (snapshot) in
            let client = Client.init(key: self.clientList [clientRow], snapshot: snapshot)
            let locRef = Database.database().reference (fromURL: client.properties)
            
            for i in 0..<client.numProps {
                self.fetchGroup.enter()
                locRef.queryOrderedByKey().queryEqual(toValue: i.description).observeSingleEvent(of: .value, with: { (locSnap) in
                    if snapshot.exists() {
                        let tempLoc = Location.init(key: i, snapshot: locSnap)
                        
                        if tempLoc.address == self.propertyList [self.jobSelector.selectedRow(inComponent: 1)].address {
                            
                            let jobRef = Database.database().reference(fromURL: tempLoc.jobs)
                            
                            for j in 0..<tempLoc.numJobs {
                                self.fetchGroup.enter()
                                jobRef.queryOrderedByKey().queryEqual(toValue: j.description).observeSingleEvent(of: .value, with: { (jobSnap) in
                                    if jobSnap.exists() {
                                        self.jobList.append(Job.init(key: j, snapshot: jobSnap))
                                    }
                                    self.fetchGroup.leave()
                                })
                            }
                            self.fetchGroup.leave()
                            return
                        }
                    }
                    self.fetchGroup.leave()
                })
            }
            self.fetchGroup.leave()
        })
    }
    func addDay (_ newDay: Workday) {
        let periodRef = Database.database().reference(fromURL: self.user!.history)
        let toAddYear = self.cal.component(.year, from: newDay.date)
        let toAddMonth = self.cal.component(.month, from: newDay.date)
        let toAddDay = self.cal.component(.day, from: newDay.date)
        
        for i in 0..<self.user!.numPeriods {
            self.fetchGroup.enter()
            periodRef.queryOrderedByKey().queryEqual(toValue: i.description).observeSingleEvent(of: .value, with: { (perSnap) in
                if perSnap.exists() {
                    let tempPer = PayPeriod.init(key: i, snapshot: perSnap)
                    let startYear = self.cal.component(.year, from: tempPer.startDate)
                    let startMonth = self.cal.component(.month, from: tempPer.startDate)
                    let endMonth = self.cal.component(.month, from: tempPer.endDate)
                    let startDay = self.cal.component(.day, from: tempPer.startDate)
                    let endDay = self.cal.component(.day, from: tempPer.endDate)
                    
                    // Check if the new day is in this pay period by doing bounds checking with the start and end dates
                    if (startYear == toAddYear) && (startMonth <= toAddMonth) && (toAddMonth <= endMonth) &&
                        (startDay <= toAddDay) && (toAddDay <= endDay) {
                        let daysRef = Database.database().reference(fromURL: tempPer.days)
                        
                        daysRef.child(tempPer.numDays.description).setValue (newDay.toAnyObject())
                        tempPer.numDays += 1
                        tempPer.totalHours += newDay.hours
                        periodRef.child(i.description).setValue(tempPer.toAnyObject())
                        self.fetchGroup.leave()
                        return
                    }
                }
                self.fetchGroup.leave()
            })
        }
    }
    func initialPickerSetup () {
        let client0Name = self.clientList [0]
        
        self.fetchGroup.enter()
        self.clientBase?.queryOrderedByKey().queryEqual(toValue: client0Name).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let client = Client.init(key: client0Name, snapshot: snapshot)
                
                let locRef = Database.database().reference(fromURL: client.properties)
                
                for i in 0..<client.numProps {
                    self.fetchGroup.enter()
                    locRef.queryOrderedByKey().queryEqual(toValue: i.description).observeSingleEvent(of: .value, with: { (locSnap) in
                        if locSnap.exists() {
                            let tempLoc = Location.init(key: i, snapshot: locSnap)
                            self.propertyList.append (tempLoc)
                        }
                        self.fetchGroup.leave()
                    })
                }
            }
            self.fetchGroup.leave()
        })
        
        self.fetchGroup.wait()
        let loc0 = self.propertyList [0]
        let jobRef = Database.database().reference(fromURL: loc0.jobs)
        
        for i in 0..<loc0.numJobs {
            self.fetchGroup.enter()
            jobRef.queryOrderedByKey().queryEqual(toValue: i.description).observeSingleEvent(of: .value, with: { (jobSnap) in
                if jobSnap.exists() {
                    let tempJob = Job.init(key: i, snapshot: jobSnap)
                    self.jobList.append (tempJob)
                }
                self.fetchGroup.leave()
            })
        }
        self.fetchGroup.wait()
    }
    
    // Change page button
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
