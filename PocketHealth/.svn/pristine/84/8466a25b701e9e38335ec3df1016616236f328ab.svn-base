//
//  PHActivityInsideViewController.h
//  PocketHealth
//
//  Created by YangFan on 15/1/22.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PHActivityInsideViewControllerDelegate <NSObject>

-(void)btnSettingPNIClick;
-(void)btnSettingMetabolismClick;

@end

@interface PHActivityInsideViewController : UIViewController
@property (nonatomic) NSInteger leftCalorie;
@property (nonatomic ,weak) id<PHActivityInsideViewControllerDelegate> delegate;

-(void)resettingCalorie:(NSInteger )calorie;
@end
