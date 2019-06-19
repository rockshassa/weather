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

@end
