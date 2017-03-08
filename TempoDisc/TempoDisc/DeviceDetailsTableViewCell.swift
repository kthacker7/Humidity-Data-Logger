//
//  DeviceDetailsTableViewCell.swift
//  Cornerstone Humidity Data Logger
//
//  Created by Kunal Thacker on 12/17/16.
//  Copyright © 2016 Cornerstone Humidity. All rights reserved.
//

import UIKit

class DeviceDetailsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var humidityImageView: UIImageView!
    
    @IBOutlet weak var flatNumberLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var dewLabel: UILabel!
    
    @IBOutlet weak var humidityImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var humidityImageLeadingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupUsingExternalDevice(device: TDTempoDisc?, name: String) {
        self.flatNumberLabel.text = name
        if device == nil {
            self.temperatureLabel.text = "-"
            self.humidityLabel.text = "-"
            self.dewLabel.text = "-"
        }
        if let tempoDiscDevice = device {
            if let temperature = tempoDiscDevice.averageDayTemperature {
                self.temperatureLabel.text = "\(temperature)°C"
            } else {
                self.temperatureLabel.text = "-"
            }
            if let dewPoint = tempoDiscDevice.dewPoint {
                self.dewLabel.text = "\(dewPoint)°C"
            } else {
                
                self.dewLabel.text = "-"
            }
        } else {
            self.temperatureLabel.text = "-"
            self.dewLabel.text = "-"
        }
        if let currHumidity = device!.currentHumidity {
            self.humidityLabel.text = "\(currHumidity) %"
        } else {
            self.humidityLabel.text = "-"
        }
    }
    
}
