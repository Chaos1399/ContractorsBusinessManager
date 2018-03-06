//
//  AEditJob.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 2/22/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import UIKit

class AEditJob: CustomVCSuper, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var jobsList: UITableView!
    
    var allJobs : [Job]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func didSelectSubmit(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindToAddJob", sender: allJobs)
    }
    @IBAction func didSelectCancel(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindToAddJob", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allJobs!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newCell = tableView.dequeueReusableCell(withIdentifier: "jobListingCell", for: indexPath) as! jobListingCell
        let df = DateFormatter ()
        df.locale = Locale (identifier: "en_US")
        df.timeStyle = .none
        df.dateFormat = "MM/dd/yy"
        
        newCell.jobDes.text = allJobs! [indexPath.row].type
        newCell.startDate.text = df.string(from: allJobs! [indexPath.row].startDate)
        newCell.endDate.text = df.string(from: allJobs! [indexPath.row].endDate)
        
        return newCell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if sender != nil {
            let destVC = segue.destination as! AAddJob
            
            destVC.allJobs = sender as! [Job]
            destVC.jobsList.reloadData()
        }
    }
}
