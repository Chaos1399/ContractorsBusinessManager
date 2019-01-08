//
//  JobChoose.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 3/18/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import UIKit
import FirebaseDatabase

class JobChoose: CustomVCSuper, UIPickerViewDelegate, UIPickerViewDataSource {
    // MARK: - Outlets
    @IBOutlet weak var clientPicker: UIPickerView!
    @IBOutlet weak var locationPicker: UIPickerView!
    @IBOutlet weak var jobPicker: UIPickerView!
    
    // MARK: - Global Variables
    var locationList : [Location] = []
    var jobList : [Job] = []
    /*
        dest determines where to unwind to, is passed in
        destinations based on dest vals:
        dest : destination
        0 : ACountHours
        1 : EClockIn
        2 : AAddToSchedule
    */
    var dest : Int = 0

    // MARK: - Required VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hiPri.async {
            if self.clientNameList.count == 0 {
                self.clientListInit()
                self.fetchGroup.wait()
            }
            self.initialPickerSetup()
        }
        
        // Adding tags so the functions can differentiate between the different pickers
        clientPicker.tag = 0
        locationPicker.tag = 1
        jobPicker.tag = 2
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - PickerView Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return clientNameList.count
        } else if pickerView.tag == 1 {
            return locationList.count
        } else {
            return jobList.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            return clientNameList [row]
        } else if pickerView.tag == 1 {
            return locationList [row].address
        } else {
            return jobList [row].type
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            self.locationList = []
            self.jobList = []
            hiPri.async {
                self.fetchLocations(forClient: row)
                self.fetchGroup.wait()
                self.fetchJobs(forLocation: self.locationList [0])
                self.fetchGroup.wait()
                
                DispatchQueue.main.async {
                    self.locationPicker.reloadComponent(0)
                    self.jobPicker.reloadComponent(0)
                }
            }
        } else if pickerView.tag == 1 {
            self.jobList = []
            hiPri.async {
                self.fetchJobs(forLocation: self.locationList [row])
                self.fetchGroup.wait()
                
                DispatchQueue.main.async {
                    self.jobPicker.reloadComponent(0)
                }
            }
        }
    }
    
    // MARK: - Custom Methods
    func fetchLocations (forClient client: Int) {
        self.fetchGroup.enter()
        
        self.clientBase!.queryOrderedByKey().queryEqual(toValue: client.description).observeSingleEvent(of: .value, with: { (snapshot) in
            let client = Client.init(key: client, snapshot: snapshot)
            
            let locRef = Database.database().reference (fromURL: client.properties)
            
            for i in 0..<client.numProps {
                self.fetchGroup.enter()
                locRef.queryOrderedByKey().queryEqual(toValue: i.description).observeSingleEvent(of: .value, with: { (locSnap) in
                    if snapshot.exists() {
                        self.locationList.append (Location.init(key: i, snapshot: locSnap))
                    }
                    self.fetchGroup.leave()
                })
            }
            self.fetchGroup.leave()
        })
    }
    func fetchJobs (forLocation location: Location) {
        let jobRef = Database.database().reference(fromURL: location.jobs)
        
        for i in 0..<location.numJobs {
            self.fetchGroup.enter()
            
            jobRef.queryOrderedByKey().queryEqual(toValue: i.description).observeSingleEvent(of: .value, with: { (jobSnap) in
                if jobSnap.exists() {
                    self.jobList.append(Job.init(key: i, snapshot: jobSnap))
                }
                self.fetchGroup.leave()
            })
        }
    }
    func initialPickerSetup () {
        self.fetchGroup.enter()
        // I put 0 hard-coded here because I want the picker to start on the first one
        self.clientBase!.queryOrderedByKey().queryEqual(toValue: "0").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let client = Client.init(key: 0, snapshot: snapshot)
                
                let locRef = Database.database().reference(fromURL: client.properties)
                
                for i in 0..<client.numProps {
                    self.fetchGroup.enter()
                    locRef.queryOrderedByKey().queryEqual(toValue: i.description).observeSingleEvent(of: .value, with: { (locSnap) in
                        if locSnap.exists() {
                            let tempLoc = Location.init(key: i, snapshot: locSnap)
                            self.locationList.append (tempLoc)
                        } else {
                            print ("Error: No data exists at " + locRef.url)
                        }
                        self.fetchGroup.leave()
                    })
                }
            } else {
                print ("Error: Couldn't find Client 0 at " + self.clientBase!.url)
            }
            self.fetchGroup.leave()
        })
        
        self.fetchGroup.wait()
        let loc0 = self.locationList [0]
        let jobRef = Database.database().reference(fromURL: loc0.jobs)
        
        for i in 0..<loc0.numJobs {
            self.fetchGroup.enter()
            jobRef.queryOrderedByKey().queryEqual(toValue: i.description).observeSingleEvent(of: .value, with: { (jobSnap) in
                if jobSnap.exists() {
                    let tempJob = Job.init(key: i, snapshot: jobSnap)
                    self.jobList.append (tempJob)
                }
                self.fetchGroup.leave()
            })
        }
        self.fetchGroup.wait()
        
        // Refresh the PickerViews
        DispatchQueue.main.async {
            self.clientPicker.reloadComponent(0)
            self.locationPicker.reloadComponent(0)
            self.jobPicker.reloadComponent(0)
        }
    }
    
    // MARK: - Button Methods
    @IBAction func didSelectBack(_ sender: UIButton) {
        if dest == 0 {
            performSegue(withIdentifier: "unwindToCountHoursWithCancel", sender: nil)
        } else if dest == 1 {
            performSegue(withIdentifier: "unwindToClockInWithCancel", sender: nil)
        } else if dest == 2 {
            performSegue(withIdentifier: "unwindToAddToScheduleWithCancel", sender: nil)
        }
    }
    @IBAction func didSelectSub(_ sender: UIButton) {
        if dest == 0 {
            performSegue(withIdentifier: "unwindToCountHoursWithSub", sender: nil)
        } else if dest == 1 {
            performSegue(withIdentifier: "unwindToClockInWithSub", sender: nil)
        } else if dest == 2 {
            performSegue(withIdentifier: "unwindToAddToScheduleWithSub", sender: nil)
        }
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToClockInWithSub" {
            let destVC = segue.destination as! EClockIn
            
            destVC.selectedClient = clientNameList [self.clientPicker.selectedRow(inComponent: 0)]
            destVC.selectedLocation = locationList [self.locationPicker.selectedRow(inComponent: 0)]
            destVC.selectedJob = jobList [self.jobPicker.selectedRow(inComponent: 0)].type
        } else if segue.identifier == "unwindToCountHoursWithSub" {
            let destVC = segue.destination as! ACountHours
            
            destVC.selectedClient = clientNameList [self.clientPicker.selectedRow(inComponent: 0)]
            destVC.selectedLocation = locationList [self.locationPicker.selectedRow(inComponent: 0)].address
            destVC.selectedJob = jobList [self.jobPicker.selectedRow(inComponent: 0)].type
        } else if segue.identifier == "unwindToAddToScheduleWithSub" {
            let destVC = segue.destination as! AAddToSchedule
            
            destVC.selectedClient = clientNameList [self.clientPicker.selectedRow(inComponent: 0)]
            destVC.selectedLocation = locationList [self.locationPicker.selectedRow(inComponent: 0)]
            destVC.selectedJob = jobList [self.jobPicker.selectedRow(inComponent: 0)].type
        }
    }
}
