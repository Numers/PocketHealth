//
//  AppDelegate.h
//  PocketHealth
//
//  Created by macmini on 15-1-5.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import "PHAppStartView.h"
#import "BPush.h"

@protocol UIAppDelegate <NSObject>

@optional
-(void)refreshStepsToday:(NSInteger )steps;
@end
@interface AppDelegate : UIResponder <UIApplicationDelegate,BPushDelegate>
{
    PHAppStartView *view;
}

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic) NSInteger numSteps; //当前今日步数
@property (nonatomic) NSInteger numM7Steps; //在m7处理器下的记步数据保存
//@property (nonatomic) BOOL isInBackCountStep;
//主动退出应用 不重连
@property (nonatomic) BOOL isInitiativeExitChatConnect;
@property (nonatomic,weak) id <UIAppDelegate> delegate;
@property (nonatomic , strong)    NSNumber * stepsToday;
/**
 *  停止记步以及睡眠计算
 */
-(void)stopStepsAndSleepCount;

/**
 *  返回昨天的睡眠时长 分钟单位
 *
 *  @return 返回睡眠时长 分钟单位
 */
-(NSNumber *)returnYesterdaySleepMinutes:(long long)memberId;

-(void)clearStepsWithZero;
@end

