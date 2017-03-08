//
//  TempoDiscDevice+CoreDataProperties.h
//
//
//  Created by Nikola Misic on 9/21/16.
//
//

#import "TempoDiscDevice+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface TempoDiscDevice (CoreDataProperties)

+ (NSFetchRequest<TempoDiscDevice *> *)fetchRequest;

@property (nullable, nonatomic, retain) NSString *uuid;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSDecimalNumber *battery;
@property (nullable, nonatomic, retain) NSString *modelType;
@property (nullable, nonatomic, retain) NSNumber *version;
@property (nullable, nonatomic, retain) NSNumber *currentTemperature;
@property (nullable, nonatomic, retain) NSNumber *currentMinTemperature;
@property (nullable, nonatomic, retain) NSNumber *currentMaxTemperature;
@property (nullable, nonatomic, retain) NSNumber *currentHumidity;
@property (nullable, nonatomic, retain) NSNumber *currentPressure;
@property (nullable, nonatomic, retain) NSNumber *currentPressureData;
@property (nullable, nonatomic, retain) NSDate *lastDownload;
@property (nullable, nonatomic, retain) NSNumber *isBlueMaestroDevice;
@property (nullable, nonatomic, retain) NSNumber *isFahrenheit;//BOOL
@property (nullable, nonatomic, retain) NSNumber *inRange;//BOOL, transient
@property (nullable, nonatomic, retain) NSDate *startTimestamp;
@property (nullable, nonatomic, retain) NSDate *lastDetected;//transient
@property (nullable, nonatomic, copy) NSNumber *timerInterval;
@property (nullable, nonatomic, copy) NSNumber *intervalCounter;
@property (nullable, nonatomic, copy) NSDecimalNumber *dewPoint;
@property (nullable, nonatomic, copy) NSNumber *mode;
@property (nullable, nonatomic, copy) NSNumber *numBreach;
@property (nullable, nonatomic, copy) NSNumber *highestTemperature;
@property (nullable, nonatomic, copy) NSNumber *highestHumidity;
@property (nullable, nonatomic, copy) NSNumber *highestDew;
@property (nullable, nonatomic, copy) NSNumber *lowestTemperature;
@property (nullable, nonatomic, copy) NSNumber *lowestHumidity;
@property (nullable, nonatomic, copy) NSNumber *lowestDew;
@property (nullable, nonatomic, copy) NSNumber *highestDayTemperature;
@property (nullable, nonatomic, copy) NSNumber *highestDayHumidity;
@property (nullable, nonatomic, copy) NSNumber *highestDayDew;
@property (nullable, nonatomic, copy) NSNumber *lowestDayTemperature;
@property (nullable, nonatomic, copy) NSNumber *lowestDayHumidity;
@property (nullable, nonatomic, copy) NSNumber *lowestDayDew;
@property (nullable, nonatomic, copy) NSNumber *averageDayTemperature;
@property (nullable, nonatomic, copy) NSNumber *averageDayHumidity;
@property (nullable, nonatomic, copy) NSNumber *averageDayDew;
@property (nullable, nonatomic, copy) NSNumber *logCount;
@property (nullable, nonatomic, copy) NSNumber *referenceDateRawNumber;
@property (nullable, nonatomic, retain) NSNumber *globalIdentifier;
@property (nullable, nonatomic, copy) NSNumber *averageDayPressure;
@property (nullable, nonatomic, copy) NSNumber *pressure;
@property (nullable, nonatomic, copy) NSNumber *highestDayPressure;
@property (nullable, nonatomic, copy) NSNumber *highestPressure;
@property (nullable, nonatomic, copy) NSNumber *lowestDayPressure;
@property (nullable, nonatomic, copy) NSNumber *lowestPressure;

@end

NS_ASSUME_NONNULL_END
