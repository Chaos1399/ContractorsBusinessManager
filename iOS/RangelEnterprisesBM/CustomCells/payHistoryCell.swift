//
//  payHistoryCell.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 3/2/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import UIKit

class payHistoryCell: UITableViewCell {
    @IBOutlet weak var perNumLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var numHoursLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        perNumLabel.layer.borderColor = UIColor.black.cgColor
        perNumLabel.layer.borderWidth = 1.5
        startLabel.layer.borderColor = UIColor.black.cgColor
        startLabel.layer.borderWidth = 1.5
        endLabel.layer.borderColor = UIColor.black.cgColor
        endLabel.layer.borderWidth = 1.5
        numHoursLabel.layer.borderColor = UIColor.black.cgColor
        numHoursLabel.layer.borderWidth = 1.5
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 2.0
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
