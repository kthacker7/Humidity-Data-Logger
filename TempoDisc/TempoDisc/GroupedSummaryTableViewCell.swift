//
//  GroupedSummaryTableViewCell.swift
//  Tempo Utility
//
//  Created by Kunal Thacker on 12/22/16.
//  Copyright © 2016 BlueMaestro. All rights reserved.
//

import UIKit

class GroupedSummaryTableViewCell: UITableViewCell {

    
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var bsValueLabel: UILabel!
    @IBOutlet weak var waterDropImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
