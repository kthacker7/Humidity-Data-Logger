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
    var internalDiscDevices : [TDTempoDisc] = []
    var externalDiscDevice  : TDTempoDisc?
    
    var internalDevices : [TempoDiscDevice] = []
    var externalDevice : TempoDiscDevice?
    
    func getAverageTemperature() -> Double {
        var totalTemp = 0.0
        if internalDevices.count > 0 {
            for device in internalDevices {
                if device.currentTemperature != nil {
                    totalTemp += Double(device.currentTemperature!)
                }
            }
            return totalTemp / Double(internalDevices.count)
        } else {
            for device in internalDiscDevices {
                if device.currentTemperature != nil {
                    totalTemp += Double(device.currentTemperature!)
                }
            }
            return totalTemp / Double(internalDiscDevices.count)
        }
    }
    
    func getCurrentHumidity() -> Double {
        var totalTemp = 0.0
        if internalDevices.count > 0 {
            for device in internalDevices {
                if device.currentHumidity != nil {
                    totalTemp += Double(device.currentHumidity!)
                }
            }
            return totalTemp / Double(internalDevices.count)
        } else {
            if internalDiscDevices.count > 0 {
                for device in internalDiscDevices {
                    if device.currentHumidity != nil {
                        totalTemp += Double(device.currentHumidity!)
                    }
                }
                return totalTemp / Double(internalDiscDevices.count)
            }
        }
        return 0
    }
    
    func getCurrentDewPoint() -> Double {
        if let device = self.externalDiscDevice {
            if device.dewPoint != nil {
                return Double(device.averageDayDew!)
            }
        } else {
            if let device = self.externalDevice {
                if device.dewPoint != nil {
                    return Double(device.averageDayDew!)
                }
            }
        }
        return 0.0
    }
}
