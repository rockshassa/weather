//
//  ViewController.m
//  weather
//
//  Created by Nicholas Galasso on 6/19/19.
//  Copyright © 2019 Rockshassa. All rights reserved.
//

#import "NGDaysCollectionViewController.h"
#import "NGDaysCollectionViewCell.h"

@interface NGDaysCollectionViewController ()

@end

static NSString * const cellReuseIdentifier = @"com.weather.NGDaysCollectionViewCell.reuse";

@implementation NGDaysCollectionViewController

+(UICollectionViewFlowLayout*)defaultLayout{
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    flow.scrollDirection = UICollectionViewScrollDirectionVertical;
    flow.itemSize = UICollectionViewFlowLayoutAutomaticSize;
    flow.estimatedItemSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), 200);
    return flow;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor cyanColor];
    [self.collectionView registerClass:[NGDaysCollectionViewCell class] forCellWithReuseIdentifier:cellReuseIdentifier];
}

#pragma mark - UICollectionView Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 7;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NGDaysCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellReuseIdentifier forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor greenColor];
    
    return cell;
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

@end
