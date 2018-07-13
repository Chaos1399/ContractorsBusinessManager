//
//  hourCountCell.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 3/2/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import UIKit

class hourCountCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var payLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        nameLabel.layer.borderWidth = 1
        nameLabel.layer.borderColor = UIColor.black.cgColor
        hourLabel.layer.borderWidth = 1
        hourLabel.layer.borderColor = UIColor.black.cgColor
        payLabel.layer.borderWidth = 1
        payLabel.layer.borderColor = UIColor.black.cgColor
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1.0
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
