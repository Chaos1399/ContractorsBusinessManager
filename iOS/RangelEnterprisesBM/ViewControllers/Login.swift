//
//  Login.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 2/22/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class Login: CustomVCSuper, UITextFieldDelegate {
    // MARK: - Outlets
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passInput: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    // MARK: - Required VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.isEnabled = false
        
        emailInput.text = ""
        passInput.text = ""
        
        let navbar = self.navigationController?.navigationBar
        navbar?.setBackgroundImage (UIImage (), for: .default)
        navbar?.shadowImage = UIImage ()
        navbar?.alpha = 0.0
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - TextField Method
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if passInput.isEditing {
            passInput.resignFirstResponder()
            
            didPressLogin(loginButton)
        }
        textField.resignFirstResponder()
        
        if passInput.hasText && emailInput.hasText {
            loginButton.isEnabled = true
        }
        else {
            loginButton.isEnabled = false
        }
        
        return true
    }
    
    // MARK: - Button Methods
    @IBAction func didPressLogin(_ sender: UIButton) {
        if let email = emailInput.text, let password = passInput.text {
            Auth.auth().signIn(withEmail: email, password: password) { (adr, error) in
                if let authUser = adr?.user {
                    self.userBase?.queryOrderedByKey().queryEqual(toValue: authUser.uid).observe(.value, with: { snapshot in
                        if snapshot.exists()  {
                            self.user = User.init(key: authUser.uid, snapshot: snapshot)
                            
                            if self.user!.admin {
                                self.performSegue(withIdentifier: "loginA", sender: nil)
                            }
                            else {
                                self.performSegue(withIdentifier: "loginE", sender: nil)
                            }
                        }
                        else {
                            let alert = UIAlertController (title: "Error", message: "Invalid Username/Password", preferredStyle: .alert)
                            let defaultAction = UIAlertAction (title: "OK", style: .default, handler: nil)
                            
                            alert.addAction(defaultAction)
                            
                            self.present (alert, animated: true, completion: nil)
                        }
                    })
                }
            }
        }
    }
    @IBAction func didTap(_ sender: UITapGestureRecognizer) {
        textFieldShouldReturn(emailInput)
        textFieldShouldReturn(passInput)
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (segue.destination as! CustomTabBar).user = self.user
    }
    @IBAction func unwindToLogin (_ segue: UIStoryboardSegue) {}
}
