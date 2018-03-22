//
//  EClockIn.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 2/22/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import UIKit
import FirebaseDatabase

// duplicates location list, doesnt show all clients

class EClockIn: CustomVCSuper {
    // MARK: - Outlets
    @IBOutlet weak var clockInOut: UIButton!
    @IBOutlet weak var numHours: UILabel!
    @IBOutlet weak var clientLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!
    
    // MARK: - Global Variables
    var start : Date = Date.init()
    var end : Date = Date.init()
    var isIn : Bool = false
    let cal = Calendar.init(identifier: .gregorian)
    var selectedClient : String?
    var selectedLocation : Location?
    var selectedJob : String?
    
    // MARK: - Required VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Custom Methods
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
    
    // MARK: - Button Methods
    @IBAction func hitClock(_ sender: UIButton) {
        var newDay : Workday
        
        if !isIn {
            start = Date.init()
            clockInOut.setTitle("Clock Out", for: .normal)
        }
        else {
            let formatter = DateFormatter()
            formatter.timeStyle = .medium
            formatter.dateStyle = .none
            
            end = Date.init()
            clockInOut.setTitle("Clock In", for: .normal)
            //Dividing by 60 to get hours from seconds
            let time = (end.timeIntervalSince(start) / 3600).rounded()
            numHours.text = time.description
            var done : Bool
            if  (time / 8) >= 1 {
                done = true
            } else {
                done = false
            }
            
            newDay = Workday.init(date: start, hours: time, done: done, forClient: selectedClient!, atLocation: self.selectedLocation!.address, doingJob: self.selectedJob!)
            
            hiPri.async {
                self.addDay (newDay)
                self.fetchGroup.wait()
            }
        }
        isIn = !isIn
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
    @IBAction func didSelectChoose (_ sender: UIButton) {
        performSegue(withIdentifier: "goToJobChoose", sender: nil)
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToJobChoose" {
            let destVC = segue.destination as! JobChoose
            
            destVC.cameFromAdmin = false
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        if selectedClient != nil && selectedLocation != nil && selectedJob != nil {
            clientLabel.text = selectedClient!
            locationLabel.text = selectedLocation!.address
            jobLabel.text = selectedJob!
        }
    }
    @IBAction func unwindToClockIn (_ segue: UIStoryboardSegue) {}
}
