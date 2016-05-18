//
//  PHAppStartManager.m
//  PocketHealth
//
//  Created by macmini on 15-1-5.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHAppStartManager.h"
#import "CommonUtil.h"
#import "AppDelegate.h"
#import "PHAFHttpHelper.h"

#import "PHGuidViewController.h"
#import "PHLoginViewController.h"
#import "PHUserCenterTableViewController.h"

//消息登录类
#import "PHSocketManagerHelper.h"

#import <AVFoundation/AVFoundation.h>

static PHAppStartManager *appStartManager;
static NSString *hostProfilePlist = @"PersonProfile.plist";
@implementation PHAppStartManager
+(id)defaultManager
{
    if (appStartManager == nil) {
        appStartManager = [[PHAppStartManager alloc] init];
    }
    return appStartManager;
}

-(Member *)userHost
{
    if (host == nil) {
        host = [self getProfileFromPlist];
    }
    return host;
}

-(void)setHostMember:(Member *)member
{
    host = member;
    [self saveProfileToPlist];
}

-(void)saveProfileToPlist
{
    NSDictionary *dic = [host dictionaryInfo];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *selfInfoPath = [documentsPath stringByAppendingPathComponent:hostProfilePlist];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:selfInfoPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:selfInfoPath error:nil];
    }
    
    [dic writeToFile:selfInfoPath atomically:YES];
}

-(Member *)getProfileFromPlist
{
    Member *member = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *selfInfoPath = [documentsPath stringByAppendingPathComponent:hostProfilePlist];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:selfInfoPath])
    {
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:selfInfoPath];
        if (dic != nil) {
            member = [[Member alloc] initlizedWithDictionary:dic];
        }
    }
    return member;
}

-(void)startApp
{
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:14/255.0
                                                        green:200/255.0 blue:200/255.0 alpha:1.0]];

//    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
//                                                          [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
//                                                          [UIFont systemFontOfSize:30.f], NSFontAttributeName, nil]];
    [[UINavigationBar appearance] setBackIndicatorImage:[UIImage imageNamed:@"backBarItemImage"]];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"backBarItemImage"]];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];
//    [[UITabBar appearance] setTranslucent:NO];
    Member *member = [self userHost];
    if (member){
        
        
        [self setHostMember:member];
        //        AFNetWorkKey = [CommonUtil createSendKeyWithUserName:host.loginName Userid:[NSString stringWithFormat:@"%lld",host.memberId]];
        //add by yangfan 自动连接socket服务器
        BOOL autoLogin = [[CommonUtil localUserDefaultsForKey:KMY_AutoLogin] boolValue];
        if (autoLogin) {
            
            [self doNecessaryPreparationsAfterAppStart];
            [self setHomeView];
            
        }else{
            [self setLoginView];
        }
        
    }else{
        [self setGuidView];
    }
}

-(id<PHPushChatViewDelegate>)returnPHGroupChatHomeView
{
    return phGroupChatHomeVC;
}

-(id<PHPushFindDocotorViewDelegate>)returnPHMonitoringView
{
    return phMonitoringVC;
}

-(void)popToTabBarControllerWithIndex:(NSInteger)index
{
    [self.navigationController popToViewController:self.tabBarController animated:NO];
    [self.tabBarController setSelectedIndex:index];
}

-(void)setHomeView
{
    _tabBarController = [[UITabBarController alloc] init];
    [_tabBarController.tabBar setTranslucent:NO];
    [_tabBarController.navigationItem setHidesBackButton:YES];
    phMonitoringVC = [[PHMonitoringViewController alloc] init];
    phGroupChatHomeVC = [[PHGroupChatHomeViewController alloc] init];
    PHUserCenterTableViewController *phUserCenterVC = [[PHUserCenterTableViewController alloc] init];
    _tabBarController.viewControllers = @[phMonitoringVC,phGroupChatHomeVC,phUserCenterVC];
    UITabBar *tabBar = _tabBarController.tabBar;
    UITabBarItem *item1 = [tabBar.items objectAtIndex:0];
    [item1 setImage:[UIImage imageNamed:@"usercenter-tabbarhealth-notselect"]];
    [item1 setSelectedImage:[UIImage imageNamed:@"usercenter-tabbarhealth-select"]];
    UITabBarItem *item2 = [tabBar.items objectAtIndex:1];
    [item2 setImage:[UIImage imageNamed:@"usercenter-tabbarchat-notselect"]];
    [item2 setSelectedImage:[UIImage imageNamed:@"usercenter-tabbarchat-select"]];
    UITabBarItem *item3 = [tabBar.items objectAtIndex:2];
    [item3 setImage:[UIImage imageNamed:@"usercenter-tabbarprofile-notselect"]];
    [item3 setSelectedImage:[UIImage imageNamed:@"usercenter-tabbarprofile-select"]];
    item1.title = @"天天健康";
    item2.title = @"健康吧";
    item3.title = @"我";
    _navigationController = [[UINavigationController alloc] initWithRootViewController:_tabBarController];
    [[(AppDelegate *)[UIApplication sharedApplication].delegate window] setRootViewController:_navigationController];
}

-(void)pushHomeViewWithSelectIndex:(NSInteger)index
{
    _tabBarController = [[UITabBarController alloc] init];
    [_tabBarController.tabBar setTranslucent:NO];
    [_tabBarController.navigationItem setHidesBackButton:YES];
    phMonitoringVC = [[PHMonitoringViewController alloc] init];
    phGroupChatHomeVC = [[PHGroupChatHomeViewController alloc] init];
    PHUserCenterTableViewController *phUserCenterVC = [[PHUserCenterTableViewController alloc] init];
    _tabBarController.viewControllers = @[phMonitoringVC,phGroupChatHomeVC,phUserCenterVC];
    UITabBar *tabBar = _tabBarController.tabBar;
    UITabBarItem *item1 = [tabBar.items objectAtIndex:0];
    [item1 setImage:[UIImage imageNamed:@"usercenter-tabbarhealth-notselect"]];
    [item1 setSelectedImage:[UIImage imageNamed:@"usercenter-tabbarhealth-select"]];
    UITabBarItem *item2 = [tabBar.items objectAtIndex:1];
    [item2 setImage:[UIImage imageNamed:@"usercenter-tabbarchat-notselect"]];
    [item2 setSelectedImage:[UIImage imageNamed:@"usercenter-tabbarchat-select"]];
    UITabBarItem *item3 = [tabBar.items objectAtIndex:2];
    [item3 setImage:[UIImage imageNamed:@"usercenter-tabbarprofile-notselect"]];
    [item3 setSelectedImage:[UIImage imageNamed:@"usercenter-tabbarprofile-select"]];
    item1.title = @"天天健康";
    item2.title = @"健康吧";
    item3.title = @"我";
    [_tabBarController setSelectedIndex:index];
    [_navigationController pushViewController:_tabBarController animated:YES];
}

-(void)setGuidView
{
    PHGuidViewController *phGuidVC = [[PHGuidViewController alloc] init];
    _navigationController = [[UINavigationController alloc] initWithRootViewController:phGuidVC];
    [[(AppDelegate *)[UIApplication sharedApplication].delegate window] setRootViewController:_navigationController];
}

-(void)setLoginView
{
    PHLoginViewController *phLoginVC = [[PHLoginViewController alloc] init];
    _navigationController = [[UINavigationController alloc] initWithRootViewController:phLoginVC];
    [[(AppDelegate *)[UIApplication sharedApplication].delegate window] setRootViewController:_navigationController];
}

-(void)loginOut
{
    NSLog(@"start loginout");
    NSLog(@"start loginout 关闭socket连接");
    [[PHSocketManagerHelper defaultManager] endSocket];
    
    [_navigationController popToRootViewControllerAnimated:NO];
    _navigationController = nil;
    _tabBarController = nil;
    [self setLoginView];
    NSLog(@"start loginout 准备插入登陆界面");
    [CommonUtil localUserDefaultsValue:[NSNumber numberWithBool:NO] forKey:KMY_AutoLogin];
    
    
    //停止记步睡眠采集
    AppDelegate * delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate stopStepsAndSleepCount];
    NSLog(@"start loginout 停止采样记步数据");
}

-(void)doNecessaryPreparationsAfterAppStart{
    [self canRecord];//录音权限开启判断 add by yangfan 2015-01-14 16:46:02
    AFNetWorkKey = [CommonUtil createSendKeyWithUserName:host.loginName Userid:[NSString stringWithFormat:@"%lld",host.memberId]];
    //启动聊天服务
    [[PHSocketManagerHelper defaultManager]startSocketWithMemberId:host.memberId];
}

//权限判断
- (BOOL)canRecord
{
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                if (granted) {
                    bCanRecord = YES;
                } else {
                    bCanRecord = NO;
                    //                    dispatch_async(dispatch_get_main_queue(), ^{
                    //                        [[[UIAlertView alloc] initWithTitle:@"无法录音" message:@"请在“设置-隐私-麦克风”选项中允许爱健康访问你的麦克风" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
                    //                    });
                }
            }];
        }
    }
    
    return bCanRecord;
}
@end
