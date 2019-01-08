//
//  AeditProfile.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 3/3/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import UIKit
import FirebaseDatabase

class AeditProfile: CustomVCSuper, UITextFieldDelegate {
    // MARK: - Outlets
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var payField: UITextField!
    @IBOutlet weak var sickField: UITextField!
    @IBOutlet weak var vacaField: UITextField!
    @IBOutlet weak var adminSwitch: UISwitch!
    @IBOutlet weak var dButton: UIButton!
    @IBOutlet weak var sButton: UIButton!
    
    // MARK: - Required VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dButton.isEnabled = false
        sButton.isEnabled = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - TextField Method
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if nameField.hasText {
            dButton.isEnabled = true
            sButton.isEnabled = true
        } else {
            dButton.isEnabled = false
            sButton.isEnabled = false
        }
        
        return true
    }
    
    // MARK: - Button Methods
    @IBAction func didPressSubmit(_ sender: UIButton) {
        self.userBase!.queryOrderedByKey().queryEqual(toValue: nameField.text!).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                let tempU = CustomUser.init(key: self.nameField.text!, snapshot: snapshot)
                
                if self.emailField.hasText {
                    tempU.email = self.emailField.text!
                }
                if self.payField.hasText {
                    tempU.pph = Double (self.payField.text!)!
                }
                if self.sickField.hasText {
                    tempU.sickTime = Double (self.sickField.text!)!
                }
                if self.vacaField.hasText {
                    tempU.vacayTime = Double (self.vacaField.text!)!
                }
                if self.adminSwitch.isOn {
                    tempU.admin = true
                } else {
                    tempU.admin = false
                }
                
                self.userBase!.child(self.nameField.text!).setValue(tempU.toAnyObject())
            }
        })
        
        performSegue(withIdentifier: "unwindToPrev", sender: nil)
    }
    @IBAction func didPressCancel(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindToPrev", sender: nil)
    }
    @IBAction func didPressDelete(_ sender: UIButton) {
        self.userBase!.queryOrderedByKey().queryEqual(toValue: nameField.text!).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                self.userBase!.child(self.nameField.text!).removeValue()
            }
            else {
                let alert = UIAlertController (title: "Error", message: "User not found, please check your spelling.\nIt is case sensitive.", preferredStyle: .alert)
                let action = UIAlertAction (title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present (alert, animated: true, completion: nil)
            }
        })
        performSegue(withIdentifier: "unwindToPrev", sender: nil)
    }
}
