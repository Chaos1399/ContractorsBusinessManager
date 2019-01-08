//
//  AReviseHours.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 2/22/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

// TODO: Add Dropdown like AAddJob

import UIKit
import FirebaseDatabase

class AReviseHours: CustomVCSuper, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
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
    @IBOutlet weak var wPicker: UIPickerView!
    @IBOutlet weak var cPicker: UIPickerView!
    @IBOutlet weak var lPicker: UIPickerView!
    @IBOutlet weak var jPicker: UIPickerView!
    
    // MARK: - Global Variables
    let cal = Calendar.init(identifier: .gregorian)
    var selectedDay : Date?
    var startTime : Date?
    var endTime : Date?
    var locList : [Location] = []
    var jobList : [String] = []
    var selectedUser : Int = -1
    var selectedClient : Int = -1
    var selectedLoc : Int = -1
    var selectedJob : Int = -1
    
    // MARK: - Required VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        subButton.isEnabled = false
        
        wPicker.isHidden = true
        cPicker.isHidden = true
        lPicker.isHidden = true
        jPicker.isHidden = true
    }
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
    
    // MARK: - TextField Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if nameField.hasText &&
            ((clientField.hasText && locationField.hasText && jobField.hasText) ||
            (sickSwitch.isOn || vacaySwitch.isOn)) {
            subButton.isEnabled = true
        } else {
            subButton.isEnabled = false
        }
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == nameField {
            wPicker.isHidden = false
            wPicker.reloadComponent(0)
        } else if textField == clientField {
            cPicker.isHidden = false
            cPicker.reloadComponent(0)
        } else if textField == locationField {
            if (clientField.text == "") {
                self.presentAlert(alertTitle: "Choose client", alertMessage: "Choose a client before choosing a location", actionTitle: "Ok", cancelTitle: nil, actionHandler: nil, cancelHandler: nil)
                return
            }
            lPicker.isHidden = false
            lPicker.reloadComponent(0)
        } else if textField == jobField {
            if (clientField.text == "" || locationField.text == "") {
                self.presentAlert(alertTitle: "Choose client or location", alertMessage: "Choose both a client and a location before choosing a job", actionTitle: "Ok", cancelTitle: nil, actionHandler: nil, cancelHandler: nil)
                return
            }
            jPicker.isHidden = false
            jPicker.reloadComponent(0)
        }
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        wPicker.isHidden = true
        cPicker.isHidden = true
        lPicker.isHidden = true
        jPicker.isHidden = true
        
        return true
    }
    
    // MARK: - PickerView Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == wPicker {
            return employeeNameList.count
        } else if pickerView == cPicker {
            return clientNameList.count
        } else if pickerView == lPicker {
            return locList.count
        } else {
            return jobList.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var attributedString : NSAttributedString
        
        if pickerView == wPicker {
            attributedString = NSAttributedString(string: employeeNameList[row], attributes: [NSAttributedStringKey.foregroundColor : UIColor.white])
        } else if pickerView == cPicker {
            attributedString = NSAttributedString(string: clientNameList[row], attributes: [NSAttributedStringKey.foregroundColor : UIColor.white])
        } else if pickerView == lPicker {
            attributedString = NSAttributedString(string: locList[row].address + ", " + locList[row].city, attributes: [NSAttributedStringKey.foregroundColor : UIColor.white])
        } else {
            attributedString = NSAttributedString(string: jobList[row], attributes: [NSAttributedStringKey.foregroundColor : UIColor.white])
        }
        
        return attributedString
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == wPicker {
            self.nameField.text = self.employeeNameList[row]
            selectedUser = row
        } else if pickerView == cPicker {
            self.clientField.text = self.clientNameList[row]
            selectedClient = row
            hiPri.async {
                self.fetchLocs()
            }
        } else if pickerView == lPicker {
            self.locationField.text = self.locList[row].address + ", " + self.locList[row].city
            selectedLoc = row
            hiPri.async {
                self.fetchJobs()
            }
        } else {
            self.jobField.text = self.jobList[row]
            selectedJob = row
        }
        
        if nameField.hasText &&
            ((clientField.hasText && locationField.hasText && jobField.hasText) ||
                (sickSwitch.isOn || vacaySwitch.isOn)) {
            subButton.isEnabled = true
        } else {
            subButton.isEnabled = false
        }
        
        pickerView.isHidden = true
    }
    
    
    // MARK: - Button Methods
    @IBAction func didSelectSubmit(_ sender: UIButton) {
        if startTime == nil || endTime == nil || selectedDay == nil {
            self.presentAlert(alertTitle: "Error", alertMessage: "You didn't input an updated day and time", actionTitle: "Ok", cancelTitle: nil, actionHandler: nil, cancelHandler: nil)
            return
        }
        
        let location = locationField.text!
        let job = jobField.text!
        
        hiPri.async {
            self.fetchGroup.enter()
            self.userBase!.queryOrderedByKey().queryEqual(toValue: self.employeeUidList[self.selectedUser]).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    let person = CustomUser.init(key: self.employeeUidList[self.selectedUser], snapshot: snapshot)
                    
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
                                                    
                                                    if self.selectedClient > -1 {
                                                        day.client = self.clientNameList[self.selectedClient]
                                                    }
                                                    if self.selectedLoc > -1 {
                                                        day.location = location
                                                    }
                                                    if self.selectedJob > -1 {
                                                        day.job = job
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
                                                    self.userBase!.child(self.employeeUidList[self.selectedUser]).setValue(person.toAnyObject())
                                                    
                                                    dayRef.child(j.description).setValue(day.toAnyObject())
                                                    
                                                    // update payperiod hours
                                                    period.totalHours += (newHours - oldHours)
                                                    pphRef.child(i.description).setValue(period.toAnyObject())
                                                }
                                            }
                                            self.fetchGroup.leave()
                                        })
                                    } // End for period.numDays loop
                                } // End if
                            }
                            self.fetchGroup.leave()
                        })
                    }
                } else {
                    self.presentAlert(alertTitle: "Error", alertMessage: "Cannot find employee: " + self.employeeNameList[self.selectedUser], actionTitle: "Ok", cancelTitle: nil, actionHandler: nil, cancelHandler: nil)
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
    
    // MARK: - Custom Methods
    func fetchLocs () {
        self.fetchGroup.enter()
        self.clientBase!.queryOrderedByKey().queryEqual(toValue: self.selectedClient.description).observeSingleEvent(of: .value, with: { (cSnap) in
            if cSnap.exists() {
                let tempClient = Client.init(key: self.selectedClient, snapshot: cSnap)
                
                let locRef = Database.database().reference(fromURL: tempClient.properties)
                
                for i in 0..<tempClient.numProps {
                    self.fetchGroup.enter()
                    locRef.queryOrderedByKey().queryEqual(toValue: i.description).observeSingleEvent(of: .value, with: { (lSnap) in
                        if lSnap.exists() {
                            self.locList.append(Location.init(key: i, snapshot: lSnap))
                        }
                        self.fetchGroup.leave()
                    })
                }
            }
            self.fetchGroup.leave()
        })
    }
    func fetchJobs () {
        let jobRef = Database.database().reference(fromURL: locList[self.selectedLoc].jobs)
        
        for i in 0..<locList[self.selectedLoc].numJobs {
            self.fetchGroup.enter()
            jobRef.queryOrderedByKey().queryEqual(toValue: i.description).observeSingleEvent(of: .value, with: { (snap) in
                if snap.exists() {
                    let tempJob = Job.init(key: i, snapshot: snap)
                    self.jobList.append(tempJob.type)
                }
                self.fetchGroup.leave()
            })
        }
    }
    
    // MARK: - Segues
    @IBAction func unwindToReviseHours (_ segue: UIStoryboardSegue) {}
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
