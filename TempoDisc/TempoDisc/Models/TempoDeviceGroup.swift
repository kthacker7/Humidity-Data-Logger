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
            return (round(totalTemp / Double(internalDevices.count)*1000.0))/1000.0
        } else {
            for device in internalDiscDevices {
                if device.currentTemperature != nil {
                    totalTemp += Double(device.currentTemperature!)
                }
            }
            return (round(totalTemp / Double(internalDiscDevices.count)*1000.0))/1000.0
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
            return (round(totalTemp / Double(internalDevices.count) * 1000.0))/1000.0
        } else {
            if internalDiscDevices.count > 0 {
                for device in internalDiscDevices {
                    if device.currentHumidity != nil {
                        totalTemp += Double(device.currentHumidity!)
                    }
                }
                return (round(totalTemp / Double(internalDiscDevices.count) * 1000.0))/1000.0
            }
        }
        return 0
    }
    
    func getCurrentDewPoint() -> Double {
        if let device = self.externalDiscDevice {
            if device.dewPoint != nil {
                return (round(Double(device.averageDayDew!) * 1000.0))/1000.0
            }
        } else {
            if let device = self.externalDevice {
                if device.dewPoint != nil {
                    return (round(Double(device.averageDayDew!) * 1000.0))/1000.0
                }
            }
        }
        return 0.0
    }
}
