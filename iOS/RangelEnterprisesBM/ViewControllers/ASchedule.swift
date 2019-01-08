//
//  ASchedule.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 2/22/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ASchedule: CustomVCSuper, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    // MARK: - Outlets
    @IBOutlet weak var scheduleList: UITableView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    
    // MARK: - Global Variables
    var selectedDate : Date?
    var scheduledDays : [ScheduledWorkday] = []
    
    // MARK: - Required VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scheduleList.isHidden = true
        addButton.isHidden = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - TextField Method
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if nameField.hasText {
            scheduleList.isHidden = false
            addButton.isHidden = false
            let name = nameField.text!
            var uid : String = ""
            for i in 0..<self.employeeNameList.count {
                if name == self.employeeNameList[i] {
                    uid = self.employeeUidList[i]
                    break
                }
            }
            
            if uid == "" {
                self.presentAlert(alertTitle: "Incorrect Spelling", alertMessage: "Check that you spelled the employee's name correctly.\nAlso check that you put the last name.", actionTitle: "Ok", cancelTitle: nil, actionHandler: nil, cancelHandler: nil)
            }
            
            hiPri.async {
                self.fetchScheduledDays(forPerson: uid)
                self.fetchGroup.wait()
                DispatchQueue.main.async {
                    self.scheduleList.reloadData()
                }
            }
        } else {
            scheduleList.isHidden = true
            addButton.isHidden = true
        }
        
        return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        scheduledDays = []
        scheduleList.reloadData()
        scheduleList.isHidden = true
        addButton.isHidden = true
        
        return true
    }
    
    // MARK: - TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scheduledDays.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleCell") as! scheduleCell
        let row = indexPath.row
        
        cell.placeLabel.text = scheduledDays [row].location
        cell.startLabel.text = self.df.string(from: scheduledDays [row].startDate)
        cell.endLabel.text = self.df.string(from: scheduledDays [row].endDate)
        cell.jobLabel.text = scheduledDays [row].job
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToEditSchedule", sender: indexPath.row)
    }
    
    // MARK: - Custom Methods
    func fetchScheduledDays (forPerson person: String) {
        self.fetchGroup.enter()
        self.userBase!.queryOrderedByKey().queryEqual(toValue: person).observeSingleEvent(of: .value, with: { (userSnap) in
            if userSnap.exists() {
                let tempPerson = CustomUser.init(key: person, snapshot: userSnap)
                let toWorkRef = Database.database().reference(fromURL: tempPerson.toWork)
                
                for i in 0..<tempPerson.numDaysScheduled {
                    self.fetchGroup.enter()
                    toWorkRef.queryOrderedByKey().queryEqual(toValue: i.description).observeSingleEvent(of: .value, with: { (toWorkSnap) in
                        if toWorkSnap.exists() {
                            self.scheduledDays.append(ScheduledWorkday.init(key: i, snapshot: toWorkSnap))
                        }
                        self.fetchGroup.leave()
                    })
                }
            } else {
                self.presentAlert(alertTitle: "Error", alertMessage: "Check spelling of employee name", actionTitle: "Ok", cancelTitle: nil, actionHandler: nil, cancelHandler: nil)
            }
            self.fetchGroup.leave()
        })
    }

    // MARK: - Button Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToEditSchedule" {
            let destVC = segue.destination as! AAddToSchedule
            let sender = sender as! Int
            
            destVC.dayToAdd = scheduledDays [sender]
            destVC.editingInt = sender
        }
    }
    @IBAction func didPressAdd(_ sender: UIButton) {
        performSegue(withIdentifier: "addToSchedule", sender: nil)
    }
    @IBAction func didPressBack(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindToCalendar", sender: nil)
    }
    @IBAction func unwindToSchedule(_ sender: UIStoryboardSegue) {
        let name = nameField.text!
        var uid : String = ""
        for i in 0..<self.employeeNameList.count {
            if name == self.employeeNameList[i] {
                uid = self.employeeUidList[i]
                break
            }
        }
        hiPri.async {
            self.userBase!.queryOrderedByKey().queryEqual(toValue: uid).observeSingleEvent(of: .value, with: { (userSnap) in
                if userSnap.exists() {
                    let tempPerson = CustomUser.init(key: uid, snapshot: userSnap)
                    let toWorkRef = Database.database().reference(fromURL: tempPerson.toWork)
                    
                    for i in 0..<self.scheduledDays.count {
                        toWorkRef.child(i.description).setValue(self.scheduledDays [i].toAnyObject())
                    }
                    
                    tempPerson.numDaysScheduled = self.scheduledDays.count
                    self.userBase!.child(uid).setValue(tempPerson.toAnyObject())
                } else {
                    print ("No data found")
                }
            })
        }
    }
}
