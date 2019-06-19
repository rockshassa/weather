//
//  ViewController.h
//  weather
//
//  Created by Nicholas Galasso on 6/19/19.
//  Copyright © 2019 Rockshassa. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NSPersistentContainer;

@interface NGDaysCollectionViewController : UICollectionViewController

-(instancetype)initWithPersistentContainer:(NSPersistentContainer*)container;

+(UICollectionViewFlowLayout*)defaultLayout;

@end

