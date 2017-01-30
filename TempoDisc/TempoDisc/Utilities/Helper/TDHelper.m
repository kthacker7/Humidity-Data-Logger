//
//  TDHelper.m
//  TempoDisc
//
//  Created by Nikola Misic on 2/28/16.
//  Copyright © 2016 BlueMaestro. All rights reserved.
//

#import "TDHelper.h"
#import <LGBluetooth/LGBluetooth.h>
#import "TDDeviceListTableViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "TDDeviceTableViewCell.h"
#import "TDOtherDeviceTableViewCell.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "TempoDiscDevice+CoreDataProperties.h"
#import "AppDelegate.h"

@implementation TDHelper

+ (TempoDevice*)findOrCreateDeviceForPeripheral:(LGPeripheral*)peripheral {
    /**
     *	If there is no manufacturer data see if the device is already inserted and return that device.
     **/
    BOOL hasManufacturerData = [TempoDevice hasManufacturerData:peripheral.advertisingData];
    
    /**
     *	TDT-2 Non Tempo Disc devices should still be visible, with limited data
     **/
    BOOL isTempoDiscDevice = [TempoDevice isTempoDiscDeviceWithAdvertisementData:peripheral.advertisingData];
    BOOL isBlueMaestroDevice = [TempoDevice isBlueMaestroDeviceWithAdvertisementData:peripheral.advertisingData];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([TempoDevice class])];
    request.predicate = [NSPredicate predicateWithFormat:@"self.uuid = %@", peripheral.cbPeripheral.identifier.UUIDString];
    NSError *fetchError;
    NSManagedObjectContext *context = [(AppDelegate*)[UIApplication sharedApplication].delegate managedObjectContext];
    NSArray *result = [context executeFetchRequest:request error:&fetchError];
    
    TempoDevice *device;
    if (!fetchError && result.count > 0) {
        //found existing device
        device = [result firstObject];
        if (isBlueMaestroDevice && hasManufacturerData) {
            [device fillWithData:peripheral.advertisingData name:peripheral.name uuid:peripheral.cbPeripheral.identifier.UUIDString];
        }
        else {
            device.name = peripheral.name;
            device.uuid = peripheral.cbPeripheral.identifier.UUIDString;
        }
        if (hasManufacturerData) {
            device.isBlueMaestroDevice = @(isBlueMaestroDevice);
        }
    }
    else if (!fetchError && hasManufacturerData) {
        //detected new device
        if (isTempoDiscDevice) {
            device = [TempoDiscDevice deviceWithName:peripheral.name data:peripheral.advertisingData uuid:peripheral.cbPeripheral.identifier.UUIDString context:context];
        }
        else {
            device = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([TempoDevice class]) inManagedObjectContext:context];
            device.name = peripheral.name;
            device.uuid = peripheral.cbPeripheral.identifier.UUIDString;
        }
        device.isBlueMaestroDevice = @(isBlueMaestroDevice);
    }
    else if (hasManufacturerData || fetchError) {
        NSLog(@"Error fetching devices: %@", fetchError.localizedDescription);
    }
    
    NSError *saveError;
    [context save:&saveError];
    if (saveError) {
        NSLog(@"Error saving device named %@: %@", peripheral.name, saveError.localizedDescription);
    }
    
    return device;
}

+ (NSNumber *)temperature:(NSNumber *)temp forDevice:(TempoDevice *)device
{
	return device.isFahrenheit.boolValue ? [NSNumber numberWithDouble:temp.doubleValue*1.8+32] : temp;
}


/**
 *	Provided code for TempoDisc
 **/
- (void) writeAndRead:(int16_t)dataToWrite peripheral:(LGPeripheral *)peripheral {
	
	NSMutableArray *tempArrayFloat = [NSMutableArray array];
	NSMutableArray *tempArrayBytes = [NSMutableArray array];
	NSMutableArray *humArrayFloat = [NSMutableArray array];
	NSMutableArray *humArrayBytes = [NSMutableArray array];
	NSDate *maxDate;
	NSInteger indexDownload = 0;
	NSDate *nowDate;
	NSManagedObjectContext *managedObjectContext;
	NSNumber *sensorId;
	
	[LGUtils writeData:[NSData dataWithBytes:&dataToWrite length:sizeof(dataToWrite)]
		   charactUUID:@"SENSOR_TEMP_WINDOW_CHARACTERISTIC_UUID"
		   serviceUUID:@"SENSOR_SERVICE_UUID"
			peripheral:peripheral completion:^(NSError *error) {
				NSLog(@"Error : %@", error);
				[LGUtils readDataFromCharactUUID:@"SENSOR_TEMP_DATA_CHARACTERISTIC_UUID"
									 serviceUUID:@"SENSOR_SERVICE_UUID"
									  peripheral:peripheral
									  completion:^(NSData *data, NSError *error) {
										  for(NSUInteger i = 0; i < data.length; ++i) {
											  Byte byte = 0;
											  [data getBytes:&byte range:NSMakeRange(i, 1)];
											  [tempArrayBytes addObject:[NSString stringWithFormat:@"%hhu", byte]];
										  }
										  
										  [LGUtils writeData:[NSData dataWithBytes:&dataToWrite length:sizeof(dataToWrite)]
												 charactUUID:@"SENSOR_HUM_WINDOW_CHARACTERISTIC_UUID"
												 serviceUUID:@"SENSOR_SERVICE_UUID"
												  peripheral:peripheral completion:^(NSError *error) {
													  
													  [LGUtils readDataFromCharactUUID:@"SENSOR_HUM_DATA_CHARACTERISTIC_UUID"
																		   serviceUUID:@"SENSOR_SERVICE_UUID"
																			peripheral:peripheral
																			completion:^(NSData *data, NSError *error) {
																				for(NSUInteger i = 0; i < data.length; ++i) {
																					Byte byte = 0;
																					[data getBytes:&byte range:NSMakeRange(i, 1)];
																					[humArrayBytes addObject:[NSString stringWithFormat:@"%hhu", byte]];
																				}
																				//REDO
																				NSLog(@"Error : %@ -> Index : %hd", error, indexDownload);
																				[self reWriteAndRead:peripheral];
																			}];
												  }];
									  }];
			}];
}


- (void)reWriteAndRead:(LGPeripheral *)peripheral {
	NSMutableArray *tempArrayFloat = [NSMutableArray array];
	NSMutableArray *tempArrayBytes = [NSMutableArray array];
	NSMutableArray *humArrayFloat = [NSMutableArray array];
	NSMutableArray *humArrayBytes = [NSMutableArray array];
	NSDate *maxDate;
	NSInteger indexDownload = 0;
	NSDate *nowDate;
	NSManagedObjectContext *managedObjectContext;
	NSNumber *sensorId;
	//TEMP
	[tempArrayFloat addObject:[NSNumber numberWithFloat:(float)([tempArrayBytes[3] integerValue] * 255 + [tempArrayBytes[2] integerValue])/10]];
	[tempArrayFloat addObject:[NSNumber numberWithFloat:(float)([tempArrayBytes[9] integerValue] * 255 + [tempArrayBytes[8] integerValue])/10]];
	[tempArrayFloat addObject:[NSNumber numberWithFloat:(float)([tempArrayBytes[15] integerValue] * 255 + [tempArrayBytes[14] integerValue])/10]];
	//HUM
	for (int i = 0; i < 12; i++) {
		[humArrayFloat addObject:[NSNumber numberWithFloat:(float)([humArrayBytes[i] integerValue])]];
	}
	
	NSTimeInterval distanceBetweenDates = [[NSDate date] timeIntervalSinceDate:maxDate];
	double secondsInAnHour = 3600;
	int maxIndex = distanceBetweenDates / secondsInAnHour;
	
	if (indexDownload > 100 || indexDownload > maxIndex+1) {
		
		for (int i=0; i<indexDownload; i++) {
			NSDate* localDate = [nowDate dateByAddingTimeInterval:-3600*i];
			if ([tempArrayFloat[i] floatValue] < 3264.0f &&  [humArrayFloat[i] floatValue] < 255.0f) {
				// ADD POINT
				// Create Entity
				NSEntityDescription *entityPoint = [NSEntityDescription entityForName:@"Point" inManagedObjectContext:managedObjectContext];
				
				// Initialize Record Temp
				NSManagedObject *recordPoint = [[NSManagedObject alloc] initWithEntity:entityPoint insertIntoManagedObjectContext:managedObjectContext];
				
				// Populate Record
				[recordPoint setValue:sensorId forKey:@"sensorId"];
				[recordPoint setValue:[NSDate date] forKey:@"createdAt"];
				[recordPoint setValue:localDate forKey:@"date"];
				[recordPoint setValue:tempArrayFloat[i] forKey:@"valueTemp"];
				[recordPoint setValue:humArrayFloat[i] forKey:@"valueHum"];
				
				//Save
				[managedObjectContext save:nil];
				NSLog(@"Save new point for date : %@", localDate);
				
			}
		}
		
		
	}
	else {
		//CONTINUE if not finished
		indexDownload = indexDownload + 1;
		[self writeAndRead:(int16_t)indexDownload peripheral:peripheral];
	}
	
}

@end
