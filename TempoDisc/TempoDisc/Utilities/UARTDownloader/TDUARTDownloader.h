//
//  TDUARTDownloader.h
//  TempoDisc
//
//  Created by Nikola Misic on 10/5/16.
//  Copyright © 2016 BlueMaestro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TempoDiscDevice+CoreDataProperties.h"
#import <LGBluetooth/LGBluetooth.h>
#import "AppDelegate.h"

typedef void(^DataDownloadCompletion)(BOOL);
typedef void(^DataProgressUpdate)(float progress);
typedef enum : NSInteger {
    DataDownloadTypeTemperature,
    DataDownloadTypeHumidity,
    DataDownloadTypeDewPoint,
    DataDownloadTypeFinish
} DataDownloadType;
@interface TDUARTDownloader : NSObject
@property (nonatomic, assign) DataDownloadType currentDownloadType;

+ (TDUARTDownloader*)shared;
- (void)refreshDownloader;
- (void)downloadDataForDevice:(TempoDiscDevice*)device withCompletion:(DataDownloadCompletion)completion;
- (void)setNewTimeStamp: (NSInteger)sendRecordsNeeded;

@end
