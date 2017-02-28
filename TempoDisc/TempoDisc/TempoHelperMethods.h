//
//  TempoHelperMethods.h
//  Tempo Utility
//
//  Created by Kunal Thacker on 1/19/17.
//  Copyright © 2017 BlueMaestro. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <LGBluetooth/LGBluetooth.h>
#import <CorePlot/ios/CorePlot.h>
#import "LogMessage.h"
#import "CHCSVParser.h"

@interface TempoHelperMethods : NSObject<CPTScatterPlotDataSource, CPTScatterPlotDelegate, CPTPlotSpaceDelegate>


@property (nonatomic, strong) NSMutableArray *dataSourceLogMessages;
@property (nonatomic, strong) LGCharacteristic *writeCharacteristic;
@property (nonatomic, strong) LGCharacteristic *readCharacteristic;

@property (nonatomic, strong) NSString *dataToSend;

@property (nonatomic, assign) BOOL didDisconnect;

- (void)connectAndWrite:(NSString*)data;
- (void)setupDevice;
+ (NSString *)createCSVFileFordevice:(TempoDevice *) device;
+ (void)configureAxesForGraph:(CPTGraph *)graph plot:(CPTScatterPlot *)plot;
+ (NSString*)createFileNameWithAttachmentType:(NSString *)type withPath:(BOOL)includePath;
@end
