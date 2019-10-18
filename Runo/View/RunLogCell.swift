//
//  RunLogCell.swift
//  Runo
//
//  Created by Mahmoud Elshakoushy on 10/14/19.
//  Copyright © 2019 Mahmoud Elshakoushy. All rights reserved.
//

import UIKit

class RunLogCell: UITableViewCell {

    @IBOutlet weak var runDurationLbl: UILabel!
    @IBOutlet weak var totalDistanceLbl: UILabel!
    @IBOutlet weak var averagePaceLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(run: Run) {
        runDurationLbl.text = run.duration.formateTimeDurationToString()
        totalDistanceLbl.text = "\(run.distance.metersToMiles(places: 2)) mi"
        averagePaceLbl.text = run.pace.formateTimeDurationToString()
        dateLbl.text = run.date.getDateString()
    }
    
}
