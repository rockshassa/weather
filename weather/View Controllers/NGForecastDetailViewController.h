//
//  NGForecastDetailViewController.h
//  weather
//
//  Created by Nicholas Galasso on 6/20/19.
//  Copyright © 2019 Rockshassa. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NSManagedObjectID;
@class NSManagedObjectContext;

NS_ASSUME_NONNULL_BEGIN

@interface NGForecastDetailViewController : UIViewController
-(instancetype)initWithObjectID:(NSManagedObjectID*)objectID inContext:(NSManagedObjectContext*)context;
@end

NS_ASSUME_NONNULL_END
