//
//  NGDailyForecast+CoreDataClass.h
//  weather
//
//  Created by Nicholas Galasso on 6/19/19.
//  Copyright © 2019 Rockshassa. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface NGDailyForecast : NSManagedObject

@property (readonly) NSString *weekday;

@end

NS_ASSUME_NONNULL_END

#import "NGDailyForecast+CoreDataProperties.h"
