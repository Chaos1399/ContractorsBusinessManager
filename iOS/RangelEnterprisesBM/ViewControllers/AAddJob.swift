//
//  AAddJob.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 2/22/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

// TODO: fix date placement

import UIKit
import FirebaseDatabase

class AAddJob: CustomVCSuper, UITextFieldDelegate, UITabBarDelegate, UITableViewDataSource, UITableViewDelegate {
    // MARK: - Outlets
    @IBOutlet weak var clientField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var jobsList: UITableView!
    @IBOutlet weak var subButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    // MARK: - Global Variables
    var jobList : [Job] = []
    var fetchedInfo : [String] = []
    
    // MARK: - Required VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        jobList = []
        
        jobsList.isHidden = true
        addButton.isHidden = true
        subButton.isHidden = true
        subButton.isEnabled = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - TextField Methods
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if clientField.hasText && locationField.hasText {
            jobList = []
            fetchedInfo = []
            jobsList.reloadData()
        }
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        jobList = []
        fetchedInfo = []
        jobsList.reloadData()
        jobsList.isHidden = true
        addButton.isHidden = true
        subButton.isHidden = true
        subButton.isEnabled = false
        
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if clientField.hasText && locationField.hasText {
            jobsList.isHidden = false
            addButton.isHidden = false
            subButton.isHidden = false
            subButton.isEnabled = true
            
            
            let cFieldText = self.clientField.text!
            let lFieldText = self.locationField.text!
            
            hiPri.async {
                self.fetchJobsURL(withClient: cFieldText, withLocation: lFieldText)
                var currentClient : Client?
                self.fetchGroup.wait()
                self.fetchGroup.enter()
                self.clientBase!.queryOrderedByKey().queryEqual(toValue: cFieldText).observeSingleEvent(of: .value, with: { (clientSnap) in
                    if clientSnap.exists() {
                        currentClient = Client.init(key: cFieldText, snapshot: clientSnap)
                    }
                    self.fetchGroup.leave()
                })
                
                self.fetchGroup.wait()
                if self.fetchedInfo.count == 0 {
                    self.presentAlert(alertTitle: "Error", alertMessage: "Location not found.\n" +
                        "Check your spelling and that the location belongs to this client.", actionTitle: "New Location", cancelTitle: "Ok", actionHandler:
                        { (UIAlertAction) in
                            let jobsURL = self.jobBase!.url + "/" + cFieldText + lFieldText
                            let newLoc = Location.init(address: lFieldText, jobs: jobsURL, numJobs: 0)
                            let newLocRef = self.locationBase!.child(cFieldText).child(currentClient!.numProps.description)
                            
                            self.fetchedInfo.append(newLoc.jobs)
                            self.fetchedInfo.append("0")
                            currentClient!.numProps += 1
                            
                            newLocRef.setValue(newLoc.toAnyObject())
                            self.clientBase!.child(cFieldText).setValue(currentClient!.toAnyObject())
                    }, cancelHandler: nil)
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
            subButton.isEnabled = false
        }
        
        return true
    }
    
    // MARK: - TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jobList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newCell = tableView.dequeueReusableCell(withIdentifier: "jobListingCell", for: indexPath) as! jobListingCell
        let df = DateFormatter ()
        df.dateFormat = "MM-dd-yy"
        
        newCell.jobDes.text = jobList [indexPath.row].type
        newCell.startDate.text = df.string(from: jobList [indexPath.row].startDate)
        newCell.endDate.text = df.string(from: jobList [indexPath.row].endDate)
        
        return newCell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToJobDetailForEdit", sender: indexPath.row)
    }
    
    // MARK: - Custom Methods
    func addRow (_ job : Job) {
        jobList.append(job)
        jobsList.reloadData()
    }
    func editRow (job : Job, index: Int) {
        jobList [index] = job
        jobsList.reloadData()
    }
    func fetchJobsURL (withClient cFieldText: String, withLocation lFieldText: String) {
        self.fetchGroup.enter()
        // Find client in clientBase
        self.clientBase!.queryOrderedByKey().queryEqual(toValue: cFieldText).observeSingleEvent(of: .value, with: { (snapshot) in
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
                self.presentAlert(alertTitle: "Error", alertMessage: "Client not found\nPlease add client before adding a job for them.", actionTitle: "Ok", cancelTitle: nil, actionHandler: nil, cancelHandler: nil)
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
    
    // MARK: - Button Methods
    @IBAction func didSelectSubmit(_ sender: UIButton) {
        removeDups()
        
        // Query clientBase to get the client info
        self.clientBase!.queryOrderedByKey().queryEqual(toValue: self.clientField.text!).observeSingleEvent(of: .value, with: { (snapshot) in
            let client = Client (key: self.clientField.text!, snapshot: snapshot)
            
            // Get a reference to the locations array for this client
            let locRef = Database.database().reference(fromURL: client.properties)
            
            // Iterate through the location array and check if each is the one that's been entered
            for i in 0..<client.numProps {
                locRef.queryOrderedByKey().queryEqual(toValue: i.description).observeSingleEvent(of: .value, with: { (locSnap) in
                    if locSnap.exists() {
                        let tempLoc = Location.init(key: i, snapshot: locSnap)
                        
                        if tempLoc.address == self.locationField.text! {
                            // The location has been found, need to update client, location, and job databases
                            
                            let tempRef = Database.database().reference(fromURL: tempLoc.jobs)
                            // Ensure that all jobs are written
                            for i in 0..<self.jobList.count {
                                tempRef.child (i.description).setValue (self.jobList [i].toAnyObject ())
                            }
                            
                            tempLoc.numJobs = self.jobList.count
                            locRef.child(i.description).setValue(tempLoc.toAnyObject())
                        }
                    } else {
                        self.presentAlert(alertTitle: "Error", alertMessage: "Something went wrong when finding client's owned properties: \(i)", actionTitle: "Ok", cancelTitle: nil, actionHandler: nil, cancelHandler: nil)
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
    
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToJobDetailForEdit" {
            let destvc = segue.destination as! AddJobDetail
            let selectedJob = jobList [sender as! Int]
            
            destvc.job = selectedJob
            destvc.editingInt = sender as! Int
        }
        
        let name = clientField.text!
        let loc = locationField.text!
        
        hiPri.async {
            self.clientBase!.queryOrderedByKey().queryEqual(toValue: name).observeSingleEvent(of: .value, with: { (clientSnap) in
                if clientSnap.exists() {
                    let tempClient = Client.init(key: name, snapshot: clientSnap)
                    let propRef = Database.database().reference(fromURL: tempClient.properties)
                    
                    for i in 0..<self.jobList.count {
                        propRef.queryOrderedByKey().queryEqual(toValue: i.description).observeSingleEvent(of: .value, with: { (propSnap) in
                            if propSnap.exists() {
                                let tempProp = Location.init(key: i, snapshot: propSnap)
                                
                                if tempProp.address == loc {
                                    let daysRef = Database.database().reference(fromURL: tempProp.jobs)
                                    
                                    for j in 0..<tempProp.numJobs {
                                        daysRef.child(j.description).setValue(self.jobList [j].toAnyObject())
                                    }
                                }
                            }
                        })
                    }
                    
                    self.clientBase!.child(name).setValue(tempClient.toAnyObject())
                }
            })
        }
    }
    @IBAction func unwindToAddJob (_ segue: UIStoryboardSegue) {
        self.jobsList.reloadData()
    }
}
