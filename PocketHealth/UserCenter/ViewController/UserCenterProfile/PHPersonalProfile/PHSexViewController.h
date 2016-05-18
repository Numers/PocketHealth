//
//  PHWeightViewController.h
//  PocketHealth
//
//  Created by macmini on 15-1-13.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Member.h"

@protocol PHSexViewDelegate <NSObject>
-(void)pickSex:(sexCode)sex;
@end
@interface PHSexViewController : UIViewController
@property(nonatomic, assign) id<PHSexViewDelegate> delegate;

-(void)showInView:(UIView *)view;
-(void)hidden;
-(BOOL)isShow;
@end