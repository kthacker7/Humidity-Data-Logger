//
//  TempoHelperMethodsSwift.swift
//  Tempo Utility
//
//  Created by Kunal Thacker on 2/20/17.
//  Copyright © 2017 BlueMaestro. All rights reserved.
//

import Foundation

class TempoHelperMethodsSwift {
    static func createCSVFileForGroup(deviceGroup : TempoDeviceGroup) -> String {
        if let fileName = TempoHelperMethods.createFileName(withAttachmentType: "CSV", withPath: true) {
            let output = OutputStream.toMemory()
            if let writer = CHCSVWriter.init(outputStream: output, encoding: String.Encoding.utf8.rawValue, delimiter: ((",") as NSString).character(at: 0)) {
                writer.writeField("Name")
                writer.writeField("RH (%)")
                writer.writeField("Temperature (°C)")
                writer.writeField("TD (°C)")
                writer.writeField("G/Kg")
                writer.writeField("VP(kPa)")
                writer.writeField("G/M3")
                writer.writeField("SVP")
                writer.finishLine()
                var externalGPKG : String?
                var externalVP : String?
                var externalVPVal : Double = 0.0
                var internalAverageGPKG : Double = 0.0
                var internalAverageVP : Double = 0.0
                if let external = deviceGroup.externalDevice {
                    if let externalDisc = external as? TempoDiscDevice {
                        let svp = 610.78 * exp((Double(externalDisc.averageDayTemperature!) * 17.2694) / (Double(externalDisc.averageDayTemperature!) + 238.3))
                        let vp = (svp / 1000.0) * (Double(externalDisc.averageDayHumidity!) / 100.0)
                        let gpm3 = ((vp * 1000.0) / ((273.0 + Double(externalDisc.averageDayTemperature!)) * 461.5)) * 1000.0
                        let gpkg = gpm3 * 0.83174
                        writer.writeField(externalDisc.name)
                        writer.writeField(String((round(Double(externalDisc.averageDayHumidity!) * 1000.0)/1000.0)))
                        writer.writeField(String((round(Double(externalDisc.averageDayTemperature!) * 1000.0)/1000.0)))
                        writer.writeField(String(round(Double(externalDisc.averageDayDew!)*1000.0)/1000.0))
                        writer.writeField(String(round(gpkg * 1000.0)/1000.0))
                        writer.writeField(String(round(vp * 1000.0)/1000.0))
                        writer.writeField(String(round(gpm3 * 1000.0)/1000.0))
                        writer.writeField(String(round(svp * 1000.0)/1000.0))
                        externalVP = String(round(vp * 1000.0)/1000.0)
                        externalGPKG = String(round(gpkg * 1000.0)/1000.0)
                        externalVPVal = round(vp * 1000.0)/1000.0
                        writer.finishLine()
                    }
                }
                for internalDevice in deviceGroup.internalDevices {
                    if let internalDisc = internalDevice as? TempoDiscDevice {
                        let svp = 610.78 * exp((Double(internalDisc.averageDayTemperature!) * 17.2694) / (Double(internalDisc.averageDayTemperature!) + 238.3))
                        let vp = (svp / 1000.0) * (Double(internalDisc.averageDayHumidity!) / 100.0)
                        let gpm3 = ((vp * 1000.0) / ((273.0 + Double(internalDisc.averageDayTemperature!)) * 461.5)) * 1000.0
                        let gpkg = gpm3 * 0.83174
                        internalAverageVP += vp
                        internalAverageGPKG += gpkg
                        writer.writeField(internalDisc.name)
                        writer.writeField(String(round(Double(internalDisc.averageDayHumidity!) * 1000.0)/1000.0))
                        writer.writeField(String(round(Double(internalDisc.averageDayTemperature!) * 1000.0)/1000.0))
                        writer.writeField(String(round(Double(internalDisc.averageDayDew!)*1000.0)/1000.0))
                        writer.writeField(String(round(gpkg * 1000.0)/1000.0))
                        writer.writeField(String(round(vp * 1000.0)/1000.0))
                        writer.writeField(String(round(gpm3 * 1000.0)/1000.0))
                        writer.writeField(String(round(svp * 1000.0)/1000.0))
                        writer.finishLine()
                    }
                }
                writer.writeField(" ")
                writer.finishLine()
                writer.writeField(" ")
                writer.finishLine()
                writer.writeField("Location")
                writer.writeField("G/kg")
                writer.writeField("VP(kPa)")
                writer.finishLine()
                writer.writeField("External")
                if externalGPKG != nil {
                    writer.writeField(externalGPKG!)
                } else {
                    writer.writeField(" ")
                }
                if externalVP != nil {
                    writer.writeField(externalVP!)
                } else {
                    writer.writeField(" ")
                }
                writer.finishLine()
                writer.writeField("Internal")
                if deviceGroup.internalDevices.count != 0 {
                    internalAverageGPKG = internalAverageGPKG/Double(deviceGroup.internalDevices.count)
                    internalAverageVP = internalAverageVP / Double(deviceGroup.internalDevices.count)
                    
                    writer.writeField(String(round(internalAverageGPKG * 1000.0)/1000.0))
                    writer.writeField(String(round(internalAverageVP * 1000.0)/1000.0))
                }
                writer.finishLine()
                writer.writeField(" ")
                writer.finishLine()
                writer.writeField("BS:5250 outcome:")
                writer.writeField("\(internalAverageVP - externalVPVal)")
                writer.finishLine()
                writer.closeStream()
                let buffer = output.property(forKey: Stream.PropertyKey.dataWrittenToMemoryStreamKey) as? Data
                FileManager.default.createFile(atPath: fileName, contents: buffer, attributes: nil)
            }
            return fileName as String
        }
        return ""
    }
    // NSData *buffer = [output propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    //[[NSFileManager defaultManager] createFileAtPath:fileName
    //    contents:buffer
    //    attributes:nil];
    //+(NSString *) createCSVFileForGroup:(TempoDeviceGroup *) deviceGroup {
    //    NSString *fileName = [self createFileNameWithAttachmentType:@"CSV" withPath:YES];
    //    NSOutputStream *output = [NSOutputStream outputStreamToMemory];
    //    CHCSVWriter *writer = [[CHCSVWriter alloc] initWithOutputStream:output encoding:NSUTF8StringEncoding delimiter:','];
    //    //wrting header name for csv file
    //    [writer writeField:@"Location"];
    //    [writer writeField:@"RH (%)"];
    //    [writer writeField:@"Temperature (°C)"];
    //    [writer writeField:@"TD (°C)"];
    //    [writer writeField:@"G/Kg"];
    //    [writer writeField:@"VP(kPa)"];
    //    [writer writeField:@"G/M3"];
    //    [writer writeField:@"SVP"];
    //    [writer finishLine];
    //
    //
    //    TempoDevice *external = deviceGroup.externalDevice;
    //    if (external != NULL) {
    //        TempoDiscDevice *externalDisc = (TempoDiscDevice *) external;
    //        [writer writeField:external.name];
    //        [writer writeField:[[external currentHumidity] stringValue]];
    //        [writer writeField:[[external currentTemperature] stringValue]];
    //        [writer writeField:[externalDisc.dewPoint stringValue]];
    //        double svp = 610.78 * exp([(externalDisc.averageDayTemperature) doubleValue] * 17.2694) / ([externalDisc.averageDayTemperature doubleValue] + 238.3);
    //        double vp = (svp / 1000.0) * ([externalDisc.averageDayHumidity doubleValue] / 100.0);
    //        double gpm3 = ((vp * 1000.0) / ((273.0 + [externalDisc.averageDayTemperature doubleValue]) * 461.5) * 1000.0);
    //        double gpkg = gpm3 * 0.83174;
    //        [writer writeField:[NSString stringWithFormat:@"%g", gpkg]];
    //        [writer writeField:[NSString stringWithFormat:@"%g", vp]];
    //        [writer writeField:[NSString stringWithFormat:@"%g", gpm3]];
    //        [writer writeField:[NSString stringWithFormat:@"%g", svp]];
    //        [writer finishLine];
    //        //        let svp = 610.78 * exp((Double(intern.averageDayTemperature!) * 17.2694) / (Double(intern.averageDayTemperature!) + 238.3))
    //        //        let vp = (svp / 1000.0) * (Double(intern.averageDayHumidity!) / 100.0)
    //        //        let gpm3 = ((vp * 1000.0) / ((273.0 + Double(intern.averageDayTemperature!)) * 461.5)) * 1000.0
    //        //        let gpkg = gpm3 * 0.83174
    //    }
    //    [writer closeStream];
    //
    //    NSData *buffer = [output propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    //    [[NSFileManager defaultManager] createFileAtPath:fileName
    //        contents:buffer
    //        attributes:nil];
    //    return fileName;
    //}
    
}
