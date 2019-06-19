//
//  NGDailyForecast+CoreDataProperties.m
//  weather
//
//  Created by Nicholas Galasso on 6/19/19.
//  Copyright © 2019 Rockshassa. All rights reserved.
//
//

#import "NGDailyForecast+CoreDataProperties.h"

@implementation NGDailyForecast (CoreDataProperties)

+ (NSFetchRequest<NGDailyForecast *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"NGDailyForecast"];
}

@dynamic date;
@dynamic apparentTemperatureHigh;
@dynamic apparentTemperatureLow;
@dynamic iconName;
@dynamic summary;

@end
