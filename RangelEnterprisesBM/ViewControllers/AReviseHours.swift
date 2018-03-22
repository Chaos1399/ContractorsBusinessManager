//
//  AReviseHours.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 2/22/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import UIKit
import FirebaseDatabase

class AReviseHours: CustomVCSuper, UITextFieldDelegate {
    // MARK: - Outlets
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var clientField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var jobField: UITextField!
    @IBOutlet weak var sickSwitch: UISwitch!
    @IBOutlet weak var vacaySwitch: UISwitch!
    @IBOutlet weak var subButton: UIButton!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    // MARK: - Global Variables
    let cal = Calendar.init(identifier: .gregorian)
    var selectedDay : Date?
    var startTime : Date?
    var endTime : Date?
    
    // MARK: - Required VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        subButton.isEnabled = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - TextField Method
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if nameField.hasText &&
            ((clientField.hasText && locationField.hasText && jobField.hasText) ||
            (sickSwitch.isOn || vacaySwitch.isOn)) {
            subButton.isEnabled = true
        }
        else {
            subButton.isEnabled = false
        }
        return true
    }
    
    // MARK: - Button Methods
    @IBAction func didSelectSubmit(_ sender: UIButton) {
        if startTime == nil || endTime == nil || selectedDay == nil {
            self.presentAlert(alertTitle: "Error", alertMessage: "You didn't input an updated day and/or time", actionTitle: "Ok", cancelTitle: nil, actionHandler: nil, cancelHandler: nil)
            return
        }
        
        let name = nameField.text!
        let client = clientField.text
        let location = locationField.text
        let job = jobField.text
        
        hiPri.async {
            self.fetchGroup.enter()
            self.userBase!.queryOrderedByKey().queryEqual(toValue: name).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    let person = User.init(key: name, snapshot: snapshot)
                    
                    let pphRef = Database.database().reference(fromURL: person.history)
                    
                    // go through each pay period, checking the start date against the pay period bounds
                    for i in 0..<person.numPeriods {
                        self.fetchGroup.enter()
                        pphRef.queryOrderedByKey().queryEqual(toValue: i.description).observeSingleEvent(of: .value, with: { (perSnap) in
                            if perSnap.exists() {
                                let period = PayPeriod.init(key: i, snapshot: perSnap)
                                let dayRef = Database.database().reference(fromURL: period.days)
                                
                                let sPickerYear = self.cal.component(.year, from: self.startTime!)
                                let sPickerMonth = self.cal.component(.month, from: self.startTime!)
                                let sPickerDay = self.cal.component(.day, from: self.startTime!)
                                
                                let ePickerYear = self.cal.component(.year, from: self.endTime!)
                                let ePickerMonth = self.cal.component(.month, from: self.endTime!)
                                let ePickerDay = self.cal.component(.day, from: self.endTime!)
                                
                                let persYear = self.cal.component(.year, from: period.startDate)
                                let persMonth = self.cal.component(.month, from: period.startDate)
                                let persDay = self.cal.component(.day, from: period.startDate)
                                
                                let pereYear = self.cal.component(.year, from: period.endDate)
                                let pereMonth = self.cal.component(.month, from: period.endDate)
                                let pereDay = self.cal.component(.day, from: period.endDate)
                                
                                // pay period bounds checking
                                if ((persYear <= sPickerYear) && (pereYear >= sPickerYear) &&
                                    ((persMonth < sPickerMonth) || ((persMonth == sPickerMonth) && (persDay <= sPickerDay))) &&
                                    ((pereMonth > sPickerMonth) || ((pereMonth == sPickerMonth) && (pereDay >= sPickerDay)))) &&
                                    ((persYear <= ePickerYear) && (pereYear >= ePickerYear) &&
                                        ((persMonth < ePickerMonth) || ((persMonth == ePickerMonth) && (persDay <= ePickerDay))) &&
                                        ((pereMonth > ePickerMonth) || ((pereMonth == ePickerMonth) && (pereDay >= ePickerDay)))) {
                                    // go through each day, checking the start date against the workday date
                                    for j in 0..<period.numDays {
                                        self.fetchGroup.enter()
                                        dayRef.queryOrderedByKey().queryEqual(toValue: j.description).observeSingleEvent(of: .value, with: { (daySnap) in
                                            if daySnap.exists() {
                                                let day = Workday.init(key: j, snapshot: daySnap)
                                                
                                                let tempYear = self.cal.component(.year, from: day.date)
                                                let tempMonth = self.cal.component(.month, from: day.date)
                                                let tempDay = self.cal.component(.day, from: day.date)
                                                
                                                if sPickerYear == tempYear && sPickerMonth == tempMonth && sPickerDay == tempDay {
                                                    let newHours = (self.endTime!.timeIntervalSince(self.startTime!) / 3600)
                                                    let oldHours = day.hours
                                                    
                                                    day.hours = newHours
                                                    
                                                    let checkOldVal = day.client
                                                    
                                                    if client != "" {
                                                        day.client = client!
                                                    }
                                                    if location != "" {
                                                        day.location = location!
                                                    }
                                                    if job != "" {
                                                        day.job = job!
                                                    }
                                                    
                                                    // set the Workday Client, Location, and Job fields, and update user sicktime / vacation hours as necessary
                                                    if self.sickSwitch.isOn {
                                                        day.client = "Sick"
                                                        day.location = "Sick"
                                                        day.job = "Sick"
                                                        
                                                        if checkOldVal != "Sick" {
                                                            person.sickTime -= newHours
                                                        } else {
                                                            person.sickTime += (newHours - oldHours)
                                                        }
                                                    } else if self.vacaySwitch.isOn {
                                                        day.client = "Vacation"
                                                        day.location = "Vacation"
                                                        day.job = "Vacation"
                                                        
                                                        if checkOldVal != "Vacation" {
                                                            person.vacayTime -= newHours
                                                        } else {
                                                            person.vacayTime += (newHours - oldHours)
                                                        }
                                                    }
                                                    
                                                    if checkOldVal == "Vacation" {
                                                        person.vacayTime += newHours
                                                    } else if checkOldVal == "Sick" {
                                                        person.sickTime += newHours
                                                    }
                                                    self.userBase!.child(name).setValue(person.toAnyObject())
                                                    
                                                    dayRef.child(j.description).setValue(day.toAnyObject())
                                                    
                                                    // update payperiod hours
                                                    period.totalHours += (newHours - oldHours)
                                                    pphRef.child(i.description).setValue(period.toAnyObject())
                                                }
                                            }
                                            self.fetchGroup.leave()
                                        })
                                    }
                                }
                            }
                            self.fetchGroup.leave()
                        })
                    }
                } else {
                    self.presentAlert(alertTitle: "Error", alertMessage: "Cannot find employee: " + name, actionTitle: "Ok", cancelTitle: nil, actionHandler: nil, cancelHandler: nil)
                }
                self.fetchGroup.leave()
            })
        }
    }
    @IBAction func didSelectChoose(_ sender: UIButton) {
        performSegue(withIdentifier: "goToChooseDate", sender: nil)
    }
    @IBAction func didSelectCancel(_ sender: UIButton) {
        self.tabBarController?.selectedIndex = 0
    }
    @IBAction func didSelectSick(_ sender: UISwitch) {
        if sickSwitch.isOn {
            vacaySwitch.setOn(false, animated: true)
            subButton.isEnabled = true
        } else if vacaySwitch.isOn {
            subButton.isEnabled = true
        } else {
            subButton.isEnabled = false
        }
    }
    @IBAction func didSelectVacation(_ sender: UISwitch) {
        if vacaySwitch.isOn {
            sickSwitch.setOn(false, animated: true)
            subButton.isEnabled = true
        } else if sickSwitch.isOn {
            subButton.isEnabled = true
        } else {
            subButton.isEnabled = false
        }
    }
    @IBAction func didPressChangePage(_ sender: UIButton) {
        let actionSheet = UIAlertController (title: "Change Page", message: nil, preferredStyle: .actionSheet)
        let changeToMenu = UIAlertAction (title: "Menu", style: .default, handler: { (action : UIAlertAction) in
            self.tabBarController?.selectedIndex = 0
        })
        let changetoCountHours = UIAlertAction (title: "Count Hours", style: .default, handler:
        { (action : UIAlertAction) in
            self.tabBarController?.selectedIndex = 1
        })
        let changetoSchedule = UIAlertAction (title: "Schedule", style: .default, handler:
        { (action : UIAlertAction) in
            self.tabBarController?.selectedIndex = 2
        })
        let changeToAddJob = UIAlertAction (title: "Add Job", style: .default, handler:
        { (action : UIAlertAction) in
            self.tabBarController?.selectedIndex = 3
        })
        let cancelAction = UIAlertAction (title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction (changeToMenu)
        actionSheet.addAction (changetoCountHours)
        actionSheet.addAction (changetoSchedule)
        actionSheet.addAction (changeToAddJob)
        actionSheet.addAction (cancelAction)
        self.present (actionSheet, animated: true, completion: nil)
    }
    
    // MARK: - Segues
    @IBAction func unwindToReviseHours (_ segue: UIStoryboardSegue) {}
    override func viewWillAppear(_ animated: Bool) {
        if selectedDay != nil && startTime != nil && endTime != nil {
            let formatter = DateFormatter ()
            formatter.timeStyle = .short
            formatter.dateStyle = .none
            
            dateLabel.text = df.string(from: selectedDay!)
            startLabel.text = formatter.string(from: startTime!)
            endLabel.text = formatter.string(from: endTime!)
        } else {
            dateLabel.text = ""
            startLabel.text = ""
            endLabel.text = ""
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToChooseDate" {
            let destVC = segue.destination as! DateTimeChoose
            
            if selectedDay != nil && startTime != nil && endTime != nil {
                destVC.selectedDay = selectedDay!
                destVC.startTime = startTime!
                destVC.endTime = endTime!
            }
        }
    }
}
