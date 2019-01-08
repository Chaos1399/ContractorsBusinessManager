//
//  AMenu.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 2/22/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import UIKit
import FirebaseAuth

class AMenu: CustomVCSuper {
    // MARK: - Required VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Tab Change Button Methods
    @IBAction func countHours(_ sender: UIButton) {
        self.tabBarController?.selectedIndex = 1
    }
    @IBAction func scheduleWorkers(_ sender: UIButton) {
        self.tabBarController?.selectedIndex = 2
    }
    @IBAction func addJob(_ sender: UIButton) {
        self.tabBarController?.selectedIndex = 3
    }
    @IBAction func reviseHours(_ sender: UIButton) {
        self.tabBarController?.selectedIndex = 4
    }

    // MARK: - Segue Performing Button Methods
    @IBAction func addWorker(_ sender: UIButton) {
        performSegue(withIdentifier: "signUp", sender: nil)
    }
    @IBAction func signOut(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        performSegue(withIdentifier: "unwindToLogin", sender: nil)
    }
    @IBAction func editUser(_ sender: UIButton) {
        performSegue(withIdentifier: "editUser", sender: nil)
    }
    @IBAction func addClient(_ sender: UIButton) {
        performSegue(withIdentifier: "addClient", sender: nil)
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (segue.destination as! CustomVCSuper).user = self.user
    }
}
