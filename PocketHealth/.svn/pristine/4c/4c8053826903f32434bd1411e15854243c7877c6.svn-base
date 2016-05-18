//
//  UINavigationController+PHNavigationController.m
//  PocketHealth
//
//  Created by macmini on 15-1-24.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "UINavigationController+PHNavigationController.h"

@implementation UINavigationController (PHNavigationController)
-(void)setMonitoringViewNavigationView
{
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"monitoring-firstbarbackgroundimage"] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationBar.translucent = NO;
    [self setNavigationBarHidden:NO];
    self.navigationBar.hidden = NO;
    [self setStatusBarStyle:UIStatusBarStyleLightContent];
    [self setTitleTextColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.f]];
}

-(void)setOtherViewNavigation
{
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"naviTopBarColor"] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
    [self setTitleTextColor:[UIColor whiteColor]];
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationBar.translucent = NO;
    [self setNavigationBarHidden:NO];
    self.navigationBar.hidden = NO;
    [self setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(void)setTranslucentView
{
    [self.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
    self.navigationBar.translucent = YES;
    [self setTitleTextColor:[UIColor whiteColor]];
    self.navigationBar.tintColor = [UIColor whiteColor];
}

-(void)setTranslucentViewForPersonalInfoView
{
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"usercenter-navBarBackImage"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setBackgroundColor:[UIColor clearColor]];
    self.navigationBar.translucent = NO;
    self.navigationBar.shadowImage = [UIImage new];
    self.navigationBar.tintColor = [UIColor whiteColor];
}

- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}

-(void)setActivity_Sleep_Mood_View
{
    UIImage *backGroundImage = [UIImage imageNamed:@"monitoring-backgroundInSideTop"];
    UIImage *image = [self scaleToSize:backGroundImage size:CGSizeMake(self.navigationBar.frame.size.width, self.navigationBar.frame.size.height + 20)];
    
    [self.navigationBar setBackgroundImage:image
                             forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
    [self setTitleTextColor:[UIColor whiteColor]];
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationBar.translucent = NO;
    [self setNavigationBarHidden:NO];
    self.navigationBar.hidden = NO;
    [self setStatusBarStyle:UIStatusBarStyleLightContent];
}


-(void)setTitleTextColor:(UIColor *)color
{
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName :color}];
}

-(void)setStatusBarStyle:(UIStatusBarStyle)style
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [[UIApplication sharedApplication] setStatusBarStyle:style animated:NO];
}
@end
