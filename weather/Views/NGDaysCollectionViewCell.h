//
//  DaysCollectionViewCell.h
//  weather
//
//  Created by Nicholas Galasso on 6/19/19.
//  Copyright © 2019 Rockshassa. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NGDailyForecast;

NS_ASSUME_NONNULL_BEGIN

@interface NGDaysCollectionViewCell : UICollectionViewCell

-(void)setDailyForecast:(NGDailyForecast*)forecast;

@end

NS_ASSUME_NONNULL_END
