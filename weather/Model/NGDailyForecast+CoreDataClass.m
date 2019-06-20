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

//use the protocol instead of a concrete type so that the parsing logic can be tested w/ a mock object not attached to an object context
-(void)updateFromJSON:(NSDictionary*)json{
    
    //These should also be type- and null-checked.
    //In Swift this would be done with Codable and we'd get that behavior for free
    
    NSNumber *time = json[@"time"];
    self.date = [[NSDate alloc] initWithTimeIntervalSince1970:time.doubleValue];
    
    NSNumber *low = json[@"apparentTemperatureLow"];
    self.apparentTemperatureLow = low.floatValue;
    
    NSNumber *high = json[@"apparentTemperatureHigh"];
    self.apparentTemperatureHigh = high.floatValue;
    
    self.iconName = json[@"icon"];
    self.summary = json[@"summary"];
}

@end
