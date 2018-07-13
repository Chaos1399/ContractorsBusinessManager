//
//  EMenu.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 2/22/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import UIKit

class EMenu: CustomVCSuper {
    // MARK: - Required VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Tab Changing Button Methods
    @IBAction func viewSchedule(_ sender: UIButton) {
        self.tabBarController?.selectedIndex = 1
    }
    @IBAction func work(_ sender: UIButton) {
        self.tabBarController?.selectedIndex = 2
    }
    @IBAction func timeOff(_ sender: UIButton) {
        self.tabBarController?.selectedIndex = 3
    }
    @IBAction func payPeriod(_ sender: UIButton) {
        self.tabBarController?.selectedIndex = 4
    }
 
    // MARK: - Segue Performing Button Methods
    @IBAction func signOut(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindToLogin", sender: nil)
    }
    @IBAction func editUser(_ sender: UIButton) {
        performSegue(withIdentifier: "editUser", sender: nil)
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (segue.destination as! CustomVCSuper).user = self.user
    }
}
