//
//  AAddToSchedule.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 3/13/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import UIKit

class AAddToSchedule: CustomVCSuper, UITextFieldDelegate {
    // MARK: - Outlets
    @IBOutlet weak var clientField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var jobField: UITextField!
    @IBOutlet weak var startPicker: UIDatePicker!
    @IBOutlet weak var endPicker: UIDatePicker!
    @IBOutlet weak var subButton: UIButton!
    
    // MARK: - Global Variables
    var dayToAdd : ScheduledWorkday?
    var editingInt : Int = -1
    
    // MARK: - Required VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if dayToAdd != nil {
            clientField.text = dayToAdd!.client
            locationField.text = dayToAdd!.location
            jobField.text = dayToAdd!.job
            startPicker.setDate(dayToAdd!.startDate, animated: false)
            endPicker.setDate(dayToAdd!.endDate, animated: false)
            subButton.isEnabled = true
        } else {
            subButton.isEnabled = false
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - TextField Method
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if clientField.hasText && locationField.hasText && jobField.hasText {
            subButton.isEnabled = true
        }
        
        return true
    }
    
    // MARK: - Button Methods
    @IBAction func didPressSubmit(_ sender: UIButton) {
        dayToAdd = ScheduledWorkday.init(client: clientField.text!, loc: locationField.text!, job: jobField.text!, startDate: startPicker.date, endDate: endPicker.date)
        
        performSegue(withIdentifier: "unwindToScheduleWithSub", sender: nil)
    }
    @IBAction func didPressCancel(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindToScheduleWithCancel", sender: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToScheduleWithSub" {
            let destVC = segue.destination as! ASchedule
            
            if editingInt >= 0 {
                destVC.scheduledDays [editingInt] = dayToAdd!
            } else {
                destVC.scheduledDays.append(dayToAdd!)
            }
            
            destVC.scheduleList.reloadData()
        }
    }
}
