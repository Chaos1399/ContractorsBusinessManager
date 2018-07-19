//
//  EeditProfile.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 3/3/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

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
        self.userBase!.queryOrderedByKey().queryEqual(toValue: Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                let tempU = User.init(key: Auth.auth().currentUser!.uid, snapshot: snapshot)
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
                    let authUser = Auth.auth().currentUser
                    
                    authUser?.updatePassword(to: self.passField.text!, completion: nil)
                    self.performSegue(withIdentifier: "unwindToPrev", sender: nil)
                } else if self.passField.hasText && self.confirmField.hasText {
                    print ("fields don't match")
                    let alert = UIAlertController (title: "Error", message: "Password and Confirm fields don't match", preferredStyle: .alert)
                    let action = UIAlertAction (title: "Ok", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present (alert, animated: true, completion: nil)
                } else if self.passField.hasText && !self.confirmField.hasText {
                    print ("confirm no text")
                    let alert = UIAlertController (title: "Error", message: "Confirm field required to change password", preferredStyle: .alert)
                    let action = UIAlertAction (title: "Ok", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present (alert, animated: true, completion: nil)
                } else if !self.passField.hasText && self.confirmField.hasText {
                    print ("pass no text")
                    let alert = UIAlertController (title: "Error", message: "Password field required to change password", preferredStyle: .alert)
                    let action = UIAlertAction (title: "Ok", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present (alert, animated: true, completion: nil)
                }
                
                if didChangeName {
                    let name = self.user!.name
                    
                    self.userBase!.child(Auth.auth().currentUser!.uid).setValue(tempU.toAnyObject())
                    
                    let persistenceRef = Database.database().reference().child("Businesses/Rangel Enterprises Inc/PersistenceStartup/Employees")
                    
                    for i in 0..<self.employeeNameList.count {
                        if self.employeeNameList [i] == name {
                            self.employeeNameList [i] = tempU.name
                            persistenceRef.child(i.description).setValue(tempU.name)
                            self.performSegue(withIdentifier: "unwindToPrev", sender: nil)
                        }
                    }
                    
                } else {
                    self.userBase!.child(Auth.auth().currentUser!.uid).setValue(tempU.toAnyObject())
                    self.performSegue(withIdentifier: "unwindToPrev", sender: nil)
                }
            } else {
                print ("snapshot doesn't exist")
            }
        })
    }
    @IBAction func didPressCancel(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindToPrev", sender: nil)
    }
}
