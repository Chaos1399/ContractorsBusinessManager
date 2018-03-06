//
//  ETimeBank.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 2/22/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import UIKit

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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 8
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return (row + 1).description
    }
    
    @IBAction func didPressUse(_ sender: UIButton) {
        if !timeTypeSwitch.isOn {
            sickTimeLabel.text = sickTimeLabel.text! + " - \(hourPicker.selectedRow(inComponent: 0) + 1)"
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
