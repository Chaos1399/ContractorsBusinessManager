//
//  AddJobDetail.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 3/5/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import UIKit

class AddJobDetail: CustomVCSuper, UITextFieldDelegate {
    @IBOutlet weak var jobField: UITextField!
    @IBOutlet weak var startPicker: UIDatePicker!
    @IBOutlet weak var endPicker: UIDatePicker!
    
    var job : Job?
    
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func didPressSubmit(_ sender: UIButton) {
        job = Job.init (type: jobField.text!, start: startPicker.date, end: endPicker.date, details: nil)
        
        performSegue(withIdentifier: "unwindToAddJob", sender: job!)
    }
    
    @IBAction func didPressCancel(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindToAddJob", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as? AAddJob
        if let newjob = sender as? Job {
            destVC?.addRow(newjob)
        }
    }
}
