//
//  ViewController.m
//  weather
//
//  Created by Nicholas Galasso on 6/19/19.
//  Copyright © 2019 Rockshassa. All rights reserved.
//

#import "NGDaysCollectionViewController.h"
#import "NGDaysCollectionViewCell.h"
#import "NGDailyForecast+CoreDataProperties.h"

@import CoreLocation;
@import CoreData;

@interface NGDaysCollectionViewController () <CLLocationManagerDelegate, NSFetchedResultsControllerDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic) UIActivityIndicatorView *spinner;

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLLocation *currentLocation;
@property (nonatomic) BOOL fetchingForecast;
@property (nonatomic) BOOL displayingError;

@property (nonatomic) NSManagedObjectContext *writeContext;
@property (nonatomic) NSPersistentContainer *container;
@property (nonatomic) NSFetchedResultsController *resultsController;

@end

static NSString * const cellReuseIdentifier = @"com.weather.NGDaysCollectionViewCell.reuse";

@implementation NGDaysCollectionViewController

+(UICollectionViewFlowLayout*)defaultLayout{
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    flow.scrollDirection = UICollectionViewScrollDirectionVertical;
    return flow;
}

-(instancetype)initWithPersistentContainer:(NSPersistentContainer*)container{
    self = [super initWithCollectionViewLayout:[[self class] defaultLayout]];
    if (self){
        _container = container;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Weather near me";
    self.collectionView.backgroundColor = [UIColor grayColor];
    
    [self.collectionView registerClass:[NGDaysCollectionViewCell class] forCellWithReuseIdentifier:cellReuseIdentifier];
    
    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _spinner.translatesAutoresizingMaskIntoConstraints = NO;
    _spinner.hidden = YES;
    [self.view addSubview:_spinner];
    
    [_spinner.centerXAnchor constraintEqualToAnchor:self.collectionView.centerXAnchor].active = YES;
    [_spinner.centerYAnchor constraintEqualToAnchor:self.collectionView.centerYAnchor].active = YES;
    
    _writeContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    _writeContext.parentContext = self.container.viewContext;
    
    _locationManager = [CLLocationManager new];
    _locationManager.delegate = self;
    
    NSFetchRequest<NGDailyForecast*> *fetch = [NGDailyForecast fetchRequest];
    fetch.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES]];
    
    _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetch
                                                             managedObjectContext:_container.viewContext
                                                               sectionNameKeyPath:nil
                                                                        cacheName:nil];
    _resultsController.delegate = self;
    
    //wake it up
    NSError *fetchError;
    [_resultsController performFetch:&fetchError];
    NSLog(@"perform fetch w/ error: %@", fetchError);
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self requestLocationIfNeeded];
}

#pragma - NSFetchedResultsController Delegate

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    [self.collectionView reloadData];
}

#pragma mark - Error Handling

-(void)displayErrorWithReason:(NSString*)reason{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, reason);
    
    if (_displayingError){ //naive limit of 1 error
        return;
    }
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Oh no!"
                                                                message:reason
                                                         preferredStyle:UIAlertControllerStyleAlert];
    
    __weak typeof(self) weakSelf = self;
    [ac addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [ac.presentingViewController dismissViewControllerAnimated:YES
                                                        completion:^{
                                                            weakSelf.displayingError = NO;
                                                        }];
    }]];
    
    _displayingError = YES;
    [self presentViewController:ac animated:YES completion:nil];
}

#pragma mark - Location Handling

-(void)requestLocationIfNeeded{
    
    if (_currentLocation){
        return;
    }
    
    switch (CLLocationManager.authorizationStatus) {
        case kCLAuthorizationStatusNotDetermined:
            [_locationManager requestWhenInUseAuthorization];
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [_locationManager requestLocation];
            [_spinner startAnimating];
            break;
        default:
            break;
    }
}

#pragma mark - Network Request

static NSString * const apiKey = @"ee36d69e7b17d4f49a545b25ae35899e";

-(void)fetchForecastForLocation:(CLLocation*)location{
    if (_fetchingForecast || !location){
        return;
    }
    _fetchingForecast = YES;
    [_spinner startAnimating];
    
    NSString *format = [[NSString alloc] initWithFormat:@"https://api.darksky.net/forecast/%@/%f,%f?exclude=currently,minutely,hourly,alerts,flags", apiKey, location.coordinate.latitude, location.coordinate.longitude];
    
    NSURL *url = [[NSURL alloc] initWithString:format];
    
    __weak typeof(self) weakSelf = self;
    [[[NSURLSession sharedSession] dataTaskWithURL:url
                                 completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                     
                                     NSError *parseError;
                                     id dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
                                     
                                     //TODO: care about the HTTP status code
                                     
                                     NSString *errorMsg;
                                     
                                     if (error ||
                                         dict == [NSNull null] ||
                                         ![dict isKindOfClass:[NSDictionary class]]){
                                         errorMsg = @"A network error occurred";
                                     } else if (parseError) {
                                         errorMsg = @"A parsing error occurred";
                                     } else {
                                         [weakSelf parseResponse:(NSDictionary*)dict];
                                     }
                                     
                                     
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         if (errorMsg){
                                             [weakSelf displayErrorWithReason:errorMsg];
                                         }
                                         weakSelf.fetchingForecast = NO;
                                         [weakSelf.spinner stopAnimating];
                                     });
                                 }] resume];
}

-(void)parseResponse:(NSDictionary*)response{
    
    //NOTE: because these keys do not get re-used elsewhere in the code, i am using literals
    //production code would probably define string constants for reuse
    
    //NOTE: normally you'd want to update an existing record (if it exists), rather than blindly inserting and getting duplicates
    //for the sake of this example, nuking the DB to remove duplicates
    [self.writeContext reset];
    
    NSDictionary *daily = response[@"daily"]; //this should be null- and type- checked
    NSArray *data = daily[@"data"]; //and this
    __weak typeof(self) weakSelf = self;
    
    [self.writeContext performBlock:^{
        
        for (NSDictionary *d in data){
            NGDailyForecast *forecast = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([NGDailyForecast class]) inManagedObjectContext:weakSelf.writeContext];
            
            //These should also be type- and null-checked.
            //In Swift this would be done with Codable and we'd get that behavior for free
            
            NSNumber *time = d[@"time"];
            forecast.date = [[NSDate alloc] initWithTimeIntervalSince1970:time.doubleValue];
            
            NSNumber *low = d[@"apparentTemperatureLow"];
            forecast.apparentTemperatureLow = low.floatValue;
            
            NSNumber *high = d[@"apparentTemperatureHigh"];
            forecast.apparentTemperatureHigh = high.floatValue;
            
            forecast.iconName = d[@"icon"];
            forecast.summary = d[@"summary"];
            
            NSLog(@"%@",forecast);
        }
        
        NSError *saveError;
        [weakSelf.writeContext save:&saveError];
        NSLog(@"saved ctx with error: %@", saveError);
    }];
}

#pragma mark - CLLocationManager Delegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    if (locations.firstObject != nil){
        _currentLocation = locations.firstObject;
        [self fetchForecastForLocation:_currentLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    [self requestLocationIfNeeded];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"%s %@",__PRETTY_FUNCTION__, error);
    [self displayErrorWithReason:@"A GPS error occurred"];
    [_spinner stopAnimating];
}

#pragma mark - UICollectionView Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _resultsController.fetchedObjects.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NGDaysCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellReuseIdentifier forIndexPath:indexPath];
    
    [cell setDailyForecast:[_resultsController objectAtIndexPath:indexPath]];
    
    return cell;
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(CGRectGetWidth(collectionView.frame), 100);
}

@end
