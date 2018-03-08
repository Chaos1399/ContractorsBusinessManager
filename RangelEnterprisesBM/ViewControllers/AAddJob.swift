//
//  AAddJob.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 2/22/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import UIKit
import FirebaseDatabase

class AAddJob: CustomVCSuper, UITextFieldDelegate, UITabBarDelegate, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var clientField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var jobsList: UITableView!
    @IBOutlet weak var subButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    var jobList : [Job] = []
    var fetchedInfo : [String] = []
    let hiPri = DispatchQueue.global(qos: .userInitiated)
    let fetchGroup = DispatchGroup ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        jobList = []
        
        jobsList.isHidden = true
        addButton.isHidden = true
        subButton.isEnabled = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToJobDetailForEdit" {
            let destvc = segue.destination as! AddJobDetail
            let selectedJob = jobList [sender as! Int]
            
            destvc.job = selectedJob
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if clientField.hasText && locationField.hasText {
            jobList = []
            fetchedInfo = []
            jobsList.reloadData()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if clientField.hasText && locationField.hasText {
            jobsList.isHidden = false
            addButton.isHidden = false
            subButton.isEnabled = true
            
            hiPri.async {
                
                self.fetchJobsURL()
                
                self.fetchGroup.wait()
                if self.fetchedInfo.count == 0 {
                    self.presentAlert(alertTitle: "Error", alertMessage: "Location not found.\n" +
                        "Check your spelling,\nAnd that the location belongs to this client.", actionTitle: "Ok", cancelTitle: nil)
                } else {
                    self.setupJobsList()
                    
                    self.fetchGroup.wait()
                    DispatchQueue.main.async {
                        self.jobsList.reloadData()
                    }
                }
            }
        } else {
            jobsList.isHidden = true
            addButton.isHidden = true
            subButton.isHidden = true
        }
        
        return true
    }
    
    // Action buttons
    @IBAction func didSelectSubmit(_ sender: UIButton) {
        
        removeDups()
        
        // Query clientBase to get the client info
        self.clientBase!.queryOrderedByKey().queryEqual(toValue: self.clientField.text!).observeSingleEvent(of: .value, with: { (snapshot) in
            let client = Client (key: self.clientField.text!, snapshot: snapshot)
            
            // Get a reference to the locations array for this client
            let locRef = Database.database().reference(fromURL: client.properties)
            
            // jobskey will be the key under which the array of jobs for a location is stored, must be appended with the location address
            // probably unnecessary, can just use tempLoc.jobs
            //var jobskey = client.name
            
            // Iterate through the location array and check if each is the one that's been entered
            for i in 0..<client.numProps {
                locRef.queryOrderedByKey().queryEqual(toValue: i.description).observeSingleEvent(of: .value, with: { (locSnap) in
                    if locSnap.exists() {
                        let tempLoc = Location.init(key: i, snapshot: locSnap)
                        
                        if tempLoc.address == self.locationField.text! {
                            // The location has been found, need to update client, location, and job databases
                            
                            // Complete the jobskey
                            //jobskey += tempLoc.address
                            
                            // Edit location before I write it back
                            //tempLoc.jobs = self.jobBase!.child(jobskey).url
                            //tempLoc.numJobs = self.jobList.count
                            
                            // Ensure that all jobs are written
                            for i in 0..<self.jobList.count {
                                let tempRef = Database.database().reference(fromURL: tempLoc.jobs).child (tempLoc.numJobs.description)
                                tempRef.setValue (self.jobList [i].toAnyObject ())
                                tempLoc.numJobs += 1
                            }
                            
                            tempLoc.numJobs += 1
                            self.locationBase!.child(self.clientField.text!).child(client.numProps.description).setValue(tempLoc.toAnyObject())
                            //client.numProps += 1
                            //self.clientBase!.child(client.name).setValue(client.toAnyObject())
                        }
                    } else {
                        self.presentAlert(alertTitle: "Error", alertMessage: "Something went wrong when finding client's owned properties: \(i)", actionTitle: "Ok", cancelTitle: nil)
                    }
                })
            }
        })
    }
    @IBAction func didSelectCancel(_ sender: UIButton) {
        clientField.text = ""
        locationField.text = ""
        jobsList.isHidden = true
        addButton.isHidden = true
        self.tabBarController?.selectedIndex = 0
    }
    @IBAction func didSelectAdd(_ sender: UIButton) {
        performSegue(withIdentifier: "goToJobDetail", sender: nil)
    }
    
    // TableView things
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jobList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newCell = tableView.dequeueReusableCell(withIdentifier: "jobListingCell", for: indexPath) as! jobListingCell
        let df = DateFormatter ()
        df.timeStyle = .none
        df.dateFormat = "MM-dd-yy"
        
        newCell.jobDes.text = jobList [indexPath.row].type
        newCell.startDate.text = df.string(from: jobList [indexPath.row].startDate)
        newCell.endDate.text = df.string(from: jobList [indexPath.row].endDate)
        
        return newCell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToJobDetailForEdit", sender: indexPath.row)
    }
    
    // Custom functions
    func addRow (_ job : Job) {
        jobList.append(job)
        jobsList.reloadData()
    }
    func fetchJobsURL () {
        let cFieldText = self.clientField.text!
        let lFieldText = self.locationField.text!
        
        self.fetchGroup.enter()
        // Find client in clientBase
        self.clientBase?.queryOrderedByKey().queryEqual(toValue: cFieldText).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let client = Client (key: cFieldText, snapshot: snapshot)
                
                // Get reference to locations array
                let locRef = Database.database().reference(fromURL: client.properties)
                
                // numProps is the number of items in the locations array, manually updated
                let numLoc = client.numProps
                
                // Iterate through the location array and check if each is the one that's been entered
                for i in 0..<numLoc {
                    self.fetchGroup.enter()
                    locRef.queryOrderedByKey().queryEqual(toValue: i.description).observeSingleEvent(of: .value, with: { (locSnap) in
                        if locSnap.exists() {
                            let tempLoc = Location.init(key: i, snapshot: locSnap)
                            
                            if tempLoc.address == lFieldText {
                                self.fetchedInfo.append (tempLoc.jobs)
                                self.fetchedInfo.append (tempLoc.numJobs.description)
                            }
                        }
                        self.fetchGroup.leave()
                    })
                }
                self.fetchGroup.leave()
            } else {
                self.presentAlert(alertTitle: "Error", alertMessage: "Client not found\nPlease add client before adding a job for them.", actionTitle: "Ok", cancelTitle: nil)
            }
        })
    }
    func setupJobsList () {
        
        // Get a reference to the array of jobs for a location
        let jobRef = Database.database().reference(fromURL: fetchedInfo [0])
        
        // Get the number of jobs in the array
        let numJobs = Int (fetchedInfo [1])!
        
        // Iterate through the array to add all the jobs to the jobList
        for i in 0..<numJobs {
            // Dispatch group enter, to ensure the jobRef closure gets executed in time
            self.fetchGroup.enter()
            
            jobRef.queryOrderedByKey().queryEqual(toValue: i.description).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    self.jobList.append(Job.init(key: i, snapshot: snapshot))
                }
                // Dispatch group leave, also in for loop, and inside closure to be sure that exit occurs on completion of this closure
                self.fetchGroup.leave()
            })
        }
    }
    func removeDups () {
        var typeCheck : String
        var startCheck : Date
        var endCheck : Date
        var occs : [Int] = []
        
        for i in 0..<jobList.count {
            typeCheck = jobList [i].type
            startCheck = jobList [i].startDate
            endCheck = jobList [i].endDate
            occs.append (i)
            
            for j in i..<jobList.count {
                if typeCheck == jobList [j].type || (startCheck == jobList [j].startDate && endCheck == jobList [j].endDate) {
                    occs.append (j)
                }
            }
            
            if occs.count > 1 {
                for k in 1..<(occs.count - 1) {
                    jobList.remove (at: occs [k])
                }
            }
            
            occs = []
        }
    }
    
    // Change page button
    @IBAction func didPressChangePage(_ sender: UIButton) {
        let actionSheet = UIAlertController (title: "Change Page", message: nil, preferredStyle: .actionSheet)
        let changeToMenu = UIAlertAction (title: "Menu", style: .default, handler: { (action : UIAlertAction) in
            self.tabBarController?.selectedIndex = 0
        })
        let changetoCountHours = UIAlertAction (title: "Count Hours", style: .default, handler:
        { (action : UIAlertAction) in
            self.tabBarController?.selectedIndex = 1
        })
        let changeToSchedule = UIAlertAction (title: "Schedule", style: .default, handler:
        { (action : UIAlertAction) in
            self.tabBarController?.selectedIndex = 2
        })
        let changetoReviseHours = UIAlertAction (title: "Revise Hours", style: .default, handler:
        { (action : UIAlertAction) in
            self.tabBarController?.selectedIndex = 5
        })
        let cancelAction = UIAlertAction (title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction (changeToMenu)
        actionSheet.addAction (changetoCountHours)
        actionSheet.addAction (changeToSchedule)
        actionSheet.addAction (changetoReviseHours)
        actionSheet.addAction (cancelAction)
        self.present (actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func unwindToAddJob (_ segue: UIStoryboardSegue) {}
}
