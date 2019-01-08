//
//  AAddJob.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 2/22/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

// TODO: fix date placement in job list cells

import UIKit
import FirebaseDatabase

class AAddJob: CustomVCSuper, UITextFieldDelegate, UITabBarDelegate, UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    // MARK: - Outlets
    @IBOutlet weak var clientField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var jobsList: UITableView!
    @IBOutlet weak var subButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var clPicker: UIPickerView!
    
    // MARK: - Global Variables
    var clientList : [Client] = []
    var jobList : [Job] = []
    var fetchedInfo : [String] = []
    var locList : [Location] = []
    var selectedClient : Int = -1
    var selectedLoc : Int = -1
    
    // MARK: - Required VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        jobsList.isHidden = true
        addButton.isHidden = true
        subButton.isHidden = true
        subButton.isEnabled = false
        clPicker.isHidden = true
        
        
        clientField.tag = 0
        locationField.tag = 1
    }
    
    // MARK: - TextField Methods
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if clientField.hasText && locationField.hasText {
            jobList = []
            fetchedInfo = []
            jobsList.reloadData()
        }
        
        if textField.tag == 0 {
            locationField.text = nil
            clPicker.tag = 0
            clPicker.isHidden = false
            clPicker.reloadComponent(0)
        } else if textField.tag == 1 {
            clPicker.tag = 1
            if !clientField.hasText {
                self.presentAlert(alertTitle: "Choose Client", alertMessage: "You need to select a client before choosing a location", actionTitle: "Ok", cancelTitle: nil, actionHandler: nil, cancelHandler: nil)
                clPicker.isHidden = true
                return
            } else {
                locList = []
                for i in 0..<clientNameList.count {
                    if clientNameList[i] == clientField!.text {
                        hiPri.async {
                            self.fetchLocs(forClient: i)
                            self.fetchGroup.wait()
                            DispatchQueue.main.async {
                                self.clPicker.isHidden = false
                                self.clPicker.reloadComponent(0)
                            }
                        }
                        break
                    }
                }
            }
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
        clPicker.isHidden = true
        
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        checkShowItems()
        
        return true
    }
    
    // MARK: PickerView Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        if pickerView.tag == 0 {
            return clientNameList.count
        } else {
            return locList.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var attributedString : NSAttributedString
        
        if pickerView.tag == 0 {
            attributedString = NSAttributedString(string: clientNameList[row], attributes: [NSAttributedStringKey.foregroundColor : UIColor.white])
        } else {
            attributedString = NSAttributedString(string: locList[row].address + ", " + locList[row].city, attributes: [NSAttributedStringKey.foregroundColor : UIColor.white])
        }
        
        return attributedString
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            clientField.text = clientNameList[row]
            selectedClient = row
            
            for i in 0..<self.clientNameList.count {
                self.clientBase!.queryOrderedByKey().queryEqual(toValue: i.description).observeSingleEvent(of: .value, with: { (snap) in
                    if snap.exists() {
                        self.clientList.append(Client.init(key: i, snapshot: snap))
                    }
                })
            }
        } else {
            locationField.text = locList[row].address + ", " + locList[row].city
            selectedLoc = row
        }
        clPicker.isHidden = true
        
        if clientField.text != nil && locationField.text != nil {
            checkShowItems()
        }
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
    func setupJobsList () {
        // Get a reference to the array of jobs for a location
        let jobRef = Database.database().reference(fromURL: fetchedInfo [0])
        
        // Get the number of jobs in the array
        let numJobs = Int (fetchedInfo [1])!
        
        // Iterate through the array to add all the jobs to the jobList
        for i in 0..<numJobs {
            self.fetchGroup.enter()
            jobRef.queryOrderedByKey().queryEqual(toValue: i.description).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    self.jobList.append(Job.init(key: i, snapshot: snapshot))
                }
                
                self.fetchGroup.leave()
            })
        }
    }
    func checkShowItems () {
        let group2 = DispatchGroup()
        
        if clientField.hasText && locationField.hasText {
            jobsList.isHidden = false
            addButton.isHidden = false
            subButton.isHidden = false
            subButton.isEnabled = true
            
            // Location doesn't exist currently
            if selectedLoc == -1 {
                group2.enter()
                self.presentAlert(alertTitle: "Error", alertMessage: "Location not found.\n" +
                    "Check your spelling and that the location belongs to this client.", actionTitle: "Add New Location", cancelTitle: "Ok", actionHandler:
                    { (UIAlertAction) in
                        self.addLoc()
                        DispatchQueue.main.async {
                            self.clPicker.isHidden = true
                        }
                }, cancelHandler: nil)
                
                group2.leave()
                return
            }
            
            group2.wait()
            self.fetchedInfo.append (self.locList[selectedLoc].jobs)
            self.fetchedInfo.append (self.locList[selectedLoc].numJobs.description)
            
            hiPri.async {
                self.setupJobsList()
                
                self.fetchGroup.wait()
                DispatchQueue.main.async {
                    self.jobsList.reloadData()
                }
            }
        } else {
            jobsList.isHidden = true
            addButton.isHidden = true
            subButton.isHidden = true
            subButton.isEnabled = false
        }
    }
    func removeJobDups () {
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
    func fetchLocs (forClient client: Int) {
        let locRef = Database.database().reference(fromURL: clientList[selectedClient].properties)
        
        // Get all locations for the chosen client
        for i in 0..<clientList[selectedClient].numProps {
            self.fetchGroup.enter()
            locRef.queryOrderedByKey().queryEqual(toValue: i.description).observeSingleEvent(of: .value, with: { (locSnap) in
                // Null check, for safety
                if locSnap.exists() {
                    self.locList.append(Location.init(key: i, snapshot: locSnap))
                }
                self.fetchGroup.leave()
            })
        }
    }
    func addLoc () {
        let currentClient : Client = clientList[selectedClient]
        let lFieldText = self.locationField.text!
        let jobsURL = self.jobBase!.url + "/" + selectedClient.description + "/" + currentClient.numProps.description
        
        var subStrings = lFieldText.components(separatedBy: ", ")
        
        if subStrings.count < 2 {
            self.presentAlert(alertTitle: "Location Format", alertMessage: "The location must be formatted as such:\nAddress, City", actionTitle: "Ok", cancelTitle: nil, actionHandler: nil, cancelHandler: nil)
            return
        }
        
        self.fetchGroup.wait()
        let newLoc = Location.init(address: subStrings[0], city: subStrings[1], jobs: jobsURL, numJobs: 0)
        let newLocRef = self.locationBase!.child(selectedClient.description).child(currentClient.numProps.description)
        
        self.fetchedInfo.append(newLoc.jobs)
        self.fetchedInfo.append("0")
        currentClient.numProps += 1
        
        newLocRef.setValue(newLoc.toAnyObject())
        self.clientBase!.child(selectedClient.description).setValue(currentClient.toAnyObject())
    }
    
    // MARK: - Button Methods
    @IBAction func didSelectSubmit(_ sender: UIButton) {
        removeJobDups()
        
        let client = clientList[selectedClient]
        let loc = locList[selectedLoc]
        
        // Get a reference to the locations array for this client
        let locRef = Database.database().reference(fromURL: client.properties)
        
        let tempRef = Database.database().reference(fromURL: loc.jobs)
        // Ensure that all jobs are written
        for i in 0..<jobList.count {
            tempRef.child (i.description).setValue (self.jobList [i].toAnyObject ())
        }
        
        loc.numJobs = self.jobList.count
        locRef.child(selectedLoc.description).setValue(loc.toAnyObject())
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
        
        let loc = locationField.text!
        let client = clientList[selectedClient]
        let propRef = Database.database().reference(fromURL: client.properties)
        
        hiPri.async {
            for i in 0..<self.jobList.count {
                propRef.queryOrderedByKey().queryEqual(toValue: i.description).observeSingleEvent(of: .value, with: { (propSnap) in
                    if propSnap.exists() {
                        let tempProp = Location.init(key: i, snapshot: propSnap)
                        
                        // Write back the property whose jobs were changed
                        if (tempProp.address + ", " + tempProp.city) == loc {
                            let daysRef = Database.database().reference(fromURL: tempProp.jobs)
                            
                            for j in 0..<tempProp.numJobs {
                                daysRef.child(j.description).setValue(self.jobList [j].toAnyObject())
                            }
                        }
                    }
                })
            }
            
            self.clientBase!.child(self.selectedClient.description).setValue(client.toAnyObject())
        }
    }
    @IBAction func unwindToAddJob (_ segue: UIStoryboardSegue) {
        self.jobsList.reloadData()
    }
}
