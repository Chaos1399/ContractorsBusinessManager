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
    // MARK: - Outlets
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var subButton: UIButton!

    // MARK: - Required VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subButton.isEnabled = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - TextField Method
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if nameField.hasText && emailField.hasText && addressField.hasText {
            subButton.isEnabled = true
        } else {
            subButton.isEnabled = false
        }
        
        return true
    }
    
    // MARK: - Button Methods
    @IBAction func didPressSubmit(_ sender: UIButton) {
        let name : String = nameField.text!
        let address : String = addressField.text!
        let email : String = emailField.text!
        let tempClientRef = clientBase!.child(name)
        let locRef = locationBase!.url + "/" + name
        
        clientList.append(nameField.text!)
        self.updatePersistentStorage(setClient: true)
        
        tempClientRef.setValue (Client.init(name: name, billingAddress: address, email: email, heldProperties: locRef, numProperties: 0).toAnyObject())
        performSegue(withIdentifier: "unwindToPrev", sender: nil)
    }
    @IBAction func didPressCancel(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindToPrev", sender: nil)
    }
}
