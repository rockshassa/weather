//
//  NGForecastDetailViewController.m
//  weather
//
//  Created by Nicholas Galasso on 6/20/19.
//  Copyright © 2019 Rockshassa. All rights reserved.
//

#import "NGForecastDetailViewController.h"
#import "NGDailyForecast+CoreDataProperties.h"

@import CoreData;

@interface NGForecastDetailViewController ()

@property (nonatomic) NSManagedObjectID *forecastID;
@property (nonatomic) NSManagedObjectContext *viewContext;
@property (nonatomic) NGDailyForecast *forecast;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UILabel *textLabel;

@end

@implementation NGForecastDetailViewController

-(instancetype)initWithObjectID:(NSManagedObjectID*)objectID inContext:(NSManagedObjectContext*)context{
    self = [super init];
    if (self) {
        _forecastID = objectID;
        _viewContext = context; //assumed to be a main-thread context
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _forecast = [_viewContext objectWithID:_forecastID];
    
    self.title = _forecast.weekday;
    
    _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:_forecast.iconName]];
    _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_imageView];
    
    _textLabel  = [UILabel new];
    _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _textLabel.text = [NSString stringWithFormat:@"%@\n%@\nHigh: %f\nLow: %f",_forecast.weekday, _forecast.summary, _forecast.apparentTemperatureHigh, _forecast.apparentTemperatureLow];
    _textLabel.numberOfLines = 0;
    [self.view addSubview:_textLabel];
    
    [_imageView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [_imageView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20].active = YES;
    [_imageView.heightAnchor constraintEqualToConstant:_imageView.image.size.height].active = YES;
    
    [_textLabel.topAnchor constraintEqualToSystemSpacingBelowAnchor:_imageView.bottomAnchor multiplier:1].active = YES;
    [_textLabel.leadingAnchor constraintEqualToSystemSpacingAfterAnchor:self.view.leadingAnchor multiplier:1].active = YES;
    [_textLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    
}


@end
