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
    @IBOutlet weak var sickTimeLabel: UILabel!
    @IBOutlet weak var vacayTimeLabel: UILabel!
    @IBOutlet weak var hourPicker: UIPickerView!
    @IBOutlet weak var timeTypeSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sickTimeLabel.text = user?.sickTime.description
        vacayTimeLabel.text = user?.vacayTime.description
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // TableView things
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 4
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ((row + 1) * 8).description
    }
    
    @IBAction func didPressUse(_ sender: UIButton) {
        let dayOffset = 86400
        let df = DateFormatter ()
        df.locale = Locale (identifier: "en_US")
        df.timeStyle = .none
        df.dateFormat = "MM/dd/yy"
        
        sickTimeLabel.text = user!.sickTime.description
        
        if !timeTypeSwitch.isOn {
            
            /*if sickDays == nil {
                user!.history = []
                user!.history!.append (PayPeriod (start: df.date(from: "01/01/18")!, end: df.date(from: "01/15/18")!, period: 0, hours: 8, days: []))
                sickDays = user!.history!.last!.days
            }
            let lastDate : Date = sickDays?.last?.date ?? Date.init()
            for i in 0...hourPicker.selectedRow(inComponent: 0) {
                let nextDate = Date.addingTimeInterval(lastDate) (TimeInterval(dayOffset * (i + 1)))
                let nextDay = Workday.init(date: nextDate, hours: 8.0, done: true, forClient: "Sick", atLocation: "Sick", doingJob: "Sick")
                
                sickTimeLabel.text = sickTimeLabel.text! + " - \(i + 1)"
                
                sickDays!.append (nextDay)
            }
            
            user!.history!.last!.days = sickDays!
            user!.sickTime -= Double ((hourPicker.selectedRow(inComponent: 0) + 1) * 8)
            
            self.userbase!.child(user!.name).setValue(user!.toAnyObject())*/
        } else {
            vacayTimeLabel.text = vacayTimeLabel.text! + " - \(hourPicker.selectedRow(inComponent: 0) + 1)"
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
