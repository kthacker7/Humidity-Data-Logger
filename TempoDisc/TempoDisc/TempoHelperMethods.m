//
//  TempoHelperMethods.m
//  Tempo Utility
//
//  Created by Kunal Thacker on 1/19/17.
//  Copyright © 2017 BlueMaestro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TempoHelperMethods.h"
#import "LogMessage.h"
#import "CHCSVParser.h"
#import <CorePlot/ios/CorePlot.h>

#define uartServiceUUIDString			@"6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
#define uartRXCharacteristicUUIDString	@"6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
#define uartTXCharacteristicUUIDString	@"6E400003-B5A3-F393-E0A9-E50E24DCCA9E"

#define kDeviceReconnectTimeout			2.0

#define kDeviceConnectTimeout			10.0

@implementation TempoHelperMethods

- (instancetype)init {
    if ( (self = [super init]) ) {
        [self setupDevice];
    }
    return self;
}

- (void)setupDevice {
    __weak typeof(self) weakself = self;
    [[TDDefaultDevice sharedDevice].selectedDevice.peripheral connectWithTimeout:kDeviceConnectTimeout completion:^(NSError *error) {
        weakself.didDisconnect = NO;
        if (!error) {
            [[TDDefaultDevice sharedDevice].selectedDevice.peripheral discoverServicesWithCompletion:^(NSArray *services, NSError *error2) {
                if (!error2) {
                    LGService *uartService;
                    for (LGService* service in services) {
                        if ([[service.UUIDString uppercaseString] isEqualToString:uartServiceUUIDString]) {
                            uartService = service;
                            [service discoverCharacteristicsWithCompletion:^(NSArray *characteristics, NSError *error3) {
                                if (!error3) {
                                    
                                    LGCharacteristic *readCharacteristic;
                                    for (LGCharacteristic *characteristic in characteristics) {
                                        if ([[characteristic.UUIDString uppercaseString] isEqualToString:uartTXCharacteristicUUIDString]) {
                                            readCharacteristic = characteristic;
                                            weakself.readCharacteristic = characteristic;
                                            /*CBMutableCharacteristic *noteCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:readCharacteristic.UUIDString] properties:CBCharacteristicPropertyNotify+CBCharacteristicPropertyRead
                                             value:nil permissions:CBAttributePermissionsReadable|CBAttributePermissionsWriteable];
                                             LGCharacteristic *characteristicForNotification = [[LGCharacteristic alloc] initWithCharacteristic:noteCharacteristic];*/
                                            [characteristic setNotifyValue:YES completion:^(NSError *error4) {
                                                if (!error4) {
                                                    //													[weakself addLogMessage:@"Subscribed for TX characteristic notifications" type:LogMessageTypeInbound];
                                                }
                                                else {
                                                    
                                                }
                                            } onUpdate:^(NSData *data, NSError *error5) {
                                                if (!error5) {
                                                }
                                                else {
                                                }
                                            }];
                                        }
                                        else if ([[characteristic.UUIDString uppercaseString] isEqualToString:uartRXCharacteristicUUIDString]) {
                                            weakself.writeCharacteristic = characteristic;
                                        }
                                    }
                                    if (!readCharacteristic) {
                                    }
                                    if (!weakself.writeCharacteristic) {
                                    }
                                    if (weakself.writeCharacteristic && weakself.dataToSend) {
                                        [weakself writeData:weakself.dataToSend toCharacteristic:weakself.writeCharacteristic];
                                        weakself.dataToSend = nil;
                                    }
                                }
                                else {
                                }
                            }];
                            break;
                        }
                    }
                    if (!uartService) {
                    }
                }
                else {
                }
            }];
        }
        else {
        }
    }];
}

- (void)writeData:(NSString*)data toCharacteristic:(LGCharacteristic*)characteristic {
//    __weak typeof(self) weakself = self;
    [characteristic writeValue:[data dataUsingEncoding:NSUTF8StringEncoding] completion:^(NSError *error) {
        if (!error) {
            //			[weakself addLogMessage:@"Sucessefully wrote data to write characteristic" type:LogMessageTypeInbound];
        }
        else {
        }
    }];
}


- (void)connectAndWrite:(NSString*)data {
    if (_writeCharacteristic) {
        [self writeData:data toCharacteristic:_writeCharacteristic];
    }
    else {
        _dataToSend = data;
        
        /**
         *	 If there was a disconnect the device will need ot be scanned for again.
         **/
        if (_didDisconnect) {
            [[LGCentralManager sharedInstance] scanForPeripheralsByInterval:kDeviceReconnectTimeout completion:^(NSArray *peripherals) {
                for (LGPeripheral *peripheral in peripherals) {
                    if ([peripheral.UUIDString isEqualToString:[TDDefaultDevice sharedDevice].selectedDevice.peripheral.UUIDString]) {
                        [TDDefaultDevice sharedDevice].selectedDevice.peripheral = peripheral;
                        [self setupDevice];
                        break;
                    }
                }
            }];
        }
        else {
            [self setupDevice];
        }
        
    }
}

+(NSString*)createFileNameWithAttachmentType:(NSString *)type withPath:(BOOL)includePath
{
    NSString* fileName;
    
    fileName = @"exportData";
    
    if (includePath) {
        NSArray *arrayPaths =
        NSSearchPathForDirectoriesInDomains(
                                            NSDocumentDirectory,
                                            NSUserDomainMask,
                                            YES);
        NSString *path = [arrayPaths objectAtIndex:0];
        NSString* pdfFileName = [path stringByAppendingPathComponent:fileName];
        
        return pdfFileName;
    }
    
    return fileName;
    
}


+(NSString *)createCSVFileFordevice:(TempoDevice *) device{
    NSString *fileName = [self createFileNameWithAttachmentType:@"CSV" withPath:YES];
    NSOutputStream *output = [NSOutputStream outputStreamToMemory];
    CHCSVWriter *writer = [[CHCSVWriter alloc] initWithOutputStream:output encoding:NSUTF8StringEncoding delimiter:','];
    //wrting header name for csv file
    [writer writeField:@"Record number"];
    [writer writeField:@"Timestamp"];
    [writer writeField:@"Temperature"];
    [writer writeField:@"Humidity"];
    [writer writeField:@"Dew point"];
    [writer finishLine];
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm\tdd/MM/yyyy"];
    //[formatter setDateFormat:@"dd/MM/yyyy\tHH:mm"];
    NSArray *temperature = [device readingsForType:@"Temperature"];
    NSArray *humidity = [device readingsForType:@"Humidity"];
    NSArray *dewPoint = [device readingsForType:@"DewPoint"];
    
    temperature = [temperature sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            Reading *reading1 = obj1;
            Reading *reading2 = obj2;
            return [reading1.timestamp compare:reading2.timestamp];
        }];
    humidity = [humidity sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        Reading *reading1 = obj1;
        Reading *reading2 = obj2;
        return [reading1.timestamp compare:reading2.timestamp];
    }];
    dewPoint = [dewPoint sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        Reading *reading1 = obj1;
        Reading *reading2 = obj2;
        return [reading1.timestamp compare:reading2.timestamp];
    }];
    
    for (NSInteger index = 0; index < temperature.count; index++) {
        Reading *readingTemperature = index < temperature.count ? temperature[index] : nil;
        Reading *readingHumidity = index < humidity.count ? humidity[index] : nil;
        Reading *readingDewPoint = index < dewPoint.count ? dewPoint[index] : nil;
        
        [writer writeField:[NSString stringWithFormat:@"%lu", (unsigned long)index+1]];
        [writer writeField:[NSString stringWithFormat:@"%@", [formatter stringFromDate:readingTemperature.timestamp]]];
        [writer writeField:[NSString stringWithFormat:@"%@", readingTemperature.avgValue]];
        [writer writeField:[NSString stringWithFormat:@"%@", readingHumidity.avgValue]];
        [writer writeField:[NSString stringWithFormat:@"%@", readingDewPoint.avgValue]];
        [writer finishLine];
    }
    
    [writer closeStream];
    
    NSData *buffer = [output propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    [[NSFileManager defaultManager] createFileAtPath:fileName
                                            contents:buffer
                                          attributes:nil];
    return fileName;
}

- (void)configureAxesForGraph:(CPTGraph*)graph plot:(CPTScatterPlot*)plot
{
    // Set up axis.
    CPTXYAxisSet * axisSet = (CPTXYAxisSet *) graph.axisSet;
    
    axisSet.xAxis.labelingPolicy = CPTAxisLabelingPolicyEqualDivisions;//CPTAxisLabelingPolicyAutomatic
    axisSet.xAxis.preferredNumberOfMajorTicks = 6;
    axisSet.xAxis.minorTickLineStyle = nil;
    axisSet.xAxis.axisConstraints = [CPTConstraints constraintWithLowerOffset:0.0];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMM\nHH:mm"];
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:formatter];
    timeFormatter.referenceDate = [NSDate dateWithTimeIntervalSince1970:0];
    [(CPTXYAxisSet *)graph.axisSet xAxis].labelFormatter = timeFormatter;
    
    axisSet.yAxis.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    //    axisSet.yAxis.preferredNumberOfMajorTicks = 6;
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineColor = [CPTColor colorWithGenericGray:0.7];
    majorGridLineStyle.lineWidth = 0.5;
    
    CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
    minorGridLineStyle.lineColor = [CPTColor colorWithGenericGray:0.8];
    minorGridLineStyle.lineWidth = 0.25;
    
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor colorWithGenericGray:0.1];
    tickLineStyle.lineWidth = 0.25;
    
    axisSet.yAxis.minorTickLineStyle = tickLineStyle;
    axisSet.yAxis.majorGridLineStyle = majorGridLineStyle;
    axisSet.yAxis.minorGridLineStyle = minorGridLineStyle;
    axisSet.yAxis.axisConstraints = [CPTConstraints constraintWithLowerOffset:0.0];
    
    NSNumberFormatter *formatterY = [[NSNumberFormatter alloc] init];
    [formatterY setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatterY setGeneratesDecimalNumbers:NO];
    axisSet.yAxis.labelFormatter = formatterY;
    
    axisSet.yAxis.axisConstraints = [CPTConstraints constraintWithLowerOffset:0.0];
    
    CPTMutableTextStyle *labelTextStyle = [[CPTMutableTextStyle alloc] init];
    labelTextStyle.textAlignment = CPTTextAlignmentCenter;
    labelTextStyle.color = kColorGraphAxis;
    labelTextStyle.fontName=kFontGraphAxis;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        labelTextStyle.fontSize = kGraphiPhoneFontSize;
    }
    else if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)//iPad
    {
        labelTextStyle.fontSize = kGraphiPadFontSize;
    }
    
    axisSet.xAxis.labelTextStyle = labelTextStyle;
    axisSet.yAxis.labelTextStyle = labelTextStyle;
    
    //25-3
    CPTColor *linecolor = kColorGraphAverage;
    
    CPTMutableLineStyle *minrangeLineStyle = [plot.dataLineStyle mutableCopy];
    minrangeLineStyle.lineWidth = kGraphLineWidth;
    minrangeLineStyle.lineColor = kColorGraphAverage;
    
    plot.dataLineStyle=minrangeLineStyle;
    plot.interpolation=GRAPH_LINE_TYPE;
    
    CPTMutableLineStyle *newSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    newSymbolLineStyle.lineColor=kColorGraphAverage;
    newSymbolLineStyle.lineWidth=1.0;
    
    CPTPlotSymbol *temperatureSymbol = [CPTPlotSymbol ellipsePlotSymbol];  //dot symbol
    temperatureSymbol.lineStyle = minrangeLineStyle;
    temperatureSymbol.size=kGraphSymbolSize;
    temperatureSymbol.fill=[CPTFill fillWithColor:linecolor];
    temperatureSymbol.lineStyle = newSymbolLineStyle;
    plot.plotSymbol = temperatureSymbol;
    
}



@end
