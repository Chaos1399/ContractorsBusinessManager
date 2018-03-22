//
//  GlossyButton.swift
//  RangelEnterprisesBM
//
//  Created by Cristian Rangel on 3/11/18.
//  Copyright © 2018 Cristian Rangel. All rights reserved.
//

import UIKit

class GlossyButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //self.setTitleColor(.white, for: .normal)
    }
    
    override func draw(_ rect: CGRect) {
        let backgroundRect = UIBezierPath (roundedRect: rect, cornerRadius: 10.0)
        UIColor (red: (103 / 255.0), green: (149 / 255.0), blue: (160 / 255.0), alpha: 1.0).setFill()
        backgroundRect.fill()
        
        let highlight1 = UIBezierPath (roundedRect: rect.divided(atDistance: rect.midY, from: .minYEdge).slice, cornerRadius: 10.0)
        UIColor (red: (133 / 255.0), green: (179 / 255.0), blue: (190 / 255.0), alpha: 1.0).setFill()
        highlight1.fill ()
    }
}
