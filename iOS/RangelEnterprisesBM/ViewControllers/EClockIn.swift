//
//  EClockIn.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 2/22/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import UIKit
import FirebaseDatabase

// duplicates location list, doesnt show all clients

class EClockIn: CustomVCSuper {
    // MARK: - Outlets
    @IBOutlet weak var clockInOut: UIButton!
    @IBOutlet weak var numHours: UILabel!
    @IBOutlet weak var clientLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!
    
    // MARK: - Global Variables
    var start : DispatchTime = DispatchTime.distantFuture
    var end : DispatchTime = DispatchTime.distantFuture
    var isIn : Bool = false
    let cal = Calendar.init(identifier: .gregorian)
    var selectedClient : String?
    var selectedLocation : Location?
    var selectedJob : String?
    
    // MARK: - Required VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Custom Methods
    func addDay (_ newDay: Workday) {
        let periodRef = Database.database().reference(fromURL: self.user!.history)
        
        self.fetchGroup.enter()
        periodRef.observeSingleEvent(of: .value, with: { (perSnap) in
            if perSnap.exists() {
                let tempPer = PayPeriod.init(key: (self.user!.numPeriods - 1), snapshot: perSnap)
                let daysRef = Database.database().reference(fromURL: tempPer.days)
                
                daysRef.child(tempPer.numDays.description).setValue(newDay.toAnyObject())
                tempPer.numDays += 1
                tempPer.totalHours += newDay.hours
                periodRef.child((self.user!.numPeriods - 1).description).setValue(tempPer.toAnyObject())
            }
            self.fetchGroup.leave()
        })
    }
    
    // MARK: - Button Methods
    @IBAction func hitClock(_ sender: UIButton) {
        var newDay : Workday
        
        if !isIn {
            if (selectedJob == nil) {
                self.presentAlert(alertTitle: "Choose Job and Location", alertMessage: "You forgot to choose what you are doing", actionTitle: "Ok", cancelTitle: nil, actionHandler: nil, cancelHandler: nil)
                return
            }
            start = DispatchTime.now()
            clockInOut.setTitle("Clock Out", for: .normal)
        }
        else {
            end = DispatchTime.now()
            let formatter = DateFormatter()
            formatter.timeStyle = .medium
            formatter.dateStyle = .none
            
            clockInOut.setTitle("Clock In", for: .normal)
            //Dividing by 3600 * 1000000000 to get hours from nanoseconds
            let time = Double ((end.uptimeNanoseconds - start.uptimeNanoseconds) / (1000000000 * 3600))
            numHours.text = time.description
            
            newDay = Workday.init(date: Date.init(), hours: time, forClient: selectedClient!, atLocation: self.selectedLocation!.address, doingJob: self.selectedJob!)
            hiPri.async {
                self.addDay (newDay)
                self.fetchGroup.wait()
            }
        }
        isIn = !isIn
    }
    @IBAction func didPressChangePage(_ sender: UIButton) {
        let actionSheet = UIAlertController (title: "Change Page", message: nil, preferredStyle: .actionSheet)
        let changeToMenu = UIAlertAction (title: "Menu", style: .default, handler: { (action : UIAlertAction) in
            self.tabBarController?.selectedIndex = 0
        })
        let changeToSchedule = UIAlertAction (title: "View Schedule", style: .default, handler: { (action : UIAlertAction) in
            self.tabBarController?.selectedIndex = 1
        })
        let changetoTimeBank = UIAlertAction (title: "Time Off", style: .default, handler: { (action : UIAlertAction) in
            self.tabBarController?.selectedIndex = 3
        })
        let changetoHistory = UIAlertAction (title: "Pay Period History", style: .default, handler: { (action : UIAlertAction) in
            self.tabBarController?.selectedIndex = 4
        })
        let cancelAction = UIAlertAction (title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction (changeToMenu)
        actionSheet.addAction (changeToSchedule)
        actionSheet.addAction (changetoTimeBank)
        actionSheet.addAction (changetoHistory)
        actionSheet.addAction (cancelAction)
        self.present (actionSheet, animated: true, completion: nil)
    }
    @IBAction func didSelectChoose (_ sender: UIButton) {
        performSegue(withIdentifier: "goToJobChoose", sender: nil)
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToJobChoose" {
            let destVC = segue.destination as! JobChoose
            
            destVC.dest = 1
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        if selectedClient != nil && selectedLocation != nil && selectedJob != nil {
            clientLabel.text = selectedClient!
            locationLabel.text = selectedLocation!.address
            jobLabel.text = selectedJob!
        }
    }
    @IBAction func unwindToClockIn (_ segue: UIStoryboardSegue) {}
}
