//
//  AViewCalendar.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 2/22/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import UIKit
import JTAppleCalendar
import FirebaseDatabase

class AViewCalendar: CustomVCSuper, JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    // MARK: - Outlets
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var viewJobTimeSwitch: UISwitch!
    
    // MARK: - Global Variables
    let cal = Calendar.init (identifier: .gregorian)
    var theDayJob : ScheduledWorkday?
    
    // MARK: - Required VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCalendarView()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - JTAppleCalendar Methods
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let cell = cell as! calendarDayCell
        cell.dateLabel.text = self.cal.component(.day, from: date).description
        handleCellSelection(view: cell)
        handleCellTextColor(view: cell, cellState: cellState)
    }
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "dayCell", for: indexPath) as! calendarDayCell
        cell.dateLabel.text = self.cal.component(.day, from: date).description
        handleCellSelection(view: cell)
        handleCellTextColor(view: cell, cellState: cellState)
        
        return cell
    }
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        df.dateFormat = "MM-dd-yy"
        let parameters = ConfigurationParameters (startDate: df.date(from: "01-01-16")!, endDate: df.date(from: "12-31-25")!)
        return parameters
    }
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellSelection(view: cell!)
        handleCellTextColor(view: cell!, cellState: cellState)
    }
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellSelection(view: cell)
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
        
        calendarView.visibleDates { (visibleDates) in
            self.setupViewsOfCalendar(from: visibleDates)
        }
    }
    func setupViewsOfCalendar (from visibleDates: DateSegmentInfo) {
        let dayOfMonth = visibleDates.monthDates.first!.date
        
        self.monthLabel.text = self.cal.monthName(from: dayOfMonth, spanish: false)
        self.yearLabel.text = self.cal.component(.year, from: dayOfMonth).description
    }
    func handleCellSelection (view: JTAppleCell?) {
        guard let validCell = view as? calendarDayCell else { return }
        if validCell.isSelected {
            validCell.selectionView.isHidden = false
            validCell.dateLabel.superview!.bringSubview(toFront: validCell.dateLabel)
            self.theDayJob = nil
        } else {
            validCell.selectionView.isHidden = true
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
                    
                    if (startYear <= selectedYear) && (startMonth <= selectedMonth) && (startDay <= selectedDay) &&
                        (endYear >= selectedYear) && (endMonth >= selectedMonth) && (endDay >= selectedDay) {
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
        let changeToMenu = UIAlertAction (title: "Menu", style: .default, handler: { (action : UIAlertAction) in
            self.tabBarController?.selectedIndex = 0
        })
        let changetoCountHours = UIAlertAction (title: "Count Hours", style: .default, handler:
        { (action : UIAlertAction) in
            self.tabBarController?.selectedIndex = 1
        })
        let changeToAddJob = UIAlertAction (title: "Add Job", style: .default, handler:
        { (action : UIAlertAction) in
            self.tabBarController?.selectedIndex = 3
        })
        let changetoReviseHours = UIAlertAction (title: "Revise Hours", style: .default, handler:
        { (action : UIAlertAction) in
            self.tabBarController?.selectedIndex = 5
        })
        let cancelAction = UIAlertAction (title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction (changeToMenu)
        actionSheet.addAction (changetoCountHours)
        actionSheet.addAction (changeToAddJob)
        actionSheet.addAction (changetoReviseHours)
        actionSheet.addAction (cancelAction)
        self.present (actionSheet, animated: true, completion: nil)
    }
    @IBAction func didPressGo(_ sender: UIButton) {
        if viewJobTimeSwitch.isOn {
            performSegue(withIdentifier: "jobDetail", sender: nil)
        } else {
            performSegue(withIdentifier: "scheduleDetail", sender: nil)
        }
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "jobDetail" {
            let destVC = segue.destination as! AViewJobTime
            destVC.selectedDate = calendarView.selectedDates.first
        } else {
            let destVC = segue.destination as! ASchedule
            destVC.selectedDate = calendarView.selectedDates.first
        }
    }
    @IBAction func unwindToViewCalendar (_ segue: UIStoryboardSegue) {}
}
