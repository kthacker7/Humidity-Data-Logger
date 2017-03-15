//
//  TempoHelperMethods.m
//  Tempo Utility
//
//  Created by Kunal Thacker on 1/19/17.
//  Copyright © 2017 BlueMaestro. All rights reserved.
//

#import "TempoHelperMethods.h"
#import "AppDelegate.h"


#define uartServiceUUIDString			@"6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
#define uartRXCharacteristicUUIDString	@"6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
#define uartTXCharacteristicUUIDString	@"6E400003-B5A3-F393-E0A9-E50E24DCCA9E"

#define kDeviceReconnectTimeout			2.0

#define kDeviceConnectTimeout			10.0
#define kInitialDataLoadCount           140

@implementation TempoHelperMethods

- (instancetype)init {
    if ( (self = [super init]) ) {
        [self setupDeviceWithCompletion:nil];
    }
    return self;
}

- (void)setupDeviceWithCompletion:(void (^)(BOOL))completion{
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
                                        [weakself writeData:weakself.dataToSend toCharacteristic:weakself.writeCharacteristic withCompletion:completion];
                                        weakself.dataToSend = nil;
                                    }
                                }
                                else {
                                    if (completion != nil) {
                                        completion(NO);
                                    }
                                }
                            }];
                            break;
                        }
                    }
                    if (!uartService) {
                        if (completion != nil) {
                            completion(NO);
                        }
                    }
                }
                else {
                    if (completion != nil) {
                        completion(NO);
                    }
                }
            }];
        }
        else {
            if (completion != nil) {
                completion(NO);
            }
        }
    }];
}

- (void)writeData:(NSString*)data
 toCharacteristic:(LGCharacteristic*)characteristic
   withCompletion:(void (^)(BOOL))completion{
    //    __weak typeof(self) weakself = self;
    [characteristic writeValue:[data dataUsingEncoding:NSUTF8StringEncoding] completion:^(NSError *error) {
        if (!error) {
            //			[weakself addLogMessage:@"Sucessefully wrote data to write characteristic" type:LogMessageTypeInbound];
            if (completion != nil) {
                completion(YES);
            }
        }
        else {
            if (completion != nil) {
                completion(NO);
            }
        }
    }];
}


- (void)connectAndWrite:(NSString*)data withCompletion:(void (^)(BOOL))completion{
//    NSLog([device.averageDayDew description]);
//    NSLog([device.averageDayHumidity description]);
//    NSLog([device.averageDayTemperature description]);
//    if (_writeCharacteristic) {
//        [self writeData:data toCharacteristic:_writeCharacteristic withCompletion:completion];
//    }
//    else {
        _dataToSend = data;
        
        /**
         *	 If there was a disconnect the device will need ot be scanned for again.
         **/
        if (_didDisconnect) {
            [[LGCentralManager sharedInstance] scanForPeripheralsByInterval:kDeviceReconnectTimeout completion:^(NSArray *peripherals) {
                for (LGPeripheral *peripheral in peripherals) {
                    if ([peripheral.UUIDString isEqualToString:[TDDefaultDevice sharedDevice].selectedDevice.peripheral.UUIDString]) {
                        [TDDefaultDevice sharedDevice].selectedDevice.peripheral = peripheral;
                        [self setupDeviceWithCompletion: completion];
                        break;
                    }
                }
            }];
        }
        else {
            [self setupDeviceWithCompletion: completion];
        }
        
//    }
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

- (void)adjustPlotsRange:(CPTPlotSpace *) plotSpaceOrig
                 forType:(NSString *) type {
    TempoDevice *device = self.selectedDevice;
    /**
     *	Adjust range for plot so that all points fit in the view with one hour before and after
     **/
    if ([type isEqualToString:@"Temperature"]) {
        CPTXYPlotSpace* plotSpace = (CPTXYPlotSpace *) plotSpaceOrig;
        NSArray *readings = [[device readingsForType:@"Temperature"] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]]];
        if (!self.allDataSelected) {
            readings = [readings subarrayWithRange:NSMakeRange(0, MIN(readings.count, kInitialDataLoadCount))];
        }
        double lastReading = [[(Reading*)[readings firstObject] timestamp] timeIntervalSince1970];
        double firstReading = [[(Reading*)[readings lastObject] timestamp] timeIntervalSince1970];
        plotSpace.xRange = [[CPTPlotRange alloc] initWithLocationDecimal:CPTDecimalFromFloat(firstReading-60*60) lengthDecimal:CPTDecimalFromFloat(MAX(60*60*2, lastReading-firstReading+60*60*2))];
        plotSpace.yRange = [[CPTPlotRange alloc] initWithLocationDecimal:CPTDecimalFromFloat([TDHelper temperature:@(0.0) forDevice:device].floatValue) lengthDecimal:CPTDecimalFromFloat([TDHelper temperature:@(35.0) forDevice:device].floatValue)];
    } else if ([type isEqualToString:@"Humidity"]) {
        CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)plotSpaceOrig;
        NSArray *readings = [[self.selectedDevice readingsForType:@"Humidity"] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]]];
        if (!self.allDataSelected) {
            readings = [readings subarrayWithRange:NSMakeRange(0, MIN(readings.count, kInitialDataLoadCount))];
        }
        double lastReading = [[(Reading*)[readings firstObject] timestamp] timeIntervalSince1970];
        double firstReading = [[(Reading*)[readings lastObject] timestamp] timeIntervalSince1970];
        plotSpace.xRange = [[CPTPlotRange alloc] initWithLocationDecimal:CPTDecimalFromFloat(firstReading-60*60) lengthDecimal:CPTDecimalFromFloat(MAX(60*60*2, lastReading-firstReading+60*60*2))];
        plotSpace.yRange = [[CPTPlotRange alloc] initWithLocationDecimal:CPTDecimalFromFloat(0.0) lengthDecimal:CPTDecimalFromFloat(100)];
    } else {
        CPTXYPlotSpace *plotSpaceDewPoint = (CPTXYPlotSpace *)plotSpaceOrig;
        NSArray *readings = [[self.selectedDevice readingsForType:@"DewPoint"] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]]];
        if (!self.allDataSelected) {
            readings = [readings subarrayWithRange:NSMakeRange(0, MIN(readings.count, kInitialDataLoadCount))];
        }
        double lastReading = [[(Reading*)[readings firstObject] timestamp] timeIntervalSince1970];
        double firstReading = [[(Reading*)[readings lastObject] timestamp] timeIntervalSince1970];
        plotSpaceDewPoint.xRange = [[CPTPlotRange alloc] initWithLocationDecimal:CPTDecimalFromFloat(firstReading-60*60) lengthDecimal:CPTDecimalFromFloat(MAX(60*60*2, lastReading-firstReading+60*60*2))];
        plotSpaceDewPoint.yRange = [[CPTPlotRange alloc] initWithLocationDecimal:CPTDecimalFromFloat([TDHelper temperature:@(0.0) forDevice:device].floatValue) lengthDecimal:CPTDecimalFromFloat([TDHelper temperature:@(35.0) forDevice:device].floatValue)];
    }
}

+ (void)configureAxesForGraph:(CPTGraph*)graph plot:(CPTScatterPlot*)plot
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

-(CPTGraphHostingView*)configureHost:(UIView*)graphView forGraph:(CPTGraphHostingView*)host
{
    for (UIView* subview in graphView.subviews) {
        [subview removeFromSuperview];
    }
    host = [(CPTGraphHostingView *)[CPTGraphHostingView alloc] initWithFrame:CGRectInset(graphView.bounds, 20, 20)];
    host.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [graphView addSubview:host];
    return host;
}

- (CPTGraph*)configureGraph:(CPTGraph*)graph hostView:(CPTGraphHostingView*)hostView graphView:(UIView*)viewGraph title:(NSString*)title
{
    // 1 - Create the graph
    graph = [[CPTXYGraph alloc] initWithFrame:CGRectInset(viewGraph.bounds, 10, 10)];
    graph.title = title;
    graph.titleDisplacement = CGPointMake(0, 15.0);
    hostView.hostedGraph = graph;
    //	_graph.plotAreaFrame.plotArea.delegate = self;
    
    // Set up the look of the plot. Want
    [graph applyTheme:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
    
    // Make things see through.
    graph.backgroundColor = nil;
    graph.fill = [CPTFill fillWithColor:[CPTColor whiteColor]];
    graph.plotAreaFrame.fill = nil;
    graph.plotAreaFrame.plotArea.fill = nil;
    graph.plotAreaFrame.borderLineStyle = nil;
    graph.plotAreaFrame.masksToBorder = NO;
    
    CPTMutableTextStyle *whiteText = [CPTMutableTextStyle textStyle];
    whiteText.color = [CPTColor colorWithComponentRed:62.0f/255.0f green:62.0f/255.0f blue:62.0f/255.0f alpha:1];
    whiteText.fontName=@"Montserrat-Regular";
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        whiteText.fontSize=15;
    }
    else if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)//iPad
    {
        whiteText.fontSize=25;
    }
    
    graph.titleTextStyle = whiteText;
    
    hostView.allowPinchScaling = YES;
    
    //    UIPinchGestureRecognizer *pGes = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    //    [viewGraph addGestureRecognizer:pGes];
    
    return graph;
}

- (CPTScatterPlot*)configurePlot:(CPTScatterPlot*)plot forGraph:(CPTGraph*)graph identifier:(NSString*)identifier
{
    //plot average
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.delegate = self;
    
    // Set up the plot, including the look of the plot itself.
    plot = [self plotWithIdentifier:identifier];
    for (id plot in graph.allPlots) {
        [graph removePlot:plot];
    }
    [graph addPlot:plot toPlotSpace:plotSpace];
    
    return plot;
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

- (CPTScatterPlot *)plotWithIdentifier:(NSString *)identifier
{
    // Set up the plot, including the look of the plot itself.
    CPTScatterPlot *plot = [[CPTScatterPlot alloc] init];
    plot.dataSource = self;
    plot.delegate = self;
    plot.identifier=identifier;
    plot.plotSymbolMarginForHitDetection = kGraphSymboldTouchArea;
    return plot;
}

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    if ([plot.identifier isEqual:@"Temperature"]) {
        if (!self.allDataSelected) {
            return MIN([self.selectedDevice readingsForType:@"Temperature"].count, kInitialDataLoadCount);
        }
        else {
            return [self.selectedDevice readingsForType:@"Temperature"].count;
        }
    }
    else if ([plot.identifier isEqual:@"Humidity"]) {
        if (!self.allDataSelected) {
            return MIN([self.selectedDevice readingsForType:@"Humidity"].count, kInitialDataLoadCount);
        }
        else {
            return [self.selectedDevice readingsForType:@"Humidity"].count;
        }
    }
    else if ([plot.identifier isEqual:@"DewPoint"]) {
        if (!self.allDataSelected) {
            return MIN([self.selectedDevice readingsForType:@"DewPoint"].count, kInitialDataLoadCount);
        }
        else {
            return [self.selectedDevice readingsForType:@"DewPoint"].count;
        }
    }
    else {
        return 0;
    }
}

- (NSNumber *) numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSArray *dataSource = @[];
    Reading *reading;
    if ([plot.identifier isEqual:@"Temperature"]) {
        dataSource = [[self.selectedDevice readingsForType:@"Temperature"] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]]];
    }
    else if ([plot.identifier isEqual:@"Humidity"]) {
        dataSource = [[self.selectedDevice readingsForType:@"Humidity"] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]]];
    }
    else if ([plot.identifier isEqual:@"DewPoint"]) {
        dataSource = [[self.selectedDevice readingsForType:@"DewPoint"] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]]];
    }
    reading = [dataSource objectAtIndex:index];
    
    switch (fieldEnum) {
        case CPTScatterPlotFieldX:
            if (fieldEnum == CPTScatterPlotFieldX)
            {
                return [NSNumber numberWithDouble:[reading.timestamp timeIntervalSince1970]];
            }
            break;
            
        case CPTScatterPlotFieldY:
            if ([plot.identifier isEqual:@"Humidity"]) {
                return reading.avgValue;
            }
            else {
                return [TDHelper temperature:reading.avgValue forDevice:self.selectedDevice];
            }
            
            break;
    }
    return [NSNumber numberWithFloat:0.0];
}

#pragma mark - CPTScatterPlotDelegate

- (CPTPlotSymbol *)symbolForScatterPlot:(CPTScatterPlot *)plot recordIndex:(NSUInteger)idx {
    CPTPlotSymbol *temperatureSymbol = [CPTPlotSymbol diamondPlotSymbol];
    temperatureSymbol.fill = [CPTFill fillWithColor:[CPTColor colorWithGenericGray:1.0]];
    return temperatureSymbol;
}

+ (TempoDiscDevice *) tdToTempo: (TDTempoDisc *) device {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([TempoDevice class])];
    request.predicate = [NSPredicate predicateWithFormat:@"self.uuid == %@", device.uuid];
    NSLog(@"activeDevice is %@", device.name);
    NSError *error;
    NSManagedObjectContext *context = [(AppDelegate*)[UIApplication sharedApplication].delegate managedObjectContext];
    NSArray *result = [context executeFetchRequest:request error:&error];
    TempoDiscDevice *discDevice;
    if (!error) {
        if (result.count > 0) {
            discDevice = [result firstObject];
        }
        else {
            discDevice = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([TempoDiscDevice class]) inManagedObjectContext:context];
        }
        
        [discDevice fillDataForPersistentStore:device];
        
    }
    else {
        NSLog(@"Error fetching device from storage: %@", error);
    }
    NSError *saveError;
    [context save:&saveError];
    if (saveError) {
        NSLog(@"Error saving context on device fetch: %@", saveError);
    }
    return discDevice;
}


@end
