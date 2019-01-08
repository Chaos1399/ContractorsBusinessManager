//
//  EMenu.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 2/22/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import UIKit
import FirebaseAuth

class EMenu: CustomVCSuper {
    // MARK: - Required VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Tab Changing Button Methods
    // Go to the View Schedule tab, governed by EViewSchedule
    @IBAction func viewSchedule(_ sender: UIButton) { self.tabBarController?.selectedIndex = 1 }
    // Go to the Clock In/Out tab, governed by EClockIn
    @IBAction func work(_ sender: UIButton) { self.tabBarController?.selectedIndex = 2 }
    // Go to the Time Off tab, governed by ETimeBank
    @IBAction func timeOff(_ sender: UIButton) { self.tabBarController?.selectedIndex = 3 }
    // Go to the Pay Period History tab, governed by EPayHistory
    @IBAction func payPeriod(_ sender: UIButton) { self.tabBarController?.selectedIndex = 4 }
 
    // MARK: - Segue Performing Button Methods
    @IBAction func signOut(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        performSegue(withIdentifier: "unwindToLogin", sender: nil)
    }
    // Go to the Edit User page, governed by EeditProfile
    @IBAction func editUser(_ sender: UIButton) {
        performSegue(withIdentifier: "editUser", sender: nil)
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (segue.destination as! CustomVCSuper).user = self.user
    }
}
