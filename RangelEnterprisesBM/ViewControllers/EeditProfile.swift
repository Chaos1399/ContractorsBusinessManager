//
//  EeditProfile.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 3/3/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import UIKit
import FirebaseDatabase

class EeditProfile: CustomVCSuper, UITextFieldDelegate {
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passField: UITextField!
    @IBOutlet weak var confirmField: UITextField!
    @IBOutlet weak var subButton: UIButton!
    
    var userbase : DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userbase = Database.database().reference().child("Users")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    @IBAction func didPressSubmit(_ sender: UIButton) {
        self.userbase?.queryOrderedByKey().queryEqual(toValue: user!.name).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                let tempU = User.init(key: self.user!.name, snapshot: snapshot)
                
                if self.nameField.hasText {
                    tempU.name = self.nameField.text! }
                if self.emailField.hasText {
                    tempU.email = self.emailField.text! }
                
                if self.passField.hasText && self.confirmField.hasText && self.passField.text! == self.confirmField.text! {
                    print ("in change")
                    tempU.password = self.passField.text! }
                else if self.passField.hasText && self.confirmField.hasText {
                    print ("fields don't match")
                    let alert = UIAlertController (title: "Error", message: "Password and Confirm fields don't match", preferredStyle: .alert)
                    let action = UIAlertAction (title: "Ok", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present (alert, animated: true, completion: nil)
                }
                else if self.passField.hasText && !self.confirmField.hasText {
                    print ("confirm no text")
                    let alert = UIAlertController (title: "Error", message: "Confirm field required to change password", preferredStyle: .alert)
                    let action = UIAlertAction (title: "Ok", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present (alert, animated: true, completion: nil)
                }
                else if !self.passField.hasText && self.confirmField.hasText {
                    print ("pass no text")
                    let alert = UIAlertController (title: "Error", message: "Password field required to change password", preferredStyle: .alert)
                    let action = UIAlertAction (title: "Ok", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present (alert, animated: true, completion: nil)
                }
                
                let tempRef = self.userbase?.child(self.user!.name)
                tempRef?.setValue(tempU.toAnyObject(withRef: tempRef!))
            }
        })
        
        self.performSegue(withIdentifier: "unwindToPrev", sender: nil)
    }
    @IBAction func didPressCancel(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindToPrev", sender: nil)
    }
}
