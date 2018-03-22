//
//  Login.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 2/22/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import UIKit
import FirebaseDatabase

class Login: CustomVCSuper, UITextFieldDelegate {
    // MARK: - Outlets
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var passInput: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    // MARK: - Required VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.isEnabled = false
        
        nameInput.text = ""
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
        
        if passInput.hasText && nameInput.hasText {
            loginButton.isEnabled = true
        }
        else {
            loginButton.isEnabled = false
        }
        
        return true
    }
    
    // MARK: - Button Methods
    @IBAction func didPressLogin(_ sender: UIButton) {
        if let username = nameInput.text, let password = passInput.text {
            self.userBase?.queryOrderedByKey().queryEqual(toValue: username).observe(.value, with: { snapshot in
                if snapshot.exists()  {
                    self.user = User.init(key: username, snapshot: snapshot)
                    
                    if password == self.user!.password {
                        if self.user!.admin {
                            self.performSegue(withIdentifier: "loginA", sender: nil)
                        }
                        else {
                            self.performSegue(withIdentifier: "loginE", sender: nil)
                        }
                    }
                    else {
                        let alert = UIAlertController (title: "Error", message: "Invalid Password", preferredStyle: .alert)
                        let defaultAction = UIAlertAction (title: "OK", style: .default, handler: nil)
                        
                        alert.addAction(defaultAction)
                        
                        self.present (alert, animated: true, completion: nil)
                    }
                }
                else {
                    let alert = UIAlertController (title: "Error", message: "Invalid Username", preferredStyle: .alert)
                    let defaultAction = UIAlertAction (title: "OK", style: .default, handler: nil)
                    
                    alert.addAction(defaultAction)
                    
                    self.present (alert, animated: true, completion: nil)
                }
            })
        }
    }
    @IBAction func didTap(_ sender: UITapGestureRecognizer) {
        textFieldShouldReturn(nameInput)
        textFieldShouldReturn(passInput)
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (segue.destination as! CustomTabBar).user = self.user
    }
    @IBAction func unwindToLogin (_ segue: UIStoryboardSegue) {}
}
