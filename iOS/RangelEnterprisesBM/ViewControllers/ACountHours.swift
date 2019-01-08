//
//  ACountHours.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 2/22/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ACountHours: CustomVCSuper, UITableViewDelegate, UITableViewDataSource {
    // MARK: - Outlets
    @IBOutlet weak var hoursBoard: UITableView!
    @IBOutlet weak var nameHeader: UILabel!
    @IBOutlet weak var hoursHeader: UILabel!
    @IBOutlet weak var payHeader: UILabel!
    @IBOutlet weak var totalHeader: UILabel!
    @IBOutlet weak var totalHoursLabel: UILabel!
    @IBOutlet weak var totalPayLabel: UILabel!
    @IBOutlet weak var clientLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!
    
    // MARK: - Global Variables
    var workerList : [String] = []
    var pphList : [Double] = []
    var hoursList : [Double] = []
    var selectedClient : String?
    var selectedLocation : String?
    var selectedJob : String?
    
    // MARK: - Required VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        nameHeader.layer.borderWidth = 1
        nameHeader.layer.borderColor = UIColor.black.cgColor
        hoursHeader.layer.borderWidth = 1
        hoursHeader.layer.borderColor = UIColor.black.cgColor
        payHeader.layer.borderWidth = 1
        payHeader.layer.borderColor = UIColor.black.cgColor
        totalHeader.layer.borderWidth = 1
        totalHeader.layer.borderColor = UIColor.black.cgColor
        totalHoursLabel.layer.borderWidth = 1
        totalHoursLabel.layer.borderColor = UIColor.black.cgColor
        totalPayLabel.layer.borderWidth = 1
        totalPayLabel.layer.borderColor = UIColor.black.cgColor
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workerList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hourCountCell") as! hourCountCell
        let row = indexPath.row
        
        cell.nameLabel.text = workerList [row]
        cell.hourLabel.text = hoursList [row].description
        cell.payLabel.text = pphList [row].description
        
        return cell
    }
    
    // MARK: - Button Methods
    @IBAction func didPressCalculate(_ sender: UIButton) {
        var tempUserList : [CustomUser] = []
        
        if self.selectedClient == nil {
            self.presentAlert(alertTitle: "Choose Job", alertMessage: "You forgot to select what you are working on.", actionTitle: "Ok", cancelTitle: nil, actionHandler: nil, cancelHandler: nil)
            return
        }
        
        hiPri.async {
            for i in 0..<self.employeeNameList.count {
                self.fetchGroup.enter()
                // Get user information to use number of hours and stuff
                self.userBase!.queryOrderedByKey().queryEqual(toValue: self.employeeUidList[i]).observeSingleEvent(of: .value, with: { (empSnap) in
                    if empSnap.exists() {
                        tempUserList.append(CustomUser.init(key: self.employeeUidList [i], snapshot: empSnap))
                    }
                    self.fetchGroup.leave()
                })
            }
            
            self.fetchGroup.wait()
            for i in 0..<tempUserList.count {
                let tempEmp = tempUserList [i]
                let historyRef = Database.database().reference(fromURL: tempEmp.history)
                
                if i >= self.workerList.count || i >= self.pphList.count || i >= self.hoursList.count {
                    self.workerList.append(tempEmp.name)
                    self.pphList.append(0.0)
                    self.hoursList.append(0.0)
                } else {
                    self.workerList [i] = tempEmp.name
                    self.pphList [i] = 0.0
                    self.hoursList [i] = 0.0
                }
                
                // Will gather hours for the last period worked at this job
                let j = self.user!.numPeriods - 1
                self.fetchGroup.enter()
                historyRef.queryOrderedByKey().queryEqual(toValue: j.description).observeSingleEvent(of: .value, with: { (historySnap) in
                    if historySnap.exists() {
                        let tempHistory = PayPeriod.init(key: j, snapshot: historySnap)
                        let daysRef = Database.database().reference(fromURL: tempHistory.days)
                        
                        for k in 0..<tempHistory.numDays {
                            self.fetchGroup.enter()
                            daysRef.queryOrderedByKey().queryEqual(toValue: k.description).observeSingleEvent(of: .value, with: { (daySnap) in
                                if daySnap.exists() {
                                    let tempDay = Workday.init(key: k, snapshot: daySnap)
                                    if tempDay.client == self.selectedClient! && tempDay.location == self.selectedLocation! && tempDay.job == self.selectedJob! {
                                        self.hoursList [i] += tempDay.hours
                                        self.pphList [i] += (tempDay.hours * tempEmp.pph)
                                    }
                                }
                                self.fetchGroup.leave()
                            })
                        }
                    }
                    self.fetchGroup.leave()
                })
            }
            
            self.fetchGroup.wait()
            
            var hourSum : Double = 0
            var paySum : Double = 0
            let nf = NumberFormatter ()
            nf.numberStyle = NumberFormatter.Style.decimal
            
            for i in 0..<self.hoursList.count {
                hourSum += self.hoursList [i]
                paySum += self.pphList [i]
            }
            
            DispatchQueue.main.async {
                self.hoursBoard.reloadData()
                self.totalHoursLabel.text = hourSum.description
                self.totalPayLabel.text = nf.string(from: NSNumber (value: paySum))
            }
        }
    }
    @IBAction func didPressChangePage(_ sender: UIButton) {
        let actionSheet = UIAlertController (title: "Change Page", message: nil, preferredStyle: .actionSheet)
        let changeToMenu = UIAlertAction (title: "Menu", style: .default, handler: { (action : UIAlertAction) in
            self.tabBarController?.selectedIndex = 0
        })
        let changeToSchedule = UIAlertAction (title: "Schedule", style: .default, handler:
        { (action : UIAlertAction) in
            self.tabBarController?.selectedIndex = 2
        })
        let changetoAddJob = UIAlertAction (title: "Add Job", style: .default, handler:
        { (action : UIAlertAction) in
            self.tabBarController?.selectedIndex = 3
        })
        let changetoReviseHours = UIAlertAction (title: "Revise Hours", style: .default, handler:
        { (action : UIAlertAction) in
            self.tabBarController?.selectedIndex = 5
        })
        let cancelAction = UIAlertAction (title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction (changeToMenu)
        actionSheet.addAction (changeToSchedule)
        actionSheet.addAction (changetoAddJob)
        actionSheet.addAction (changetoReviseHours)
        actionSheet.addAction (cancelAction)
        self.present (actionSheet, animated: true, completion: nil)
    }
    @IBAction func didSelectChoose (_ sender: UIButton) {
        workerList = []
        pphList = []
        hoursList = []
        hoursBoard.reloadData()
        
        performSegue(withIdentifier: "goToJobChoose", sender: nil)
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToJobChoose" {
            let destVC = segue.destination as! JobChoose
            
            destVC.dest = 0
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        if selectedClient != nil && selectedLocation != nil && selectedJob != nil {
            clientLabel.text = selectedClient!
            locationLabel.text = selectedLocation!
            jobLabel.text = selectedJob!
        }
    }
    @IBAction func unwindToCountHours (_ segue: UIStoryboardSegue) {}
}
