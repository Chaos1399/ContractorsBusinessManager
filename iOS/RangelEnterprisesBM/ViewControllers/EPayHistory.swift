//
//  EPayHistory.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 2/22/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import UIKit
import FirebaseDatabase

class EPayHistory: CustomVCSuper, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    // MARK: - Outlets
    @IBOutlet weak var historyTable: UITableView!
    @IBOutlet weak var periodField: UITextField!
    @IBOutlet weak var dayField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var periodHeader: UILabel!
    @IBOutlet weak var dateHeader: UILabel!
    @IBOutlet weak var hourHeader: UILabel!
    
    // MARK: - Gobal Variables
    var perList : [PayPeriod]?
    var searchList : [PayPeriod]?
    var searching : Bool = false
    
    // MARK: - Required VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        historyTable.allowsSelection = false
        
        periodHeader.layer.borderWidth = 1
        periodHeader.layer.borderColor = UIColor.black.cgColor
        dateHeader.layer.borderWidth = 1
        dateHeader.layer.borderColor = UIColor.black.cgColor
        hourHeader.layer.borderWidth = 1
        hourHeader.layer.borderColor = UIColor.black.cgColor
        
        perList = []
        hiPri.async {
            self.fetchPeriods()
            
            self.fetchGroup.wait()
            DispatchQueue.main.async {
                self.historyTable.reloadData()
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchList!.count
        } else {
            return perList?.count ?? 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "payHistoryCell") as! payHistoryCell
        
        if self.searching {
            cell.perNumLabel.text = row.description
            cell.numHoursLabel.text = searchList! [row].totalHours.description
            cell.startLabel.text = df.string (from: searchList! [row].startDate)
            cell.endLabel.text = df.string (from: searchList! [row].endDate)
        } else {
            cell.perNumLabel.text = row.description
            cell.numHoursLabel.text = perList! [row].totalHours.description
            cell.startLabel.text = df.string (from: perList! [row].startDate)
            cell.endLabel.text = df.string (from: perList! [row].endDate)
        }
        
        return cell
    }
    
    // MARK: - Custom Methods
    func fetchPeriods () {
        let perRef = Database.database().reference (fromURL: self.user!.history)
        
        for i in 0..<self.user!.numPeriods {
            self.fetchGroup.enter()
            
            perRef.queryOrderedByKey().queryEqual(toValue: i.description).observeSingleEvent(of: .value, with: { (perSnap) in
                if perSnap.exists() {
                    let tempPer = PayPeriod.init(key: i, snapshot: perSnap)
                    self.perList?.append(tempPer)
                } else {
                    print ("Error occurred. no persnap")
                }
                self.fetchGroup.leave()
            })
        }
    }
    
    // MARK: - TextField Method
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if (perList != nil) && (perList!.count > 0) && (periodField.hasText || dayField.hasText) {
            searchButton.isEnabled = true
        } else {
            searchButton.isEnabled = false
            searching = false
        }
        
        return true
    }
    
    // MARK: - Button Methods
    @IBAction func didPressSearch(_ sender: UIButton) {
        var pToSearch : Int? = nil
        var dToSearch : Date? = nil
        
        var pSearch = false
        var dSearch = false
        
        print (periodField.text!.count)
        print (dayField.text!.count)
        
        if periodField.text!.count > 0 {
            pSearch = true
            pToSearch = Int (periodField.text!)
            
            if pToSearch == nil {
                self.presentAlert(alertTitle: "Error", alertMessage: "Type in a number for the period", actionTitle: "Ok", cancelTitle: nil, actionHandler: nil, cancelHandler: nil)
                return
            }
        }
        if dayField.text!.count > 0 {
            dSearch = true
            dToSearch = df.date (from: dayField.text!)
            
            if dToSearch == nil {
                self.presentAlert(alertTitle: "Error", alertMessage: "Type in date in MM-DD-YY format", actionTitle: "Ok", cancelTitle: nil, actionHandler: nil, cancelHandler: nil)
                return
            }
        }
        
        searchList = []
        searching = true
        if pSearch && dSearch {
            for i in 0..<perList!.count {
                if (i == pToSearch!) &&
                    (perList! [i].startDate.compare(dToSearch!) == ComparisonResult.orderedAscending) &&
                    (perList! [i].endDate.compare(dToSearch!) == ComparisonResult.orderedDescending) {
                    searchList!.append(perList! [i])
                }
            }
            historyTable.reloadData()
        } else if pSearch {
            for i in 0..<perList!.count {
                if (i == pToSearch!) {
                    searchList!.append(perList! [i])
                }
            }
            historyTable.reloadData()
        } else if dSearch {
            for i in 0..<perList!.count {
                if (perList! [i].startDate.compare(dToSearch!) == ComparisonResult.orderedAscending) &&
                    (perList! [i].endDate.compare(dToSearch!) == ComparisonResult.orderedDescending) {
                    searchList!.append(perList! [i])
                }
            }
            historyTable.reloadData()
        } else {
            searching = false
            perList = []
            hiPri.async {
                self.fetchPeriods()
                
                self.fetchGroup.wait()
                DispatchQueue.main.async {
                    self.historyTable.reloadData()
                }
            }
        }
    }
    @IBAction func didPressChangePage(_ sender: UIButton) {
        let actionSheet = UIAlertController (title: "Change Page", message: nil, preferredStyle: .actionSheet)
        let changeToMenu = UIAlertAction (title: "Menu", style: .default) { (action : UIAlertAction) in
            self.tabBarController?.selectedIndex = 0
        }
        let changeToSchedule = UIAlertAction (title: "View Schedule", style: .default, handler:
        { (action : UIAlertAction) in
            self.tabBarController?.selectedIndex = 1
        })
        let changetoWork = UIAlertAction (title: "Work", style: .default, handler:
        { (action : UIAlertAction) in
            self.tabBarController?.selectedIndex = 2
        })
        let changetoTimeBank = UIAlertAction (title: "Time Off", style: .default, handler:
        { (action : UIAlertAction) in
            self.tabBarController?.selectedIndex = 3
        })
        let cancelAction = UIAlertAction (title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(changeToMenu)
        actionSheet.addAction(changeToSchedule)
        actionSheet.addAction(changetoWork)
        actionSheet.addAction(changetoTimeBank)
        actionSheet.addAction(cancelAction)
        self.present (actionSheet, animated: true, completion: nil)
    }
}
