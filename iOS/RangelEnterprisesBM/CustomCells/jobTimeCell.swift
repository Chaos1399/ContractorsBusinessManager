//
//  jobTimeCell.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 3/2/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import UIKit

class jobTimeCell: UITableViewCell {
    @IBOutlet weak var clientLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1.0
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
