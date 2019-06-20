//
//  NGDailyForecastProtocol.h
//  weather
//
//  Created by Nicholas Galasso on 6/20/19.
//  Copyright © 2019 Rockshassa. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NGDailyForecastProtocol <NSObject>

@property (nullable, nonatomic, copy) NSDate *date;
@property (nonatomic) float apparentTemperatureHigh;
@property (nonatomic) float apparentTemperatureLow;
@property (nullable, nonatomic, copy) NSString *iconName;
@property (nullable, nonatomic, copy) NSString *summary;
@property (readonly) NSString *weekday;

@end

NS_ASSUME_NONNULL_END
