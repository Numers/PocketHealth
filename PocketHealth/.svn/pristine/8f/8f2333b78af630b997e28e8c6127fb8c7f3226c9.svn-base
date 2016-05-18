//
//  CalculateViewFrame.m
//  PocketHealth
//
//  Created by YangFan on 15/1/7.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "CalculateViewFrame.h"

@implementation CalculateViewFrame

#pragma mark - 视图位置计算
+(CGRect)viewFrame:(UINavigationController *)navigationController withTabBarController:(UITabBarController *)tabBarOutController
{
    CGRect frame;
    if([[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."][0] intValue] >= 7){
//        [navigationController.navigationBar setTranslucent:NO];
    }
    float heightPadding;
    if (navigationController == nil) {
        heightPadding      =  0;
    }else{
        CGRect statusBarViewRect = [[UIApplication sharedApplication] statusBarFrame];
        heightPadding      = statusBarViewRect.size.height + navigationController.navigationBar.frame.size.height;
    }
    


    float height             = tabBarOutController.tabBar.frame.size.height;
    frame                    = CGRectMake([UIScreen mainScreen].bounds.origin.x, [UIScreen mainScreen].bounds.origin.y - 0.5,[UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-height-heightPadding + 0.5);
    return frame;
}
@end
