//
//  DaysCollectionViewCell.m
//  weather
//
//  Created by Nicholas Galasso on 6/19/19.
//  Copyright © 2019 Rockshassa. All rights reserved.
//

#import "NGDaysCollectionViewCell.h"

@interface NGDaysCollectionViewCell ()

@property (nonatomic) UILabel *titleLabel;

@end

@implementation NGDaysCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        _titleLabel = [UILabel new];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = false;
        [self.contentView addSubview:_titleLabel];
        _titleLabel.text = @"Foo";
        
        [_titleLabel.leadingAnchor constraintEqualToSystemSpacingAfterAnchor:self.contentView.leadingAnchor multiplier:1].active = YES;
        [_titleLabel.topAnchor constraintEqualToSystemSpacingBelowAnchor:self.contentView.topAnchor multiplier:1].active = YES;
        [_titleLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor].active = YES;
        [_titleLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor].active = YES;
        
    }
    return self;
}

@end
