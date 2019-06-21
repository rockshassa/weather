//
//  NGDailyForecast+CoreDataClass.m
//  weather
//
//  Created by Nicholas Galasso on 6/19/19.
//  Copyright © 2019 Rockshassa. All rights reserved.
//
//

#import "NGDailyForecast+CoreDataClass.h"

@implementation NGDailyForecast

-(NSString*)weekday{
    NSCalendarUnit dayOfTheWeek = [[NSCalendar currentCalendar] component:NSCalendarUnitWeekday fromDate:self.date];
    
    //TODO: really these should be localized
    switch (dayOfTheWeek) {
        case 1:
            return @"Sunday";
        case 2:
            return @"Monday";
        case 3:
            return @"Tuesday";
        case 4:
            return @"Wednesday";
        case 5:
            return @"Thursday";
        case 6:
            return @"Friday";
        case 7:
            return @"Saturday";
        default:
            return @"";
    }
}

//use the protocol instead of a concrete type so that the parsing logic can be tested w/ a mock object not attached to a context
//if this was Swift, this could instead be an instance method bolted on to all objects conforming to NGDailyForecastProtocol
+(id<NGDailyForecastProtocol>)updateForecast:(id<NGDailyForecastProtocol>)forecast withJSON:(NSDictionary*)json{
    
    //These should also be type- and null-checked.
    //In Swift this would be done with Codable and we'd get that behavior for free
    //should define string constants instead of using literals in a production app
    
    NSNumber *time = json[@"time"];
    forecast.date = [[NSDate alloc] initWithTimeIntervalSince1970:time.doubleValue];
    
    NSNumber *low = json[@"apparentTemperatureLow"];
    forecast.apparentTemperatureLow = low.floatValue;
    
    NSNumber *high = json[@"apparentTemperatureHigh"];
    forecast.apparentTemperatureHigh = high.floatValue;
    
    forecast.iconName = json[@"icon"];
    forecast.summary = json[@"summary"];
    
    return forecast;
}

@end
