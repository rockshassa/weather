//
//  DaysCollectionViewCell.m
//  weather
//
//  Created by Nicholas Galasso on 6/19/19.
//  Copyright © 2019 Rockshassa. All rights reserved.
//

#import "NGDaysCollectionViewCell.h"
#import "NGDailyForecast+CoreDataProperties.h"

@interface NGDaysCollectionViewCell ()

@property (nonatomic) UIImageView *iconView;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *temperatureLabel;

@end

@implementation NGDaysCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        _titleLabel = [UILabel new];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.allowsDefaultTighteningForTruncation = YES;
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:_titleLabel];
        
        _iconView = [UIImageView new];
        _iconView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_iconView];

        //Build Constraints
        [_iconView.topAnchor constraintEqualToSystemSpacingBelowAnchor:self.contentView.topAnchor multiplier:1].active = YES;
        [_iconView.leadingAnchor constraintEqualToSystemSpacingAfterAnchor:self.contentView.leadingAnchor multiplier:1].active = YES;
        
        [_titleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [_titleLabel.leadingAnchor constraintEqualToSystemSpacingAfterAnchor:self.iconView.trailingAnchor multiplier:1].active = YES;
        [_titleLabel.topAnchor constraintEqualToSystemSpacingBelowAnchor:self.contentView.topAnchor multiplier:1].active = YES;
        
        NSLayoutConstraint *labelTrailing = [_titleLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor];
        labelTrailing.priority = UILayoutPriorityDefaultLow;
//        labelTrailing.active = YES;
        
    }
    return self;
}

-(void)setDailyForecast:(NGDailyForecast*)forecast{
    
    //TODO: use attributed string
    self.titleLabel.text = [NSString stringWithFormat:@"%@\n%@",forecast.weekday, forecast.summary];
    UIImage *img = [UIImage imageNamed:@"clear-day"];
    _iconView.image = img;
//    self.titleLabel.text = @"FRidayy";
}

-(void)prepareForReuse{
    self.titleLabel.text = nil;
    self.iconView.image = nil;
    [super prepareForReuse];
}

@end
