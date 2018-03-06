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
    
    var clientbase : DatabaseReference?
    var allJobs : [Job] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clientbase = Database.database().reference().child("Clients")
        
        setupTableView ()
        
        jobsList.isHidden = true
        addButton.isHidden = true
        subButton.isEnabled = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupTableView () {
        self.clientbase?.queryOrderedByKey().queryEqual(toValue: clientField.text!).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let client = Client (key: self.clientField.text!, snapshot: snapshot)
                
                if client.properties != nil {
                    for loc in client.properties! {
                        if loc.address == self.locationField.text! {
                            self.allJobs = loc.jobs!
                            self.jobsList.reloadData()
                        }
                    }
                }
            }
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if clientField.hasText && locationField.hasText {
            setupTableView()
            jobsList.isHidden = false
            addButton.isHidden = false
            subButton.isEnabled = true
        }
        
        return true
    }
    
    @IBAction func didSelectSubmit(_ sender: UIButton) {
        self.clientbase?.queryOrderedByKey().queryEqual(toValue: clientField.text!).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let client = Client (key: self.clientField.text!, snapshot: snapshot)
                
                let location = Location.init(address: self.locationField.text!, jobs: self.allJobs)
                if client.properties != nil {
                    var didSet = false
                    for i in 0...client.properties!.count {
                        if client.properties! [i].address == self.locationField.text! {
                            client.properties! [i] = location
                            didSet = true
                            break
                        }
                    }
                    if !didSet {
                        client.properties?.append(location)
                    }
                } else {
                    client.properties = []
                    client.properties?.append(location)
                }
                
                self.clientbase?.child(self.clientField.text!).setValue(client.toAnyObject())
            } else {
                let alert = UIAlertController (title: "Error", message: "Client not found, please add client before adding a job for them.", preferredStyle: .alert)
                let action = UIAlertAction (title: "Ok", style: .default, handler: nil)
                alert.addAction(action)
                self.present (alert, animated: true, completion: nil)
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allJobs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newCell = tableView.dequeueReusableCell(withIdentifier: "jobListingCell", for: indexPath) as! jobListingCell
        let df = DateFormatter ()
        df.locale = Locale (identifier: "en_US")
        df.timeStyle = .none
        df.dateFormat = "MM/dd/yy"
        
        newCell.jobDes.text = allJobs [indexPath.row].type
        newCell.startDate.text = df.string(from: allJobs [indexPath.row].startDate)
        newCell.endDate.text = df.string(from: allJobs [indexPath.row].endDate)
        
        return newCell
    }
    
    func addRow (_ job : Job) {
        allJobs.append(job)
        jobsList.reloadData()
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
    
    @IBAction func unwindToAddJob (_ segue: UIStoryboardSegue) {}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToEditJob" {
            let destvc = segue.destination as! AEditJob
            
            destvc.allJobs = allJobs
        }
    }
}
