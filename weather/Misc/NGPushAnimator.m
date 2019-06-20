//
//  NGPushAnimator.m
//  weather
//
//  Created by Nicholas Galasso on 6/20/19.
//  Copyright © 2019 Rockshassa. All rights reserved.
//

#import "NGPushAnimator.h"
@import GLKit;

@implementation NGPushAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 1;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIView *container = transitionContext.containerView;
    
    [container addSubview:toViewController.view];
    
    UIView *fromIcon = [fromViewController.view viewWithTag:NG_ANIMATION_SOURCE_TAG];
    UIView *toIcon = [toViewController.view viewWithTag:NG_ANIMATION_DESTINATION_TAG];
    
    UIView *snap = [fromIcon snapshotViewAfterScreenUpdates:NO];
    snap.translatesAutoresizingMaskIntoConstraints = NO;
    [container addSubview:snap];
    
    snap.center = [container convertPoint:fromIcon.center fromView:fromIcon.superview];
    
    toViewController.view.alpha = 0;
    fromIcon.alpha = 0;
    toIcon.alpha = 0;
    
    [toViewController.view layoutIfNeeded];
    
    [UIView animateKeyframesWithDuration:[self transitionDuration:transitionContext]
                                   delay:0
                                 options:0
                              animations:^{
                                  
                                  [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 animations:^{
                                      toViewController.view.alpha = 1;
                                      snap.center = [container convertPoint:toIcon.center fromView:toIcon.superview];
                                  }];
                                  
                                  [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.5 animations:^{
                                      CGAffineTransform t = CGAffineTransformMakeScale(2, 2);
                                      t = CGAffineTransformRotate(t, GLKMathDegreesToRadians(180));
                                      snap.transform = t;
                                  }];
                                  
                                  [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
                                      CGAffineTransform t = snap.transform;
                                      t = CGAffineTransformRotate(t, GLKMathDegreesToRadians(180));
                                      t = CGAffineTransformScale(t, 0.5, 0.5);
                                      snap.transform = t;
                                  }];
                                  
                              } completion:^(BOOL finished) {
                                  toIcon.alpha = 1;
                                  fromIcon.alpha = 1;
                                  fromIcon.tag = 0;
                                  [snap removeFromSuperview];
                                  [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                              }];
}

@end
