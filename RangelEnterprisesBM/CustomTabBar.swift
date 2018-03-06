//
//  CustomTabBar.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 3/3/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import UIKit

class CustomTabBar: UITabBarController {

    var user : User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        (self.viewControllers! [0] as! CustomVCSuper).user = self.user
        (self.viewControllers! [1] as! CustomVCSuper).user = self.user
        (self.viewControllers! [2] as! CustomVCSuper).user = self.user
        (self.viewControllers! [3] as! CustomVCSuper).user = self.user
        (self.viewControllers! [4] as! CustomVCSuper).user = self.user
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func unwindToPrev (_ segue: UIStoryboardSegue) {}
}
