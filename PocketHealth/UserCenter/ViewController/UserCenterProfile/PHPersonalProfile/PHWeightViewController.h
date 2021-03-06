//
//  PHWeightViewController.h
//  PocketHealth
//
//  Created by macmini on 15-1-13.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PHWeightViewDelegate <NSObject>
-(void)pickWeight:(NSInteger)weight;
@end
@interface PHWeightViewController : UIViewController
@property(nonatomic, assign) id<PHWeightViewDelegate> delegate;

-(id)initWithWeight:(NSInteger)w;
-(void)showInView:(UIView *)view;
-(void)hidden;
-(BOOL)isShow;
@end
