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
    // MARK: - Outlets
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passField: UITextField!
    @IBOutlet weak var confirmField: UITextField!
    @IBOutlet weak var subButton: UIButton!
    
    // MARK: - Required VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - TextField Method
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    // MARK: - Button Methods
    @IBAction func didPressSubmit(_ sender: UIButton) {
        self.userBase!.queryOrderedByKey().queryEqual(toValue: user!.name).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                let tempU = User.init(key: self.user!.name, snapshot: snapshot)
                var didChangeName : Bool = false
                
                if self.nameField.hasText {
                    tempU.name = self.nameField.text!
                    didChangeName = true
                }
                if self.emailField.hasText {
                    tempU.email = self.emailField.text!
                    
                }
                
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
                
                if didChangeName {
                    var pos : Int = -1
                    let name = self.user!.name
                    self.userBase!.child(tempU.name).setValue(tempU.toAnyObject())
                    self.userBase!.child(name).removeValue()
                    
                    let persistenceRef = Database.database().reference().child("PersistenceStartup").child("Employees")
                    
                    for i in 0..<self.employeeList.count {
                        if self.employeeList [i] == name {
                            pos = i
                            break
                        }
                    }
                    
                    self.employeeList [pos] = tempU.name
                    persistenceRef.child(pos.description).setValue(tempU.name)
                } else {
                    self.userBase!.child(self.user!.name).setValue(tempU.toAnyObject())
                }
            }
        })
        
        self.performSegue(withIdentifier: "unwindToPrev", sender: nil)
    }
    @IBAction func didPressCancel(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindToPrev", sender: nil)
    }
}
