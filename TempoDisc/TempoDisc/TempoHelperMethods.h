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
#import "TempoDiscDevice+CoreDataClass.h"

@interface TempoHelperMethods : NSObject<CPTScatterPlotDataSource, CPTScatterPlotDelegate, CPTPlotSpaceDelegate>


@property (nonatomic, strong) NSMutableArray *dataSourceLogMessages;
@property (nonatomic, strong) LGCharacteristic *writeCharacteristic;
@property (nonatomic, strong) LGCharacteristic *readCharacteristic;
@property (nonatomic, strong) TempoDevice* selectedDevice;

@property (nonatomic, strong) NSString *dataToSend;

@property (nonatomic, assign) BOOL didDisconnect;
@property (nonatomic, assign) BOOL allDataSelected;

- (void)connectAndWrite:(NSString*)data;
- (void)setupDevice;
+ (NSString *)createCSVFileFordevice:(TempoDevice *) device;
+ (void)configureAxesForGraph:(CPTGraph *)graph plot:(CPTScatterPlot *)plot;
+ (NSString*)createFileNameWithAttachmentType:(NSString *)type withPath:(BOOL)includePath;
- (CPTGraphHostingView*)configureHost:(UIView*)graphView forGraph:(CPTGraphHostingView*)host;
- (CPTGraph*)configureGraph:(CPTGraph*)graph hostView:(CPTGraphHostingView*)hostView graphView:(UIView*)viewGraph title:(NSString*)title;
- (CPTScatterPlot*)configurePlot:(CPTScatterPlot*)plot forGraph:(CPTGraph*)graph identifier:(NSString*)identifier;
- (void)configureAxesForGraph:(CPTGraph*)graph plot:(CPTScatterPlot*)plot;
- (CPTScatterPlot *)plotWithIdentifier:(NSString *)identifier;
- (void)adjustPlotsRange:(CPTPlotSpace *) plotSpaceOrig
                 forType:(NSString *) type;
+ (TempoDiscDevice *) tdToTempo: (TDTempoDisc *) device;
@end
