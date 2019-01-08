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
    @IBOutlet weak var clientLabel: UILabel!
    @IBOutlet weak var locLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!
    @IBOutlet weak var startPicker: UIDatePicker!
    @IBOutlet weak var endPicker: UIDatePicker!
    @IBOutlet weak var subButton: UIButton!
    
    // MARK: - Global Variables
    var dayToAdd : ScheduledWorkday?
    var editingInt : Int = -1
    var selectedClient : String?
    var selectedLocation : Location?
    var selectedJob : String?
    
    // MARK: - Required VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if dayToAdd != nil {
            clientLabel!.text = dayToAdd!.client
            locLabel!.text = dayToAdd!.location
            jobLabel!.text = dayToAdd!.job
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
    
    // MARK: - Button Methods
    @IBAction func didPressSubmit(_ sender: UIButton) {
        dayToAdd = ScheduledWorkday.init(client: clientLabel.text!, loc: locLabel.text!, job: jobLabel.text!, startDate: startPicker.date, endDate: endPicker.date)
        
        performSegue(withIdentifier: "unwindToScheduleWithSub", sender: nil)
    }
    @IBAction func didPressCancel(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindToScheduleWithCancel", sender: nil)
    }
    @IBAction func didPressChoose(_ sender: UIButton) {
        performSegue(withIdentifier: "goToJobChoose", sender: nil)
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToScheduleWithSub" {
            let destVC = segue.destination as! ASchedule
            
            if editingInt >= 0 {
                destVC.scheduledDays [editingInt] = dayToAdd!
            } else {
                destVC.scheduledDays.append(dayToAdd!)
            }
            
            destVC.scheduleList.reloadData()
        } else if segue.identifier == "goToJobChoose" {
            let destVC = segue.destination as! JobChoose
            
            destVC.dest = 2
        }
    }
    @IBAction func unwindToAddToSchedule (segue: UIStoryboardSegue) {
        if selectedClient != nil {
            subButton.isEnabled = true
            clientLabel.text = selectedClient
            locLabel.text = selectedLocation!.address + ", " + selectedLocation!.city
            jobLabel.text = selectedJob
        }
    }
}
