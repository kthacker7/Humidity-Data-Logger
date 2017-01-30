//
//  TempoDeviceGroup.swift
//  Tempo Utility
//
//  Created by Kunal Thacker on 12/21/16.
//  Copyright © 2016 BlueMaestro. All rights reserved.
//

import Foundation

@objc class TempoDeviceGroup : NSObject {
    var groupName : String = ""
    var internalDevices : [TempoDevice] = []
    var externalDevice  : TempoDevice?
    
    func getAverageTemperature() -> Double {
        var totalTemp = 0.0
        for device in internalDevices {
            if device.currentTemperature != nil {
                totalTemp += Double(device.currentTemperature!)
            }
        }
        return totalTemp / Double(internalDevices.count)
    }
    
    func getCurrentHumidity() -> Double {
        var totalTemp = 0.0
        for device in internalDevices {
            if device.currentHumidity != nil {
                totalTemp += Double(device.currentHumidity!)
            }
        }
        return totalTemp / Double(internalDevices.count)
    }
    
    func getCurrentDewPoint() -> Double {
        if let device = self.externalDevice as? TempoDiscDevice {
            if device.dewPoint != nil {
                return Double(device.averageDayDew!)
            }
        }
        return 0.0
    }
}
