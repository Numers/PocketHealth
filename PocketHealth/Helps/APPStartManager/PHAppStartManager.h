//
//  PHAppStartManager.h
//  PocketHealth
//
//  Created by macmini on 15-1-5.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PHAppNavigationViewController.h"
#import "Member.h"
#import "PHGroupChatHomeViewController.h"
#import "PHMonitoringViewController.h"
#import "PHProtocol.h"
@interface PHAppStartManager : NSObject
{
    Member *host;
    PHGroupChatHomeViewController *phGroupChatHomeVC;
    PHMonitoringViewController *phMonitoringVC;
}

@property(nonatomic, strong) UINavigationController *navigationController;
@property(nonatomic, strong) UITabBarController *tabBarController;

+(id)defaultManager;
-(id<PHPushChatViewDelegate>)returnPHGroupChatHomeView;
-(id<PHPushFindDocotorViewDelegate>)returnPHMonitoringView;
-(void)popToTabBarControllerWithIndex:(NSInteger)index;
-(Member *)userHost;
-(void)setHostMember:(Member *)member;

-(void)pushHomeViewWithSelectIndex:(NSInteger)index;
-(void)startApp;
-(void)loginOut;

-(void)doNecessaryPreparationsAfterAppStart;
@end
