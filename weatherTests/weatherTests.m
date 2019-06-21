//
//  weatherTests.m
//  weatherTests
//
//  Created by Nicholas Galasso on 6/19/19.
//  Copyright © 2019 Rockshassa. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NGDailyForecastProtocol.h"
#import "NGMockForecast.h"
#import "NGDailyForecast+CoreDataClass.h"

@interface weatherTests : XCTestCase

@end

@implementation weatherTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

-(void)testParsing{
    
    const CGFloat knownHigh = 74.25;
    const CGFloat knownLow = 69.75;
    NSString *knownIcon = @"rain";
    NSString *knownSummary = @"Possible light rain in the evening and overnight.";
    const CGFloat knownTime = 1560916800;
    
    NSString *sampleJSON = [NSString stringWithFormat:@"{ \"apparentTemperatureHigh\" : %f,"
                            "\"apparentTemperatureLow\" : %f,"
                            "\"icon\" : \"%@\","
                            "\"summary\" : \"%@\","
                            "\"time\" : %f }", knownHigh, knownLow, knownIcon, knownSummary, knownTime];
    
    NSData *data = [sampleJSON dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NGMockForecast *mock = [NGMockForecast new];
    [NGDailyForecast updateForecast:mock withJSON:json];
    
    XCTAssert(mock.apparentTemperatureLow == knownLow);
    XCTAssert(mock.apparentTemperatureHigh == knownHigh);
    XCTAssert([mock.iconName isEqualToString:knownIcon]);
    XCTAssert([mock.summary isEqualToString:knownSummary]);
    XCTAssert(mock.date.timeIntervalSince1970 == knownTime);
    
}

@end
