//
//  InternalDeviceDetailsTableViewCell.swift
//  Cornerstone Humidity Data Logger
//
//  Created by Kunal Thacker on 12/18/16.
//  Copyright © 2016 Cornerstone Humidity. All rights reserved.
//

import UIKit

class InternalDeviceDetailsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var deviceNameLabel: UILabel!
    
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var rssiLabel: UILabel!
    @IBOutlet weak var batteryLabel: UILabel!
    @IBOutlet weak var currentTemperatureLabel: UILabel!
    @IBOutlet weak var currentHumidityLabel: UILabel!
    @IBOutlet weak var currentDewPointLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupUsingDevice(device: TempoDevice?) {
        if device == nil {
            self.uuidLabel.text = "-"
            self.versionLabel.text = "-"
            self.rssiLabel.text = "-"
            self.batteryLabel.text = "-"
            self.currentDewPointLabel.text = "-"
            self.currentHumidityLabel.text = "-"
            self.currentTemperatureLabel.text = "-"
            self.deviceNameLabel.text = "-"
        }
        self.deviceNameLabel.text = device!.name
        self.uuidLabel.text = device!.uuid
        if let peripheral = device!.peripheral {
            self.rssiLabel.text = "\(peripheral.rssi)dBm"
        } else {
            self.rssiLabel.text = "-"
        }
        self.versionLabel.text = device!.version
        if let battery = device!.battery {
            self.batteryLabel.text = "\(battery)%"
        } else {
            self.batteryLabel.text = "-"
        }
        if let temperature = device!.currentTemperature {
            self.currentTemperatureLabel.text = "\(temperature)°C"
        } else {
            self.currentTemperatureLabel.text = "-"
        }
        if let humidity = device!.currentHumidity {
            self.currentHumidityLabel.text = "\(humidity)% RH"
        } else {
            self.currentHumidityLabel.text = "-"
        }
        if let tempoDiscDevice = device! as? TempoDiscDevice {
            if let dewPoint = tempoDiscDevice.dewPoint {
                self.currentDewPointLabel.text = "\(dewPoint)°C"
            } else {
                self.currentDewPointLabel.text = "-"
            }
        } else {
            self.currentDewPointLabel.text = "-"
        }
    }
}
