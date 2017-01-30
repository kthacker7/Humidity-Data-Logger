//
//  ExportDataTableViewCell.swift
//  Cornerstone Humidity Data Logger
//
//  Created by Kunal Thacker on 12/19/16.
//  Copyright © 2016 Cornerstone Humidity. All rights reserved.
//

import UIKit

protocol ExportDataDelegate {
    func exportAsPDF()
    func exportAsCSV()
}

class ExportDataTableViewCell: UITableViewCell {
    
    var delegate : ExportDataDelegate?

    @IBOutlet weak var exportAsCSVButton: UIButton!
    @IBOutlet weak var exportAsPDFButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.exportAsCSVButton.layer.cornerRadius = 5.0
        self.exportAsCSVButton.layer.borderWidth = 1.0
        self.exportAsCSVButton.layer.borderColor = UIColor(colorLiteralRed: 197.0/255.0, green: 10.0/255.0, blue: 39.0/255.0, alpha: 1.0).cgColor
        
        self.exportAsPDFButton.layer.cornerRadius = 5.0
        self.exportAsPDFButton.layer.borderWidth = 1.0
        self.exportAsPDFButton.layer.borderColor = UIColor(colorLiteralRed: 197.0/255.0, green: 10.0/255.0, blue: 39.0/255.0, alpha: 1.0).cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func exportAsPDFTapped(_ sender: Any) {
        self.delegate?.exportAsPDF()
    }
    
    @IBAction func exportAsCSVTapped(_ sender: Any) {
        self.delegate?.exportAsCSV()
    }
    
    
}
