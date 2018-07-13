//
//  DateTimeChoose.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 3/18/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import UIKit
import JTAppleCalendar

class DateTimeChoose: CustomVCSuper, JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    // MARK: - Outlets
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var startPicker: UIDatePicker!
    @IBOutlet weak var endPicker: UIDatePicker!
    
    // MARK: - Global Variables
    let cal = Calendar.init(identifier: .gregorian)
    var selectedDay : Date?
    var startTime : Date?
    var endTime : Date?
    
    // MARK: - Required VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if selectedDay != nil {
            setupCalendarView(startDate: selectedDay!)
        } else {
            setupCalendarView(startDate: Date.init())
        }
        if startTime != nil {
            startPicker.setDate(startTime!, animated: false)
        }
        if endTime != nil {
            endPicker.setDate(endTime!, animated: false)
        }
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
    func setupCalendarView (startDate: Date) {
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
        calendarView.allowsMultipleSelection = false
        
        calendarView.scrollToDate(startDate, triggerScrollToDateDelegate: false, animateScroll: false)
        
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
            
            validCell.dateLabel.superview!.bringSubview(toFront: validCell.dateLabel)
            
            selectedDay = cellState.date
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
    
    // MARK: - Button Methods
    @IBAction func didSelectSubmit(_ sender: UIButton) {
        if selectedDay != nil {
            performSegue(withIdentifier: "unwindToReviseHoursWithSub", sender: nil)
        } else {
            self.presentAlert(alertTitle: "Error", alertMessage: "You have not chosen a day", actionTitle: "Ok", cancelTitle: nil, actionHandler: nil, cancelHandler: nil)
        }
    }
    @IBAction func didSelectBack(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindToReviseHoursWithCancel", sender: nil)
    }
    @IBAction func changeRight(_ sender: UIButton) {
        calendarView.deselectAllDates()
        calendarView.scrollToSegment(.next, triggerScrollToDateDelegate: true, animateScroll: true)
    }
    @IBAction func changeLeft(_ sender: UIButton) {
        calendarView.deselectAllDates()
        calendarView.scrollToSegment(.previous, triggerScrollToDateDelegate: true, animateScroll: true)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToReviseHoursWithSub" {
            let destVC = segue.destination as! AReviseHours
            
            destVC.selectedDay = selectedDay
            destVC.startTime = startPicker.date
            destVC.endTime = endPicker.date
        }
    }
}
