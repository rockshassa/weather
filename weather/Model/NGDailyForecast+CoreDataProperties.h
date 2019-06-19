//
//  NGDailyForecast+CoreDataProperties.h
//  weather
//
//  Created by Nicholas Galasso on 6/19/19.
//  Copyright © 2019 Rockshassa. All rights reserved.
//
//

#import "NGDailyForecast+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface NGDailyForecast (CoreDataProperties)

+ (NSFetchRequest<NGDailyForecast *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *date;
@property (nonatomic) float apparentTemperatureHigh;
@property (nonatomic) float apparentTemperatureLow;
@property (nullable, nonatomic, copy) NSString *iconName;
@property (nullable, nonatomic, copy) NSString *summary;

@end

NS_ASSUME_NONNULL_END
