//
//  ETimeBank.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 2/22/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import UIKit
import FirebaseDatabase

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
        let dayOffset = 86400
        var dayRef : DatabaseReference?
        var curPer : PayPeriod?
        var lastDay : Date = Date.init()
        let perRef = Database.database().reference(fromURL: user!.history)
        var msg : String = "Sick"
        let sick_vacayTime = Double ((hourPicker.selectedRow(inComponent: 0) + 1) * 8)
        
        if !timeTypeSwitch.isOn {
            msg = "Sick"
            self.user!.sickTime -= sick_vacayTime
        } else {
            msg = "Vacation"
            self.user!.vacayTime -= sick_vacayTime
        }
        self.userBase!.child(self.user!.name).setValue(self.user!.toAnyObject())
        
        hiPri.async {
            self.fetchGroup.enter()
            perRef.queryOrderedByKey().queryEqual(toValue: (self.user!.numPeriods - 1).description).observeSingleEvent(of: .value, with: { (perSnap) in
                if perSnap.exists() {
                    curPer = PayPeriod.init(key: (self.user!.numPeriods - 1), snapshot: perSnap)
                    
                    dayRef = Database.database().reference(fromURL: curPer!.days)
                }
                self.fetchGroup.leave()
            })
            self.fetchGroup.wait()
            
            self.fetchGroup.enter()
            dayRef!.queryOrderedByKey().queryEqual(toValue: (curPer!.numDays - 1).description).observeSingleEvent(of: .value, with: { (daySnap) in
                if daySnap.exists() {
                    lastDay = Workday.init(key: (curPer!.numDays - 1), snapshot: daySnap).date
                }
                self.fetchGroup.leave()
            })
            
            self.fetchGroup.wait()
            DispatchQueue.main.async {
                if dayRef != nil {
                    var i : Int = 0
                    var interval : TimeInterval = Double(dayOffset)
                    
                    repeat {
                        curPer!.numDays += 1
                        curPer!.totalHours += 8
                        self.sickTimeLabel.text = self.user!.sickTime.description
                        self.vacayTimeLabel.text = self.user!.vacayTime.description
                        if i != 0 { interval = Double (dayOffset * i) }
                        
                        dayRef!.child((curPer!.numDays - 1).description).setValue(Workday.init(date: Date.init(timeInterval: interval, since: lastDay), hours: 8, done: true, forClient: msg, atLocation: msg, doingJob: msg).toAnyObject())
                        self.historyBase!.child(self.user!.name).child(curPer!.number.description).setValue(curPer!.toAnyObject())
                        
                        i += 1
                    } while i <= self.hourPicker.selectedRow(inComponent: 0)
                    
                    self.fetchGroup.wait()
                } else {
                    self.presentAlert(alertTitle: "Error", alertMessage: "Something bad happened", actionTitle: "Umm?", cancelTitle: nil, actionHandler: nil, cancelHandler: nil)
                }
            }
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
