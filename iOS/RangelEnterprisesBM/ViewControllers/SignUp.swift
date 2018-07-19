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
    // MARK: - Outlets
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passField: UITextField!
    @IBOutlet weak var pphField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    // MARK: - Required VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        signUpButton.isEnabled = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - TextField Method
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
    
    // MARK: - Custom Methods
    func fetchLatestPayPeriod () -> PayPeriod {
        var retval : PayPeriod?
        
        self.fetchGroup.enter()
        self.userBase!.queryOrderedByKey().queryEqual(toValue: "Admin").observeSingleEvent(of: .value, with: { (userSnap) in
            if userSnap.exists() {
                let admin = User.init(key: "Admin", snapshot: userSnap)
                let pphRef = Database.database().reference(fromURL: admin.history)
                let paynum = admin.numPeriods - 1
                
                self.fetchGroup.enter()
                pphRef.queryOrderedByKey().queryEqual(toValue: paynum.description).observeSingleEvent(of: .value, with: { (perSnap) in
                    if perSnap.exists() {
                        retval = PayPeriod.init(key: paynum, snapshot: perSnap)
                    }
                    self.fetchGroup.leave()
                })
            }
            self.fetchGroup.leave()
        })
        
        self.fetchGroup.wait()
        return retval!
    }
    
    // MARK: - Button Methods
    @IBAction func didPressSignUp(_ sender: UIButton) {
        let name = nameField.text!
        let toWorkURL = scheduleBase!.url + "/" + name
        let payURL = Database.database().reference().url + "/Pay Period Histories/" + name
        self.user = User (name: name, email: self.emailField.text!, payPerHour: Double (self.pphField.text!)!, sickTime: 0.0, vacayTime: 0.0, admin: false, scheduledWork: toWorkURL, numDays: 0, payPeriodHistory: payURL, numPayPeriods: 1)
        userBase!.child(name).setValue(self.user!.toAnyObject())
        self.employeeNameList.append(name)
        self.updatePersistentStorage(setClient: false)
        
        hiPri.async {
            var latestPP : PayPeriod = self.fetchLatestPayPeriod()
            self.fetchGroup.wait()
            
            latestPP.days = self.workdayBase!.url + "/" + name + 0.description
            Database.database().reference(fromURL: payURL).child("0").setValue(latestPP.toAnyObject())
            
            self.fetchGroup.wait()
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "unwindToPrev", sender: nil)
            }
        }
    }
    @IBAction func didPressCancel(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindToPrev", sender: nil)
    }
}
