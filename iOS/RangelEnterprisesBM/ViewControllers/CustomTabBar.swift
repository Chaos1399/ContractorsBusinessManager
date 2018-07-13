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
        
        for i in 0..<self.viewControllers!.count {
            (self.viewControllers! [i] as! CustomVCSuper).user = self.user
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func unwindToPrev (_ segue: UIStoryboardSegue) {}
}
