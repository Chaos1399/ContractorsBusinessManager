//
//  AddClient.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 3/5/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import UIKit
import FirebaseDatabase

class AddClient: CustomVCSuper, UITextFieldDelegate {
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var subButton: UIButton!
    
    var clientbase : DatabaseReference?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        clientbase = Database.database().reference().child("Clients")
        
        subButton.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if nameField.hasText && emailField.hasText && addressField.hasText {
            subButton.isEnabled = true
        } else {
            subButton.isEnabled = false
        }
        
        return true
    }
    
    @IBAction func didPressSubmit(_ sender: UIButton) {
        let tempRef = clientbase?.child(nameField.text!)
        
        tempRef?.setValue (Client.init(name: nameField.text!, billingAddress: addressField.text!, email: emailField.text!, heldProperties: nil).toAnyObject())
    }
    @IBAction func didPressCancel(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindToPrev", sender: nil)
    }
}
