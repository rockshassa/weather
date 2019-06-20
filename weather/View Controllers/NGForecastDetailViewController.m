//
//  NGForecastDetailViewController.m
//  weather
//
//  Created by Nicholas Galasso on 6/20/19.
//  Copyright © 2019 Rockshassa. All rights reserved.
//

#import "NGForecastDetailViewController.h"
#import "NGDailyForecast+CoreDataProperties.h"
#import "NGPushAnimator.h"

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
    _imageView.tag = NG_ANIMATION_DESTINATION_TAG;
    [self.view addSubview:_imageView];
    
    _textLabel  = [UILabel new];
    _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _textLabel.text = [NSString stringWithFormat:@"%@\n%@\nHigh: %f\nLow: %f",_forecast.weekday, _forecast.summary, _forecast.apparentTemperatureHigh, _forecast.apparentTemperatureLow];
    _textLabel.numberOfLines = 0;
    [_textLabel sizeToFit];
    [self.view addSubview:_textLabel];
    
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    /*
     it seems that Autolayout does not update the constraints of this VC prior to
     - (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext being called
     this messed with the animation i wanted to do so I am placing these views by setting frames
     */
    
    _imageView.center = CGPointMake(CGRectGetMidX(self.view.bounds), self.view.safeAreaInsets.top+60); //magic number 60 is bad
    _textLabel.center = self.view.center;
}

@end
