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
#import "NGForecastDetailViewController.h"
#import "NGPushAnimator.h"

@import CoreLocation;
@import CoreData;

@interface NGDaysCollectionViewController () <CLLocationManagerDelegate, NSFetchedResultsControllerDelegate, UICollectionViewDelegateFlowLayout, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate>

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
    self.navigationController.delegate = self;
    
    //the custom push animation causes this pop gesture to be disabled. this re-enables it
    //ideally I'd check for protocol conformance before casting self as UIGestureRecognizerDelegate
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    
    [self.collectionView registerClass:[NGDaysCollectionViewCell class]
            forCellWithReuseIdentifier:cellReuseIdentifier];
    
    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_spinner];
    
    _writeContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    _writeContext.parentContext = self.container.viewContext;
    _writeContext.automaticallyMergesChangesFromParent = YES;
    
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

#pragma mark - UINavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC{
    
    switch (operation) {
        case UINavigationControllerOperationPush:
            return [NGPushAnimator new];
        default:
            return nil;
    }
}


#pragma mark - NSFetchedResultsController Delegate

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    NSAssert([NSThread mainThread], @"");
    [self.collectionView reloadData];
    if (controller.fetchedObjects.count){
        [_spinner stopAnimating];
    }
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
            [self displayErrorWithReason:@"Please allow location access in settings"];
            break;
    }
}

#pragma mark - Network Request Handling

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
                                     
                                     //TODO: care about the HTTP status code
                                     
                                     NSString *errorMsg;
                                     
                                     if (!data ||
                                         error){
                                         errorMsg = @"A network error occurred";
                                     } else {
                                         NSError *parseError;
                                         id dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
                                         if (parseError ||
                                             dict == [NSNull null] ||
                                             ![dict isKindOfClass:[NSDictionary class]]) {
                                             errorMsg = @"There is a problem with the response";
                                         } else {
                                             //should occur on BG thread
                                            [weakSelf handleResponse:(NSDictionary*)dict];
                                         }
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

#pragma mark - Coredata Stuff

-(void)handleResponse:(NSDictionary*)response{
    
    //NOTE: because these keys do not get re-used elsewhere in the code, i am using literals here
    //production code would define string constants for reuse
    
    NSDictionary *daily = response[@"daily"]; //this should be null- and type- checked
    NSArray *data = daily[@"data"]; //and this
    __weak typeof(self) weakSelf = self;
    
    [self.writeContext performBlock:^{
    
        //NOTE: normally you'd want to update an existing record (if it exists), rather than blindly inserting and getting duplicates etc
        //for the sake of this example, nuking the DB to remove duplicates
        //the delete is a blocking operation on the writeContext's private queue,
        //not something i'd do for real but necessary in this particular scenario
        [weakSelf nukeViewContext];
        
        for (NSDictionary *d in data){
            [self insertForecastWithJSON:d]; //batch insert would be more performant
        }
        
        NSError *writeError;
        [weakSelf.writeContext save:&writeError];
        
        if (writeError) {
            NSLog(@"saved write ctx with error: %@", writeError);
        } else {
            
            //OK to do this because we know its a main-thread context.
            //but probably not the prettiest way to get this to happen
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *viewSaveError;
                [weakSelf.container.viewContext save:&viewSaveError];
                NSLog(@"saved view ctx with error: %@",viewSaveError);
            });
        }
    }];
}

-(void)insertForecastWithJSON:(NSDictionary*)json{
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([NGDailyForecast class])
                                              inManagedObjectContext:self.writeContext];
    NGDailyForecast *forecast = [[NGDailyForecast alloc] initWithEntity:entity
                                         insertIntoManagedObjectContext:self.writeContext];
    NSError *insertError;
    
    //need this as the object ID is passed to the detail view controller
    [self.writeContext obtainPermanentIDsForObjects:@[forecast] error:&insertError];
    
    if (insertError) {
        NSLog(@"couldn't get permanent object ID. %@", insertError);
    }
    
    [NGDailyForecast updateForecast:forecast withJSON:json];
}

-(void)nukeViewContext{
    
    //generally prefer not to perform any operations on the ViewContext, but it is the parent in this example
    [self.container.viewContext performBlockAndWait:^{
        
        NSError *fetchError;
        NSArray<NGDailyForecast*>* results = [self.container.viewContext executeFetchRequest:[NGDailyForecast fetchRequest]
                                                                                       error:&fetchError];
        for (NGDailyForecast *r in results){
            //batch delete is faster but changes don't propogate to the UI
            [self.container.viewContext deleteObject:r];
        }
        
        //delete will be auto-propagated to the write context
        NSError *saveError;
        [self.container.viewContext save:&saveError];
        
        if (saveError){
            NSLog(@"delete error %@", saveError);
        }
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
    NGDailyForecast *forecast = _resultsController.fetchedObjects[indexPath.row];
    NGForecastDetailViewController *vc = [[NGForecastDetailViewController alloc] initWithObjectID:forecast.objectID
                                                                                        inContext:self.container.viewContext];
    
    //setup for animation
    NGDaysCollectionViewCell *cell = (NGDaysCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    cell.iconView.tag = NG_ANIMATION_SOURCE_TAG;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(CGRectGetWidth(collectionView.frame), 80);
}

@end
