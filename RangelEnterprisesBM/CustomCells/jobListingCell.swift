//
//  jobListingCell.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 3/2/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import UIKit

class jobListingCell: UITableViewCell {
    @IBOutlet weak var jobDes: UILabel!
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var endDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1.0
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
