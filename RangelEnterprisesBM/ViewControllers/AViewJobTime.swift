//
//  AViewJobTime.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 2/22/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import UIKit

class AViewJobTime: CustomVCSuper {
    @IBOutlet weak var dateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDate()
    }
    
    func setupDate () {
        let date = Date.init()
        let today = Calendar.init(identifier: .gregorian)
        let day = today.component(.day, from: date)
        let monthname : String
        let year = today.component(.year, from: date)
        
        switch today.component(.month, from: date) {
        case 1:
            monthname = "January"
        case 2:
            monthname = "February"
        case 3:
            monthname = "March"
        case 4:
            monthname = "April"
        case 5:
            monthname = "May"
        case 6:
            monthname = "June"
        case 7:
            monthname = "July"
        case 8:
            monthname = "August"
        case 9:
            monthname = "September"
        case 10:
            monthname = "October"
        case 11:
            monthname = "November"
        default:
            monthname = "December"
        }
        
        dateLabel.text = monthname + " \(day), \(year)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func didPressChangePage(_ sender: UIButton) {
        let actionSheet = UIAlertController (title: "Change Page", message: nil, preferredStyle: .actionSheet)
        let changeToMenu = UIAlertAction (title: "Menu", style: .default, handler: { (action : UIAlertAction) in
            self.tabBarController?.selectedIndex = 0
        })
        let changetoCountHours = UIAlertAction (title: "Count Hours", style: .default, handler:
        { (action : UIAlertAction) in
            self.tabBarController?.selectedIndex = 1
        })
        let changeToAddJob = UIAlertAction (title: "Add Job", style: .default, handler:
        { (action : UIAlertAction) in
            self.tabBarController?.selectedIndex = 3
        })
        let changetoReviseHours = UIAlertAction (title: "Revise Hours", style: .default, handler:
        { (action : UIAlertAction) in
            self.tabBarController?.selectedIndex = 5
        })
        let cancelAction = UIAlertAction (title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction (changeToMenu)
        actionSheet.addAction (changetoCountHours)
        actionSheet.addAction (changeToAddJob)
        actionSheet.addAction (changetoReviseHours)
        actionSheet.addAction (cancelAction)
        self.present (actionSheet, animated: true, completion: nil)
    }
}
