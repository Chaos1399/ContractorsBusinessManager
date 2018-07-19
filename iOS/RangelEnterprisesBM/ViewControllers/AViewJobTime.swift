//
//  AViewJobTime.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 2/22/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import UIKit
import FirebaseDatabase

class AViewJobTime: CustomVCSuper, UITableViewDelegate, UITableViewDataSource {
    // MARK: - Outlets
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var jobTimeTable: UITableView!
    
    // MARK: - Global Variables
    var selectedDate : Date?
    let cal = Calendar.init(identifier: .gregorian)
    var currentclients : [String] = []
    var currentlocations : [String] = []
    var currentjobs : [Job] = []
    
    // MARK: - Required VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        jobTimeTable.allowsSelection = false
        
        let dateString = cal.monthName(from: selectedDate!, spanish: false) + " \(cal.component(.day, from: selectedDate!))," +
        " \(cal.component(.year, from: selectedDate!))"
        dateLabel.text = dateString
        
        
        hiPri.async {
            if self.clientNameList.count == 0 {
                self.clientListInit()
                self.fetchGroup.wait()
            }
            self.fetchJobList()
            self.fetchGroup.wait()
            DispatchQueue.main.async {
                self.jobTimeTable.reloadData()
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentjobs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "jobTimeCell") as! jobTimeCell
        let row = indexPath.row
        
        cell.clientLabel.text = currentclients [row]
        cell.addressLabel.text = currentlocations [row]
        cell.jobLabel.text = currentjobs [row].type
        cell.startLabel.text = self.df.string(from: currentjobs [row].startDate)
        cell.endLabel.text = self.df.string(from: currentjobs [row].endDate)
        
        return cell
    }
    
    // MARK: - Custom Methods
    func fetchJobList () {
        let selectedYear = cal.component(.year, from: selectedDate!)
        let selectedMonth = cal.component(.month, from: selectedDate!)
        let selectedDay = cal.component(.day, from: selectedDate!)
        
        for clientName in self.clientNameList {
            self.fetchGroup.enter()
            self.clientBase!.queryOrderedByKey().queryEqual(toValue: clientName).observeSingleEvent(of: .value, with: { (clientSnap) in
                if clientSnap.exists() {
                    let tempClient = Client.init(key: clientName, snapshot: clientSnap)
                    let propRef = Database.database().reference(fromURL: tempClient.properties)
                    
                    for i in 0..<tempClient.numProps {
                        self.fetchGroup.enter()
                        propRef.queryOrderedByKey().queryEqual(toValue: i.description).observeSingleEvent(of: .value, with: { (propSnap) in
                            if propSnap.exists() {
                                let tempProp = Location.init(key: i, snapshot: propSnap)
                                let jobRef = Database.database().reference(fromURL: tempProp.jobs)
                                
                                for j in 0..<tempProp.numJobs {
                                    self.fetchGroup.enter()
                                    jobRef.queryOrderedByKey().queryEqual(toValue: j.description).observeSingleEvent(of: .value, with: { (jobSnap) in
                                        if jobSnap.exists() {
                                            let tempJob = Job.init(key: j, snapshot: jobSnap)
                                            
                                            let startYear = self.cal.component(.year, from: tempJob.startDate)
                                            let startMonth = self.cal.component(.month, from: tempJob.startDate)
                                            let startDay = self.cal.component(.day, from: tempJob.startDate)
                                            
                                            let endYear = self.cal.component(.year, from: tempJob.endDate)
                                            let endMonth = self.cal.component(.month, from: tempJob.endDate)
                                            let endDay = self.cal.component(.day, from: tempJob.endDate)
                                            
                                            
                                            if (startYear <= selectedYear) && (endYear >= selectedYear) &&
                                                ((startMonth < selectedMonth) || ((startMonth == selectedMonth) && (startDay <= selectedDay))) &&
                                                ((endMonth > selectedMonth) || ((endMonth == selectedMonth) && (endDay >= selectedDay))) {
                                                
                                                self.currentclients.append(tempClient.name)
                                                self.currentlocations.append(tempProp.address)
                                                self.currentjobs.append(tempJob)
                                            }
                                        }
                                        self.fetchGroup.leave()
                                    })
                                }
                            }
                            self.fetchGroup.leave()
                        })
                    }
                }
                self.fetchGroup.leave()
            })
        }
    }
    
    // MARK: - Button Methods
    @IBAction func didPressBack(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindToCalendar", sender: nil)
    }
}
