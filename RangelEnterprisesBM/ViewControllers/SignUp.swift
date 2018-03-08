//
//  SignUp.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 2/22/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import UIKit
import FirebaseDatabase

class SignUp: CustomVCSuper, UITextFieldDelegate {
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passField: UITextField!
    @IBOutlet weak var pphField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signUpButton.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if nameField.hasText && emailField.hasText && passField.hasText && pphField.hasText {
            signUpButton.isEnabled = true
        }
        else {
            signUpButton.isEnabled = false
        }
        
        return true
    }
    
    @IBAction func didPressSignUp(_ sender: UIButton) {
        let toWorkURL = Database.database().reference().child("Schedules").child(self.nameField.text!).url
        self.user = User (name: self.nameField.text!, password: self.passField.text!, email: self.emailField.text!, payPerHour: Double (self.pphField.text!)!, sickTime: 0.0, vacayTime: 0.0, admin: false, scheduledWork: toWorkURL, numDays: 0, payPeriodHistory: self.historyBase!.child(self.nameField.text!).url, numPayPeriods: 0)
        userBase!.child(nameField.text!).setValue(self.user?.toAnyObject())
        
        performSegue(withIdentifier: "unwindToPrev", sender: nil)
    }
    
    @IBAction func didPressCancel(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindToPrev", sender: nil)
    }
}
