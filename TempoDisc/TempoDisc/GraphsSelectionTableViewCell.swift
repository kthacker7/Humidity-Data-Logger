//
//  GraphsSelectionTableViewCell.swift
//  Cornerstone Humidity Data Logger
//
//  Created by Kunal Thacker on 12/19/16.
//  Copyright © 2016 Cornerstone Humidity. All rights reserved.
//

import UIKit

protocol GraphSelectionDelegate {
    func selectRange()
    func allData()
}

class GraphsSelectionTableViewCell: UITableViewCell {

    @IBOutlet weak var selectRangeButton: UIButton!
    @IBOutlet weak var allDataButton: UIButton!
    
    var delegate : GraphSelectionDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectRangeButton.layer.cornerRadius = 5.0
        self.selectRangeButton.layer.borderWidth = 1.0
        self.selectRangeButton.layer.borderColor = UIColor(colorLiteralRed: 197.0/255.0, green: 10.0/255.0, blue: 39.0/255.0, alpha: 1.0).cgColor
        
        self.allDataButton.layer.cornerRadius = 5.0
        self.allDataButton.layer.borderWidth = 1.0
        self.allDataButton.layer.borderColor = UIColor(colorLiteralRed: 197.0/255.0, green: 10.0/255.0, blue: 39.0/255.0, alpha: 1.0).cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func selectRangeButtonTapped(_ sender: Any) {
        delegate?.selectRange()
    }
    
    @IBAction func allDataButtonTapped(_ sender: Any) {
        delegate?.allData()
    }
}
