//
//  ETimeBank.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 2/22/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ETimeBank: CustomVCSuper, UIPickerViewDelegate, UIPickerViewDataSource {
    // MARK: - Outlets
    @IBOutlet weak var sickTimeLabel: UILabel!
    @IBOutlet weak var vacayTimeLabel: UILabel!
    @IBOutlet weak var hourPicker: UIPickerView!
    @IBOutlet weak var timeTypeSwitch: UISwitch!
    
    // MARK: - Required VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sickTimeLabel.text = user?.sickTime.description
        vacayTimeLabel.text = user?.vacayTime.description
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - TableView Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 4
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ((row + 1) * 8).description
    }
    
    // MARK: - Button Methods
    @IBAction func didPressUse(_ sender: UIButton) {
        let comp = hourPicker.selectedRow(inComponent: 0) + 1
        // Seconds in a day - needed for the date.addingTimeInterval
        let dayOffset = 86400
        var dayRef : DatabaseReference = workdayBase!.child(Auth.auth().currentUser!.uid).child((user!.numPeriods - 1).description)
        var curPer : PayPeriod?
        let today : Date = Date.init()
        let perRef = Database.database().reference(fromURL: user!.history)
        var msg : String
        let tInterval = Double (comp * 8)
        
        // Change the field fill types and time use based on
        // whether it's sick time or vacation time to be used
        if !timeTypeSwitch.isOn {
            msg = "Sick"
            self.user!.sickTime -= tInterval
        } else {
            msg = "Vacation"
            self.user!.vacayTime -= tInterval
        }
        
        // Do in background thread
        hiPri.async {
            var i : Int = 0
            var interval : TimeInterval
            
            
            self.fetchGroup.enter()
            // Get the last pay period in the database
            perRef.queryOrderedByKey().queryEqual(toValue: (self.user!.numPeriods - 1).description).observeSingleEvent(of: .value, with: { (perSnap) in
                if perSnap.exists() {
                    curPer = PayPeriod.init(key: (self.user!.numPeriods - 1), snapshot: perSnap)
                } else {
                    print ("Error: no data at: " + perRef.url)
                }
                self.fetchGroup.leave()
            })
            self.fetchGroup.wait()
            
            // If today is not out of the bounds of the current pay period,
            // but the user wants to use enough time to roll over onto a new pay period
             if (self.df.string(from: today.addingTimeInterval(Double(comp * dayOffset))) > self.df.string(from: curPer!.endDate)) {
                // Loop to add sick or vacation days while they are within the bounds of the current pay period
                while (self.df.string(from: today.addingTimeInterval(Double(i * dayOffset))) <= self.df.string(from: curPer!.endDate)) {
                    curPer!.numDays += 1
                    curPer!.totalHours += 8
                    interval = Double (dayOffset * i)
                    let tempDay = Workday.init(date: today.addingTimeInterval(interval), hours: 8, forClient: msg, atLocation: msg, doingJob: msg)
                    
                    dayRef.child((curPer!.numDays - 1).description).setValue(tempDay.toAnyObject())
                    
                    i += 1
                }
                perRef.child((self.user!.numPeriods - 1).description).setValue(curPer!.toAnyObject())
                
                // Make a new period
                // End adds 14 days because pay period is 15 days long
                let newPer = PayPeriod.init(start: curPer!.endDate.addingTimeInterval(Double(dayOffset)), end: today.addingTimeInterval(Double (dayOffset * 14)), hours: 0, days: dayRef.child((self.user!.numPeriods - 1).description).url, numDays: 0)
                self.user!.numPeriods += 1
                
                // Add the new period to the database
                self.fetchGroup.enter()
                perRef.child((self.user!.numPeriods - 1).description).setValue(newPer.toAnyObject())
                self.fetchGroup.leave()
                
                
                // Set the current period to be the new one created
                curPer = newPer
                dayRef = self.workdayBase!.child(Auth.auth().currentUser!.uid).child((self.user!.numPeriods - 1).description)
            }
            // If today and all the time to be used stays within the current pay period
            else {
                dayRef = Database.database().reference(fromURL: curPer!.days)
            }
            
            // Need the main thread here to access the labels
            DispatchQueue.main.async {
                self.sickTimeLabel.text = self.user!.sickTime.description
                self.vacayTimeLabel.text = self.user!.vacayTime.description
            }
            
            self.fetchGroup.wait()
            
            // Loop to add a new day with the fields filled with "Sick" or "Vacation" as appropriate,
            // for as many days as necessary
            while (i < comp) {
                curPer!.numDays += 1
                curPer!.totalHours += 8
                interval = Double (dayOffset * i)
                let tempDay = Workday.init(date: today.addingTimeInterval(interval), hours: 8, forClient: msg, atLocation: msg, doingJob: msg)
                
                dayRef.child((curPer!.numDays - 1).description).setValue(tempDay.toAnyObject())
                
                i += 1
            }
            
            self.userBase!.child(Auth.auth().currentUser!.uid).setValue(self.user!.toAnyObject())
            perRef.child((self.user!.numPeriods - 1).description).setValue(curPer!.toAnyObject())
        }
    }
    @IBAction func didPressChangePage(_ sender: UIButton) {
        let actionSheet = UIAlertController (title: "Change Page", message: nil, preferredStyle: .actionSheet)
        let changeToMenu = UIAlertAction (title: "Menu", style: .default) { (action : UIAlertAction) in
            self.tabBarController?.selectedIndex = 0
        }
        let changeToSchedule = UIAlertAction (title: "View Schedule", style: .default, handler:
        { (action : UIAlertAction) in
            self.tabBarController?.selectedIndex = 1
        })
        let changetoWork = UIAlertAction (title: "Work", style: .default, handler:
        { (action : UIAlertAction) in
            self.tabBarController?.selectedIndex = 2
        })
        let changetoHistory = UIAlertAction (title: "Pay Period History", style: .default, handler:
        { (action : UIAlertAction) in
            self.tabBarController?.selectedIndex = 4
        })
        let cancelAction = UIAlertAction (title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(changeToMenu)
        actionSheet.addAction(changeToSchedule)
        actionSheet.addAction(changetoWork)
        actionSheet.addAction(changetoHistory)
        actionSheet.addAction(cancelAction)
        self.present (actionSheet, animated: true, completion: nil)
    }
}
