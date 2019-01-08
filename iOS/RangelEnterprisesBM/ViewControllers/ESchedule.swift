//
//  ESchedule.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 2/22/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

// TODO: Make it show all things user is scheduled to do that day

import UIKit
import JTAppleCalendar
import FirebaseDatabase

class ESchedule: CustomVCSuper, JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    // MARK: - Outlets
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!
    @IBOutlet weak var atLabel: UILabel!
    @IBOutlet weak var doingLabel: UILabel!
    @IBOutlet weak var forLabel: UILabel!
    @IBOutlet weak var clientLabel: UILabel!
    
    // MARK: - Global Variables
    let cal = Calendar.init (identifier: .gregorian)
    var theDayJob : ScheduledWorkday?
    
    // MARK: - Required VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCalendarView()
        
        forLabel.isHidden = true
        atLabel.isHidden = true
        doingLabel.isHidden = true
        clientLabel.isHidden = true
        locationLabel.isHidden = true
        jobLabel.isHidden = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - JTAppleCalendar Methods
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let cell = cell as! calendarDayCell
        
        cell.dateLabel.text = self.cal.component(.day, from: date).description
    }
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "dayCell", for: indexPath) as! calendarDayCell
        cell.dateLabel.text = cellState.text
        
        handleCellSelection(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        
        return cell
    }
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        df.dateFormat = "MM-dd-yy"
        let parameters = ConfigurationParameters (startDate: df.date(from: "01-01-16")!, endDate: df.date(from: "12-31-25")!)
        return parameters
    }
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellSelection(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
    }
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellSelection(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
    }
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        calendar.deselectAllDates(triggerSelectionDelegate: false)
        setupViewsOfCalendar(from: visibleDates)
    }
    
    
    // MARK: - Custom Methods
    func setupCalendarView () {
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
        calendarView.allowsMultipleSelection = false
        
        calendarView.scrollToDate(Date.init(), triggerScrollToDateDelegate: false, animateScroll: false)
        calendarView.selectDates([Date.init()])
        
        calendarView.visibleDates { (visibleDates) in
            self.setupViewsOfCalendar(from: visibleDates)
        }
    }
    func setupViewsOfCalendar (from visibleDates: DateSegmentInfo) {
        let dayOfMonth = visibleDates.monthDates.first!.date
        
        self.monthLabel.text = self.cal.monthName(from: dayOfMonth, spanish: false)
        self.yearLabel.text = self.cal.component(.year, from: dayOfMonth).description
    }
    func handleCellSelection (view: JTAppleCell?, cellState: CellState) {
        guard let validCell = view as? calendarDayCell else { return }
        
        if validCell.isSelected {
            validCell.selectionView.isHidden = false
            
            forLabel.isHidden = false
            atLabel.isHidden = false
            doingLabel.isHidden = false
            clientLabel.isHidden = false
            locationLabel.isHidden = false
            jobLabel.isHidden = false
            
            validCell.dateLabel.superview!.bringSubview(toFront: validCell.dateLabel)
            
            self.theDayJob = nil
            hiPri.async {
                self.fetchJobData(forDate: cellState.date)
                self.fetchGroup.wait()
                
                DispatchQueue.main.async {
                    if self.theDayJob != nil {
                        self.clientLabel.text = self.theDayJob!.client
                        self.locationLabel.text = self.theDayJob!.location
                        self.jobLabel.text = self.theDayJob!.job
                    } else {
                        self.clientLabel.text = "Not Scheduled"
                        self.locationLabel.text = "Not Scheduled"
                        self.jobLabel.text = "Not Scheduled"
                    }
                }
            }
        } else {
            validCell.selectionView.isHidden = true
            
            forLabel.isHidden = true
            atLabel.isHidden = true
            doingLabel.isHidden = true
            clientLabel.isHidden = true
            locationLabel.isHidden = true
            jobLabel.isHidden = true
        }
    }
    func handleCellTextColor (view: JTAppleCell?, cellState: CellState) {
        guard let validCell = view as? calendarDayCell else { return }
        
        if validCell.isSelected {
            validCell.dateLabel.textColor = .black
        } else {
            if cellState.dateBelongsTo == .thisMonth {
                validCell.dateLabel.textColor = .white
            } else {
                validCell.dateLabel.textColor = .gray
            }
        }
    }
    func fetchJobData (forDate date: Date) {
        let scheduledRef = Database.database().reference(fromURL: self.user!.toWork)
        let selectedYear = self.cal.component(.year, from: date)
        let selectedMonth = self.cal.component(.month, from: date)
        let selectedDay = self.cal.component(.day, from: date)
        
        for i in 0..<self.user!.numDaysScheduled {
            self.fetchGroup.enter()
            scheduledRef.queryOrderedByKey().queryEqual(toValue: i.description).observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.exists() {
                    let tempScheduledDay = ScheduledWorkday.init(key: i, snapshot: snapshot)
                    let startYear = self.cal.component(.year, from: tempScheduledDay.startDate)
                    let startMonth = self.cal.component(.month, from: tempScheduledDay.startDate)
                    let startDay = self.cal.component(.day, from: tempScheduledDay.startDate)
                    let endYear = self.cal.component(.year, from: tempScheduledDay.endDate)
                    let endMonth = self.cal.component(.month, from: tempScheduledDay.endDate)
                    let endDay = self.cal.component(.day, from: tempScheduledDay.endDate)
                    
                    if (startYear <= selectedYear) && (endYear >= selectedYear) &&
                        ((startMonth < selectedMonth) || ((startMonth == selectedMonth) && (startDay <= selectedDay))) &&
                        ((endMonth > selectedMonth) || ((endMonth == selectedMonth) && (endDay >= selectedDay))) {
                        self.theDayJob = tempScheduledDay
                    }
                }
                self.fetchGroup.leave()
            }
        }
    }
    
    
    // MARK: - Button Methods
    @IBAction func changeRight(_ sender: UIButton) {
        calendarView.deselectAllDates()
        calendarView.scrollToSegment(.next, triggerScrollToDateDelegate: true, animateScroll: true)
    }
    @IBAction func changeLeft(_ sender: UIButton) {
        calendarView.deselectAllDates()
        calendarView.scrollToSegment(.previous, triggerScrollToDateDelegate: true, animateScroll: true)
    }
    @IBAction func didPressChangePage(_ sender: UIButton) {
        let actionSheet = UIAlertController (title: "Change Page", message: nil, preferredStyle: .actionSheet)
        let changeToMenu = UIAlertAction (title: "Menu", style: .default) { (action : UIAlertAction) in
            self.tabBarController?.selectedIndex = 0
        }
        let changeToWork = UIAlertAction (title: "Work", style: .default, handler:
        { (action : UIAlertAction) in
            self.tabBarController?.selectedIndex = 2
        })
        let changetoTimeBank = UIAlertAction (title: "Time Off", style: .default, handler:
        { (action : UIAlertAction) in
            self.tabBarController?.selectedIndex = 3
        })
        let changetoHistory = UIAlertAction (title: "Pay Period History", style: .default, handler:
        { (action : UIAlertAction) in
            self.tabBarController?.selectedIndex = 4
        })
        let cancelAction = UIAlertAction (title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(changeToMenu)
        actionSheet.addAction(changeToWork)
        actionSheet.addAction(changetoTimeBank)
        actionSheet.addAction(changetoHistory)
        actionSheet.addAction(cancelAction)
        self.present (actionSheet, animated: true, completion: nil)
    }
}

// MARK: - Calendar Extension
extension Calendar {
    func monthName (from date: Date, spanish: Bool) -> String {
        let monthNum = self.component(.month, from: date)
        if !spanish {
            switch monthNum {
            case 1:
                return "January"
            case 2:
                return "February"
            case 3:
                return "March"
            case 4:
                return "April"
            case 5:
                return "May"
            case 6:
                return "June"
            case 7:
                return "July"
            case 8:
                return "August"
            case 9:
                return "September"
            case 10:
                return "October"
            case 11:
                return "November"
            default:
                return "December"
            }
        } else {
            switch monthNum {
            case 1:
                return "Enero"
            case 2:
                return "Febrero"
            case 3:
                return "Marzo"
            case 4:
                return "Abril"
            case 5:
                return "Mayo"
            case 6:
                return "Junio"
            case 7:
                return "Julio"
            case 8:
                return "Agosto"
            case 9:
                return "Septiembre"
            case 10:
                return "Octubre"
            case 11:
                return "Noviembre"
            default:
                return "Diciembre"
            }
        }
    }
}



