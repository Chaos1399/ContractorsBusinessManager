//
//  calendarDayCell.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 3/7/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import UIKit
import JTAppleCalendar

class calendarDayCell: JTAppleCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var selectionView: UIView!
    
    override func draw(_ rect: CGRect) {
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 0.5
    }
}
