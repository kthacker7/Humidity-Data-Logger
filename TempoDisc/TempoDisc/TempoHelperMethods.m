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


@end
