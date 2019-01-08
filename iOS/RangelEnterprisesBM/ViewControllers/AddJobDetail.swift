//
//  AddJobDetail.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 3/5/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import UIKit

class AddJobDetail: CustomVCSuper, UITextFieldDelegate {
    // MARK: - Outlets
    @IBOutlet weak var jobField: UITextField!
    @IBOutlet weak var startPicker: UIDatePicker!
    @IBOutlet weak var endPicker: UIDatePicker!
    
    // MARK: - Global Variables
    var job : Job?
    var editingInt : Int = -1
    
    // MARK: - Required VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if job != nil {
            jobField.text = job!.type
            startPicker.setDate(job!.startDate, animated: false)
            endPicker.setDate(job!.endDate, animated: false)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - TextField Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Button Methods
    @IBAction func didPressSubmit(_ sender: UIButton) {
        if jobField.text! == "" {
            self.presentAlert(alertTitle: "Need Job Field", alertMessage: "Need to enter job name", actionTitle: "Ok", cancelTitle: nil, actionHandler: nil, cancelHandler: nil)
        } else {
            job = Job.init (type: jobField.text!, start: startPicker.date, end: endPicker.date, details: nil)
            performSegue(withIdentifier: "unwindToAddJobWithSub", sender: nil)
        }
    }
    @IBAction func didPressCancel(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindToAddJobWithCancel", sender: nil)
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToAddJobWithSub" {
            let destVC = segue.destination as! AAddJob
            if editingInt >= 0 {
                destVC.editRow (job: job!, index: editingInt)
            } else {
                destVC.addRow (job!)
            }
        }
    }
}
