//
//  TempoHelperMethods.h
//  Tempo Utility
//
//  Created by Kunal Thacker on 1/19/17.
//  Copyright © 2017 BlueMaestro. All rights reserved.
//
#import <LGBluetooth/LGBluetooth.h>

@interface TempoHelperMethods : NSObject


@property (nonatomic, strong) NSMutableArray *dataSourceLogMessages;
@property (nonatomic, strong) LGCharacteristic *writeCharacteristic;
@property (nonatomic, strong) LGCharacteristic *readCharacteristic;

@property (nonatomic, strong) NSString *dataToSend;

@property (nonatomic, assign) BOOL didDisconnect;

- (void)connectAndWrite:(NSString*)data;
- (void)setupDevice;

@end
